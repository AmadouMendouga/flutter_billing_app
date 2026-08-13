import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/widgets/input_label.dart';
import '../../../../core/widgets/primary_button.dart';
import '../bloc/auth_bloc.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text;
    final password = _passwordController.text;
    if (_isSignUp) {
      context.read<AuthBloc>().add(SignUpRequested(email, password));
    } else {
      context.read<AuthBloc>().add(LogInRequested(email, password));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message), backgroundColor: Colors.red));
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.storefront,
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
                      const SizedBox(height: 32),
                      const InputLabel(text: 'Email'),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        decoration:
                            const InputDecoration(hintText: 'toi@exemple.com'),
                        validator: AppValidators.email,
                      ),
                      const SizedBox(height: 15),
                      const InputLabel(text: 'Mot de passe'),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        autofillHints: const [AutofillHints.password],
                        decoration:
                            const InputDecoration(hintText: 'Min. 6 caractères'),
                        validator: AppValidators.password,
                      ),
                      const SizedBox(height: 8),
                      PrimaryButton(
                        onPressed: isLoading ? null : _submit,
                        isLoading: isLoading,
                        icon: _isSignUp ? Icons.person_add : Icons.login,
                        label: _isSignUp ? 'Créer le compte' : 'Se connecter',
                      ),
                      TextButton(
                        onPressed: isLoading
                            ? null
                            : () => setState(() => _isSignUp = !_isSignUp),
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
          );
        },
      ),
    );
  }
}
