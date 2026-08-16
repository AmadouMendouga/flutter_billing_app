import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/widgets/google_sign_in_button.dart';
import '../../../../core/widgets/input_label.dart';
import '../../../../core/widgets/primary_button.dart';
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
          SignUpRequested(email, password, _shopNameController.text.trim()));
    } else {
      context.read<AuthBloc>().add(LogInRequested(email, password));
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        const Icon(Icons.storefront,
                            size: 56, color: AppTheme.primaryColor),
                        const SizedBox(height: 12),
                        Text(
                          _isSignUp ? 'Créer un compte' : 'Se connecter',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isSignUp
                              ? 'Crée le compte de ta boutique'
                              : 'Connecte-toi à ta boutique',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                        if (state is AuthError) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.red.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline,
                                    color: Colors.red, size: 20),
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
                          const InputLabel(text: 'Nom de la boutique'),
                          TextFormField(
                            controller: _shopNameController,
                            textCapitalization: TextCapitalization.words,
                            decoration:
                                const InputDecoration(hintText: 'Ma Boutique'),
                            validator: _isSignUp
                                ? AppValidators.required(
                                    'Nom de la boutique requis')
                                : null,
                          ),
                          const SizedBox(height: 15),
                        ],
                        const InputLabel(text: 'Email'),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(
                              hintText: 'nara@example.com'),
                          validator: AppValidators.email,
                        ),
                        const SizedBox(height: 15),
                        const InputLabel(text: 'Mot de passe'),
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
                              hintText: _isSignUp
                                  ? 'Maj, min, chiffre & symbole (6+)'
                                  : 'Min. 6 caractères',
                              suffixIcon: IconButton(
                                key: const ValueKey(
                                    'password-visibility-toggle'),
                                tooltip: _obscurePassword
                                    ? 'Afficher le mot de passe'
                                    : 'Masquer le mot de passe',
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              )),
                          validator: _isSignUp
                              ? AppValidators.signUpPassword
                              : AppValidators.password,
                        ),
                        if (!_isSignUp)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () => showForgotPasswordSheet(context,
                                      initialEmail: _emailController.text),
                              child: const Text('Mot de passe oublié ?'),
                            ),
                          ),
                        const SizedBox(height: 8),
                        PrimaryButton(
                          onPressed: isLoading ? null : _submit,
                          isLoading: isLoading,
                          icon: _isSignUp ? Icons.person_add : Icons.login,
                          label: _isSignUp ? 'Créer le compte' : 'Se connecter',
                        ),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text('ou',
                                  style: TextStyle(color: Colors.grey[500])),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GoogleSignInButton(
                          onPressed: isLoading
                              ? null
                              : () => context
                                  .read<AuthBloc>()
                                  .add(GoogleSignInRequested()),
                        ),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () => setState(() {
                                    _isSignUp = !_isSignUp;
                                    _obscurePassword = true;
                                  }),
                          child: Text(
                            _isSignUp
                                ? 'Tu as déjà un compte ? Se connecter'
                                : "Pas encore de compte ? En créer un",
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
