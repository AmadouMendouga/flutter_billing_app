import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/entities/app_user.dart';
import '../bloc/auth_bloc.dart';

const _resendCooldownSeconds = 60;
const _autoCheckInterval = Duration(seconds: 4);

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

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  Timer? _cooldownTimer;
  Timer? _autoCheckTimer;
  int _cooldownSeconds = 0;
  bool _isSending = false;
  bool _isChecking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _sendLink();
    _autoCheckTimer =
        Timer.periodic(_autoCheckInterval, (_) => _checkStatus(silent: true));
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _autoCheckTimer?.cancel();
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
    if (!mounted) return;
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
    if (!silent) {
      setState(() {
        _isChecking = true;
        _error = null;
      });
    }
    final authRepository = context.read<AuthBloc>().authRepository;
    final result = await authRepository.refreshEmailVerificationStatus();
    if (!mounted) return;
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
          context.read<AuthBloc>().add(AuthUserChanged(refreshedUser));
          return;
        }
        if (!silent) {
          setState(() {
            _isChecking = false;
            _error =
                "Pas encore vérifié — clique d'abord le lien reçu par email.";
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  const Icon(Icons.mark_email_unread,
                      size: 56, color: AppTheme.primaryColor),
                  const SizedBox(height: 12),
                  const Text(
                    'Vérifie ton email',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.user.email == null
                        ? 'On vient de t\'envoyer un lien de vérification.'
                        : 'On vient d\'envoyer un lien de vérification à ${widget.user.email}. Clique dessus, cet écran se débloque automatiquement.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 24),
                  if (_error != null) ...[
                    Text(_error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                  ],
                  PrimaryButton(
                    onPressed: _isChecking ? null : () => _checkStatus(),
                    isLoading: _isChecking,
                    icon: Icons.check_circle_outline,
                    label: 'J\'ai cliqué sur le lien',
                  ),
                  TextButton(
                    onPressed:
                        (_isSending || _cooldownSeconds > 0) ? null : _sendLink,
                    child: Text(
                      _cooldownSeconds > 0
                          ? 'Renvoyer l\'email (${_cooldownSeconds}s)'
                          : 'Renvoyer l\'email',
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        context.read<AuthBloc>().add(LogOutRequested()),
                    child: const Text('Se déconnecter'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
