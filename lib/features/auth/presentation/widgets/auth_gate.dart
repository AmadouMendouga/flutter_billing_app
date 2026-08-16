import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../billing/presentation/bloc/billing_bloc.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../shop/domain/entities/shop.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../pages/auth_page.dart';
import '../pages/email_verification_page.dart';

/// Switches between authentication, email verification, and the signed-in
/// application while keeping account-scoped blocs synchronized.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.authenticatedChild});

  final Widget authenticatedChild;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated && state.user.emailVerified) {
          context.read<ProductBloc>().add(LoadProducts());
          context.read<ShopBloc>().add(LoadShopEvent());
          final shopName = state.pendingShopName;
          if (shopName != null && shopName.isNotEmpty) {
            context.read<ShopBloc>().add(UpdateShopEvent(Shop(name: shopName)));
          }
        } else if (state is AuthUnauthenticated) {
          context.read<ProductBloc>().add(ClearProducts());
          context.read<ShopBloc>().add(ClearShopEvent());
          context.read<BillingBloc>().add(ClearCartEvent());
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
          return KeyedSubtree(
            key: const ValueKey('authenticated-app'),
            child: authenticatedChild,
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
        // AuthInitial / AuthLoading: still resolving whether a session is
        // already persisted, so avoid flashing the login screen.
        return const KeyedSubtree(
          key: ValueKey('authentication-loading-app'),
          child: Scaffold(body: Center(child: CircularProgressIndicator())),
        );
      },
    );
  }
}
