import 'dart:async';

import 'package:fpdart/fpdart.dart' show Either;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failure.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../admin/domain/entities/admin_access.dart';
import '../../../admin/domain/repositories/admin_repository.dart';
import '../../../admin/presentation/pages/admin_dashboard_page.dart';
import '../../../admin/presentation/pages/admin_shop_detail_page.dart';
import '../../../billing/presentation/bloc/billing_bloc.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../shop/domain/entities/shop.dart';
import '../../../shop/domain/repositories/shop_repository.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../../../shop/presentation/pages/shop_access_status_page.dart';
import '../../../shop/presentation/pages/shop_details_page.dart';
import '../bloc/auth_bloc.dart';
import '../pages/auth_page.dart';
import '../pages/email_verification_page.dart';

/// Chooses the correct application surface for the current Firebase account.
///
/// Authentication proves who the user is. Firestore then decides whether the
/// account is an administrator and, for shop accounts, whether the shop is
/// allowed to use the application.
class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    required this.authenticatedChild,
    required this.adminRepository,
    required this.shopRepository,
  });

  final Widget authenticatedChild;
  final AdminRepository adminRepository;
  final ShopRepository shopRepository;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          _clearAccountData(context);
        }
      },
      builder: (context, state) {
        if (state is AuthAuthenticated && !state.user.emailVerified) {
          return Navigator(
            key: const ValueKey('email-verification-app'),
            onGenerateRoute:
                (_) => MaterialPageRoute<void>(
                  builder: (_) => EmailVerificationPage(user: state.user),
                ),
          );
        }
        if (state is AuthAuthenticated) {
          return _AccountAccessGate(
            key: ValueKey('account-access-${state.user.uid}'),
            uid: state.user.uid,
            pendingShopName: state.pendingShopName,
            adminRepository: adminRepository,
            shopRepository: shopRepository,
            authenticatedChild: authenticatedChild,
          );
        }
        if (state is AuthUnauthenticated ||
            state is AuthSubmitting ||
            state is AuthError) {
          return Navigator(
            key: const ValueKey('authentication-app'),
            onGenerateRoute:
                (_) =>
                    MaterialPageRoute<void>(builder: (_) => const AuthPage()),
          );
        }
        // The persisted Firebase session is still being restored. Do not
        // briefly show the sign-in form while this check is in progress.
        return const KeyedSubtree(
          key: ValueKey('authentication-loading-app'),
          child: Scaffold(body: Center(child: CircularProgressIndicator())),
        );
      },
    );
  }
}

class _AccountAccessGate extends StatefulWidget {
  const _AccountAccessGate({
    super.key,
    required this.uid,
    required this.pendingShopName,
    required this.adminRepository,
    required this.shopRepository,
    required this.authenticatedChild,
  });

  final String uid;
  final String? pendingShopName;
  final AdminRepository adminRepository;
  final ShopRepository shopRepository;
  final Widget authenticatedChild;

  @override
  State<_AccountAccessGate> createState() => _AccountAccessGateState();
}

class _AccountAccessGateState extends State<_AccountAccessGate> {
  late Stream<AdminAccess> _accessStream;

  @override
  void initState() {
    super.initState();
    _accessStream = widget.adminRepository.watchAdminAccess(widget.uid);
  }

  void _retry() {
    setState(() {
      _accessStream = widget.adminRepository.watchAdminAccess(widget.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AdminAccess>(
      stream: _accessStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _AccountAccessError(onRetry: _retry);
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            key: ValueKey('account-access-loading'),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final access = snapshot.requireData;
        // A known role remains on the admin surface even when disabled, where
        // the dashboard shows Access denied. It must not silently create a
        // normal shop for a revoked administrator.
        if (access.role != AdminRole.unknown) {
          return _AdminApplication(
            key: ValueKey('admin-application-${widget.uid}'),
            uid: widget.uid,
            repository: widget.adminRepository,
          );
        }

        return _ShopApplication(
          key: ValueKey('shop-application-${widget.uid}'),
          repository: widget.shopRepository,
          pendingShopName: widget.pendingShopName,
          authenticatedChild: widget.authenticatedChild,
        );
      },
    );
  }
}

class _AdminApplication extends StatefulWidget {
  const _AdminApplication({
    super.key,
    required this.uid,
    required this.repository,
  });

  final String uid;
  final AdminRepository repository;

  @override
  State<_AdminApplication> createState() => _AdminApplicationState();
}

class _AdminApplicationState extends State<_AdminApplication> {
  @override
  void initState() {
    super.initState();
    _clearAccountData(context);
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: const ValueKey('admin-app'),
      onGenerateRoute:
          (_) => MaterialPageRoute<void>(
            builder:
                (dashboardContext) => AdminDashboardPage(
                  repository: widget.repository,
                  adminUid: widget.uid,
                  onSignOut:
                      () => context.read<AuthBloc>().add(LogOutRequested()),
                  onOpenShop: (shop) {
                    Navigator.of(dashboardContext).push(
                      MaterialPageRoute<void>(
                        builder:
                            (_) => AdminShopDetailPage(
                              repository: widget.repository,
                              adminUid: widget.uid,
                              shop: shop,
                            ),
                      ),
                    );
                  },
                ),
          ),
    );
  }
}

class _ShopApplication extends StatefulWidget {
  const _ShopApplication({
    super.key,
    required this.repository,
    required this.pendingShopName,
    required this.authenticatedChild,
  });

  final ShopRepository repository;
  final String? pendingShopName;
  final Widget authenticatedChild;

  @override
  State<_ShopApplication> createState() => _ShopApplicationState();
}

class _ShopApplicationState extends State<_ShopApplication> {
  StreamSubscription<Either<Failure, Shop>>? _subscription;
  Shop? _shop;
  Object? _error;
  var _isLoading = true;
  var _generation = 0;
  ShopStatus? _lastSynchronizedStatus;
  late String _initialShopName;

  @override
  void initState() {
    super.initState();
    _initialShopName = widget.pendingShopName?.trim() ?? '';
    unawaited(_start());
  }

  @override
  void didUpdateWidget(covariant _ShopApplication oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newName = widget.pendingShopName?.trim() ?? '';
    if (_initialShopName.isEmpty && newName.isNotEmpty) {
      _initialShopName = newName;
      final currentShop = _shop;
      if (currentShop != null && currentShop.name.trim().isEmpty) {
        unawaited(
          widget.repository.updateShop(currentShop.copyWith(name: newName)),
        );
      }
    }
  }

  Future<void> _start() async {
    final generation = ++_generation;
    await _subscription?.cancel();
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    final ensured = await widget.repository.ensureShop(
      initialName: _initialShopName,
    );
    if (!mounted || generation != _generation) return;
    final failure = ensured.fold<Object?>((value) => value, (_) => null);
    if (failure != null) {
      _synchronizeRestrictedAccess();
      setState(() {
        _error = failure;
        _isLoading = false;
      });
      return;
    }

    _subscription = widget.repository.watchShop().listen(
      (result) {
        if (!mounted || generation != _generation) return;
        result.fold(
          (failure) {
            _synchronizeRestrictedAccess();
            setState(() {
              _error = failure;
              _isLoading = false;
            });
          },
          (shop) {
            _synchronizeStatus(shop.status);
            setState(() {
              _shop = shop;
              _error = null;
              _isLoading = false;
            });
          },
        );
      },
      onError: (Object error) {
        if (!mounted || generation != _generation) return;
        _synchronizeRestrictedAccess();
        setState(() {
          _error = error;
          _isLoading = false;
        });
      },
    );
  }

  void _synchronizeStatus(ShopStatus status) {
    if (_lastSynchronizedStatus == status) return;
    _lastSynchronizedStatus = status;
    if (status.allowsAccess) {
      context.read<ShopBloc>().add(LoadShopEvent());
      context.read<ProductBloc>().add(LoadProducts());
      return;
    }
    _clearAccountData(context);
  }

  void _synchronizeRestrictedAccess() {
    _lastSynchronizedStatus = null;
    _clearAccountData(context);
  }

  @override
  void dispose() {
    _generation++;
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        key: ValueKey('shop-access-loading'),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null || _shop == null) {
      return _AccountAccessError(onRetry: _start);
    }
    final shop = _shop!;
    if (shop.status.allowsAccess) {
      return KeyedSubtree(
        key: const ValueKey('authenticated-app'),
        child: widget.authenticatedChild,
      );
    }
    return Navigator(
      key: ValueKey('restricted-shop-${shop.status.firestoreValue}'),
      onGenerateRoute:
          (_) => MaterialPageRoute<void>(
            builder:
                (statusContext) => ShopAccessStatusPage(
                  shop: shop,
                  onRetry: _start,
                  onLogOut:
                      () => context.read<AuthBloc>().add(LogOutRequested()),
                  onCompleteProfile:
                      shop.status == ShopStatus.pending
                          ? () {
                            context.read<ShopBloc>().add(LoadShopEvent());
                            Navigator.of(statusContext).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const ShopDetailsPage(),
                              ),
                            );
                          }
                          : null,
                ),
          ),
    );
  }
}

class _AccountAccessError extends StatelessWidget {
  const _AccountAccessError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      key: const ValueKey('account-access-error'),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off_outlined, size: 52, color: scheme.error),
                const SizedBox(height: 16),
                Text(
                  l10n.shopAccessLoadFailed,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.retry),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed:
                      () => context.read<AuthBloc>().add(LogOutRequested()),
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(l10n.logOut),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void _clearAccountData(BuildContext context) {
  context.read<ProductBloc>().add(ClearProducts());
  context.read<ShopBloc>().add(ClearShopEvent());
  context.read<BillingBloc>().add(ClearCartEvent());
}
