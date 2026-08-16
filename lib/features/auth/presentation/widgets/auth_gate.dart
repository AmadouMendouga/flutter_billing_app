import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../shop/domain/entities/shop.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../pages/auth_page.dart';
import '../pages/email_verification_page.dart';

/// Switches between authentication, email verification, and the signed-in
/// application while keeping account-scoped blocs synchronized.
class AuthGate extends StatelessWidget {
  const AuthGate({
    super.key,
    required this.authenticatedAppBuilder,
  });

  final WidgetBuilder authenticatedAppBuilder;

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
        }
      },
      builder: (context, state) {
        if (state is AuthAuthenticated && !state.user.emailVerified) {
          return MaterialApp(
            key: const ValueKey('email-verification-app'),
            title: 'Billing App',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            home: EmailVerificationPage(user: state.user),
          );
        }
        if (state is AuthAuthenticated) {
          return KeyedSubtree(
            key: const ValueKey('authenticated-app'),
            child: authenticatedAppBuilder(context),
          );
        }
        if (state is AuthUnauthenticated ||
            state is AuthSubmitting ||
            state is AuthError) {
          return MaterialApp(
            key: const ValueKey('authentication-app'),
            title: 'Billing App',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            home: const AuthPage(),
          );
        }
        // AuthInitial / AuthLoading: still resolving whether a session is
        // already persisted, so avoid flashing the login screen.
        return MaterialApp(
          key: const ValueKey('authentication-loading-app'),
          title: 'Billing App',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          home: const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }
}
