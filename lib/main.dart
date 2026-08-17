import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show debugPrint, debugPrintStack, kIsWeb;
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
import 'features/settings/domain/entities/app_preferences.dart';
import 'features/settings/presentation/bloc/app_preferences_cubit.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await _initializeFirebase();
    await _configureAuthPersistence();
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

Future<void> _configureAuthPersistence() async {
  if (!kIsWeb) return;
  try {
    await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
  } catch (error, stackTrace) {
    // Private browsing or blocked browser storage can make persistence
    // unavailable. The application must still be able to start and sign in.
    debugPrint('Unable to enable persistent authentication: $error');
    debugPrintStack(stackTrace: stackTrace);
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
        options: DefaultFirebaseOptions.currentPlatform,
      );
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const _StartupErrorScreen(),
    );
  }
}

class _StartupErrorScreen extends StatelessWidget {
  const _StartupErrorScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(l10n.startupLoadError, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              const _RetryButton(),
            ],
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
      child: Text(AppLocalizations.of(context).retry),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppPreferencesCubit>.value(value: di.sl()),
        BlocProvider<AuthBloc>(
          create:
              (context) => di.sl<AuthBloc>()..add(AuthSubscriptionRequested()),
        ),
        BlocProvider<ProductBloc>(create: (context) => di.sl<ProductBloc>()),
        BlocProvider<ShopBloc>(create: (context) => di.sl<ShopBloc>()),
        BlocProvider<BillingBloc>(
          create:
              (context) => BillingBloc(
                getProductByBarcodeUseCase: di.sl(),
                completeSaleUseCase: di.sl(),
              ),
        ),
        BlocProvider<PrinterBloc>(
          create: (context) => di.sl<PrinterBloc>()..add(InitPrinterEvent()),
        ),
      ],
      child: BlocBuilder<AppPreferencesCubit, AppPreferences>(
        builder: (context, preferences) {
          return MaterialApp.router(
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: preferences.themeMode,
            locale: preferences.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            debugShowCheckedModeBanner: false,
            routerConfig: router,
            builder:
                (context, child) => AuthGate(
                  authenticatedChild: child ?? const SizedBox.shrink(),
                  adminRepository: di.sl(),
                  shopRepository: di.sl(),
                ),
          );
        },
      ),
    );
  }
}
