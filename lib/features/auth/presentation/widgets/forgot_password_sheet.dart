import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/widgets/input_label.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/auth_bloc.dart';

/// Standalone "forgot password" flow. Calls [AuthRepository] directly
/// (via the already-public [AuthBloc.authRepository]) instead of going
/// through a Bloc event, so it never touches the auth state machine that
/// drives navigation in `_AuthGate`.
Future<void> showForgotPasswordSheet(BuildContext context,
    {String? initialEmail}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => _ForgotPasswordSheet(initialEmail: initialEmail),
  );
}

class _ForgotPasswordSheet extends StatefulWidget {
  final String? initialEmail;
  const _ForgotPasswordSheet({this.initialEmail});

  @override
  State<_ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<_ForgotPasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _emailController =
      TextEditingController(text: widget.initialEmail);
  bool _isLoading = false;
  bool _isSent = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final authRepository = context.read<AuthBloc>().authRepository;
    final result =
        await authRepository.sendPasswordResetEmail(_emailController.text);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _isLoading = false;
        _error = failure.message;
      }),
      (_) => setState(() {
        _isLoading = false;
        _isSent = true;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: _isSent ? _buildSentState() : _buildFormState(),
        ),
      ),
    );
  }

  Widget _buildFormState() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.lock_reset, size: 40, color: AppTheme.primaryColor),
          const SizedBox(height: 12),
          const Text(
            'Mot de passe oublié',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'On t\'envoie un lien pour le réinitialiser.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          const InputLabel(text: 'Email'),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(hintText: 'nara@example.com'),
            validator: AppValidators.email,
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 8),
          PrimaryButton(
            onPressed: _isLoading ? null : _submit,
            isLoading: _isLoading,
            label: 'Envoyer le lien',
          ),
        ],
      ),
    );
  }

  Widget _buildSentState() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.mark_email_read, size: 40, color: Colors.green),
        const SizedBox(height: 12),
        const Text(
          'Email envoyé',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Vérifie ta boîte de réception (${_emailController.text.trim()}) et suis le lien pour choisir un nouveau mot de passe.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[500]),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          onPressed: () => Navigator.of(context).pop(),
          label: 'Fermer',
        ),
      ],
    );
  }
}
