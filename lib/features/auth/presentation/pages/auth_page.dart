import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/google_sign_in_button.dart';
import '../../../../core/widgets/input_label.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/forgot_password_sheet.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _shopNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text;
    final password = _passwordController.text;
    if (_isSignUp) {
      context.read<AuthBloc>().add(
        SignUpRequested(email, password, _shopNameController.text.trim()),
      );
    } else {
      context.read<AuthBloc>().add(LogInRequested(email, password));
    }
  }

  String? _validateEmail(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) return l10n.emailRequired;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
      return l10n.emailInvalid;
    }
    return null;
  }

  String? _validatePassword(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) return l10n.passwordRequired;
    if (value.length < 6) return l10n.passwordMinLength;
    return null;
  }

  String? _validateSignUpPassword(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) return l10n.passwordRequired;
    final missing = <String>[];
    if (value.length < 6) missing.add(l10n.sixCharactersMinimum);
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      missing.add(l10n.oneLowercaseLetter);
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      missing.add(l10n.oneUppercaseLetter);
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) missing.add(l10n.oneNumber);
    if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(value)) {
      missing.add(l10n.oneSpecialCharacter);
    }
    if (missing.isEmpty) return null;
    return l10n.passwordMissingRequirements(missing.join(', '));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthSubmitting;
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.storefront,
                          size: 56,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isSignUp ? l10n.createAccount : l10n.signIn,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isSignUp
                              ? l10n.createShopAccountSubtitle
                              : l10n.signInShopSubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (state is AuthError) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    state.message,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),
                        if (_isSignUp) ...[
                          InputLabel(text: l10n.shopName),
                          TextFormField(
                            controller: _shopNameController,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              hintText: l10n.shopNameHint,
                            ),
                            validator:
                                _isSignUp
                                    ? (value) =>
                                        value == null || value.trim().isEmpty
                                            ? l10n.shopNameRequired
                                            : null
                                    : null,
                          ),
                          const SizedBox(height: 15),
                        ],
                        InputLabel(text: l10n.email),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: InputDecoration(
                            hintText: l10n.emailExample,
                          ),
                          validator: (value) => _validateEmail(value, l10n),
                        ),
                        const SizedBox(height: 15),
                        InputLabel(text: l10n.password),
                        TextFormField(
                          key: const ValueKey('password-field'),
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          autocorrect: false,
                          enableSuggestions: false,
                          autofillHints: [
                            _isSignUp
                                ? AutofillHints.newPassword
                                : AutofillHints.password,
                          ],
                          decoration: InputDecoration(
                            hintText:
                                _isSignUp
                                    ? l10n.newPasswordHint
                                    : l10n.passwordHint,
                            suffixIcon: IconButton(
                              key: const ValueKey('password-visibility-toggle'),
                              tooltip:
                                  _obscurePassword
                                      ? l10n.showPassword
                                      : l10n.hidePassword,
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed:
                                  () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                            ),
                          ),
                          validator:
                              _isSignUp
                                  ? (value) =>
                                      _validateSignUpPassword(value, l10n)
                                  : (value) => _validatePassword(value, l10n),
                        ),
                        if (!_isSignUp)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed:
                                  isLoading
                                      ? null
                                      : () => showForgotPasswordSheet(
                                        context,
                                        initialEmail: _emailController.text,
                                      ),
                              child: Text(l10n.forgotPasswordQuestion),
                            ),
                          ),
                        const SizedBox(height: 8),
                        PrimaryButton(
                          onPressed: isLoading ? null : _submit,
                          isLoading: isLoading,
                          icon: _isSignUp ? Icons.person_add : Icons.login,
                          label:
                              _isSignUp
                                  ? l10n.createAccountButton
                                  : l10n.signInButton,
                        ),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                l10n.or,
                                style: TextStyle(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GoogleSignInButton(
                          onPressed:
                              isLoading
                                  ? null
                                  : () => context.read<AuthBloc>().add(
                                    GoogleSignInRequested(),
                                  ),
                        ),
                        TextButton(
                          onPressed:
                              isLoading
                                  ? null
                                  : () => setState(() {
                                    _isSignUp = !_isSignUp;
                                    _obscurePassword = true;
                                  }),
                          child: Text(
                            _isSignUp
                                ? l10n.alreadyHaveAccount
                                : l10n.noAccountCreate,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
