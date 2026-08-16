import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/email_delivery_hint.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/app_user.dart';
import '../bloc/auth_bloc.dart';

const _resendCooldownSeconds = 60;
const _autoCheckInterval = Duration(seconds: 4);
const _successAnimationDuration = Duration(milliseconds: 1200);
const _successHoldDuration = Duration(milliseconds: 500);

/// Gates access to the app until the signed-in user's email is verified.
/// Uses Firebase's native "click the link in your email" verification (no
/// backend required) — auto-polls so the app unlocks itself as soon as the
/// link is clicked, no manual "I've verified" step needed.
/// Shown by `_AuthGate` in main.dart whenever `AuthAuthenticated` carries a
/// user with `emailVerified == false`.
class EmailVerificationPage extends StatefulWidget {
  final AppUser user;
  const EmailVerificationPage({super.key, required this.user});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage>
    with SingleTickerProviderStateMixin {
  Timer? _cooldownTimer;
  Timer? _autoCheckTimer;
  late final AnimationController _successController;
  late final Animation<double> _ringOpacity;
  late final Animation<double> _checkScale;
  late final Animation<double> _messageOpacity;
  int _cooldownSeconds = 0;
  bool _isSending = false;
  bool _isChecking = false;
  bool _refreshInProgress = false;
  bool _verificationCompleted = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: _successAnimationDuration,
    );
    _ringOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1), weight: 58),
      TweenSequenceItem(tween: Tween(begin: 1, end: 0), weight: 42),
    ]).animate(_successController);
    _checkScale = CurvedAnimation(
      parent: _successController,
      curve: const Interval(0.35, 1, curve: Curves.elasticOut),
    );
    _messageOpacity = CurvedAnimation(
      parent: _successController,
      curve: const Interval(0.62, 1, curve: Curves.easeOut),
    );
    _sendLink();
    _autoCheckTimer = Timer.periodic(
      _autoCheckInterval,
      (_) => _checkStatus(silent: true),
    );
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _autoCheckTimer?.cancel();
    _successController.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _cooldownSeconds = _resendCooldownSeconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        setState(() => _cooldownSeconds = 0);
      } else {
        setState(() => _cooldownSeconds--);
      }
    });
  }

  Future<void> _sendLink() async {
    setState(() {
      _isSending = true;
      _error = null;
    });
    final authRepository = context.read<AuthBloc>().authRepository;
    final result = await authRepository.sendVerificationEmail();
    if (!mounted || _verificationCompleted) return;
    result.fold(
      (failure) => setState(() {
        _isSending = false;
        _error = failure.message;
      }),
      (_) {
        setState(() => _isSending = false);
        _startCooldown();
      },
    );
  }

  Future<void> _checkStatus({bool silent = false}) async {
    if (_verificationCompleted || _refreshInProgress) return;
    _refreshInProgress = true;
    if (!silent) {
      setState(() {
        _isChecking = true;
        _error = null;
      });
    }
    final authRepository = context.read<AuthBloc>().authRepository;
    final result = await authRepository.refreshEmailVerificationStatus();
    if (!mounted) return;
    _refreshInProgress = false;
    result.fold(
      (failure) {
        if (!silent) {
          setState(() {
            _isChecking = false;
            _error = failure.message;
          });
        }
      },
      (refreshedUser) {
        if (refreshedUser.emailVerified) {
          unawaited(_showVerificationSuccess(refreshedUser));
          return;
        }
        if (!silent) {
          setState(() {
            _isChecking = false;
            _error = AppLocalizations.of(context).notVerifiedYet;
          });
        }
      },
    );
  }

  Future<void> _showVerificationSuccess(AppUser refreshedUser) async {
    if (_verificationCompleted) return;
    _autoCheckTimer?.cancel();
    _cooldownTimer?.cancel();
    setState(() {
      _verificationCompleted = true;
      _isChecking = false;
      _isSending = false;
      _error = null;
    });

    await _successController.forward(from: 0);
    await Future<void>.delayed(_successHoldDuration);
    if (!mounted) return;
    context.read<AuthBloc>().add(AuthUserChanged(refreshedUser));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_verificationCompleted) ...[
                    SizedBox(
                      height: 132,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          FadeTransition(
                            opacity: _ringOpacity,
                            child: RotationTransition(
                              turns: _successController,
                              child: const SizedBox(
                                width: 104,
                                height: 104,
                                child: CircularProgressIndicator(
                                  value: 0.76,
                                  strokeWidth: 8,
                                  color: AppTheme.primaryColor,
                                  strokeCap: StrokeCap.round,
                                ),
                              ),
                            ),
                          ),
                          ScaleTransition(
                            scale: _checkScale,
                            child: Container(
                              width: 96,
                              height: 96,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 58,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FadeTransition(
                      opacity: _messageOpacity,
                      child: Column(
                        children: [
                          Text(
                            l10n.emailVerified,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.openingShop,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    const Icon(
                      Icons.mark_email_unread,
                      size: 56,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.verifyEmail,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.user.email == null
                          ? l10n.verificationLinkSent
                          : l10n.verificationLinkSentTo(widget.user.email!),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const EmailDeliveryHint(),
                    const SizedBox(height: 16),
                    if (_error != null) ...[
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 8),
                    ],
                    PrimaryButton(
                      onPressed: _isChecking ? null : () => _checkStatus(),
                      isLoading: _isChecking,
                      icon: Icons.check_circle_outline,
                      label: l10n.clickedVerificationLink,
                    ),
                    TextButton(
                      onPressed:
                          (_isSending || _cooldownSeconds > 0)
                              ? null
                              : _sendLink,
                      child: Text(
                        _cooldownSeconds > 0
                            ? l10n.resendEmailCountdown(_cooldownSeconds)
                            : l10n.resendEmail,
                      ),
                    ),
                    TextButton(
                      onPressed:
                          () => context.read<AuthBloc>().add(LogOutRequested()),
                      child: Text(l10n.logOut),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
