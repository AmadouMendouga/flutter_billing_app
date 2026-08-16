import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'config/routes/app_routes.dart';
import 'core/data/hive_database.dart';
import 'core/service_locator.dart' as di;
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/widgets/auth_gate.dart';
import 'features/billing/presentation/bloc/billing_bloc.dart';
import 'features/product/presentation/bloc/product_bloc.dart';
import 'features/shop/presentation/bloc/shop_bloc.dart';
import 'features/settings/presentation/bloc/printer_bloc.dart';
import 'features/settings/presentation/bloc/printer_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await _initializeFirebase();
    await HiveDatabase.init();
    await di.init();
    runApp(const MyApp());
  } catch (_) {
    // Ensures the web loading spinner (which only clears on the
    // 'flutter-first-frame' event) never spins forever: a failed
    // startup still renders a frame, with a retry that re-runs main().
    runApp(const _StartupErrorApp());
  }
}

/// On Flutter web, the JS interop bridge that firebase_core relies on can
/// still be registering itself when Firebase.initializeApp() first runs,
/// causing a transient "Unable to establish connection on channel:
/// FirebaseCoreHostApi.initializeCore" PlatformException. This doesn't
/// happen on native platforms (no JS bridge involved), so retry only
/// covers that web-specific startup race.
Future<void> _initializeFirebase() async {
  for (var attempt = 1; attempt <= 3; attempt++) {
    try {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
      return;
    } catch (_) {
      if (attempt == 3) rethrow;
      await Future.delayed(Duration(milliseconds: 300 * attempt));
    }
  }
}

/// Shown instead of an infinite loading spinner if startup (Firebase/Hive/DI
/// init) fails. Lets the user retry without reloading the page.
class _StartupErrorApp extends StatelessWidget {
  const _StartupErrorApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  "Impossible de charger l'application.\nVérifiez votre connexion internet et réessayez.",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                _RetryButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  const _RetryButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: main,
      child: const Text('Réessayer'),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) =>
              di.sl<AuthBloc>()..add(AuthSubscriptionRequested()),
        ),
        BlocProvider<ProductBloc>(create: (context) => di.sl<ProductBloc>()),
        BlocProvider<ShopBloc>(create: (context) => di.sl<ShopBloc>()),
        BlocProvider<BillingBloc>(
            create: (context) =>
                BillingBloc(getProductByBarcodeUseCase: di.sl())),
        BlocProvider<PrinterBloc>(
            create: (context) => di.sl<PrinterBloc>()..add(InitPrinterEvent())),
      ],
      child: AuthGate(
        authenticatedAppBuilder: (_) => MaterialApp.router(
          title: 'Billing App',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          routerConfig: router,
        ),
      ),
    );
  }
}
