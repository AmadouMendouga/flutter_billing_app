import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'config/routes/app_routes.dart';
import 'core/data/hive_database.dart';
import 'core/service_locator.dart' as di;
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/auth_page.dart';
import 'features/billing/presentation/bloc/billing_bloc.dart';
import 'features/product/presentation/bloc/product_bloc.dart';
import 'features/shop/domain/entities/shop.dart';
import 'features/shop/presentation/bloc/shop_bloc.dart';
import 'features/settings/presentation/bloc/printer_bloc.dart';
import 'features/settings/presentation/bloc/printer_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebase();
  await HiveDatabase.init();
  await di.init();
  runApp(const MyApp());
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
      child: const _AuthGate(),
    );
  }
}

/// The APK is bundled alongside the web build (see web/downloads/) so it's
/// reachable at this path on whatever domain hosts the web app.
const _androidApkPath = 'downloads/AmadShop.apk';

/// Shows the login/signup flow while unauthenticated, and the app's normal
/// routed screens once signed in. Each branch owns a complete, separate
/// MaterialApp rather than nesting a second Router inside a shared one, but
/// both share [_navigatorKey] so the periodic web download reminder can
/// show a dialog regardless of which branch is currently active.
/// Also keeps ProductBloc/ShopBloc in sync with the current account:
/// reloads their data on sign-in, and clears it on sign-out so the next
/// account never briefly sees the previous one's shop/products.
class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  Timer? _downloadReminderTimer;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _downloadReminderTimer = Timer.periodic(
        const Duration(minutes: 30),
        (_) => _showDownloadReminder(),
      );
    }
  }

  @override
  void dispose() {
    _downloadReminderTimer?.cancel();
    super.dispose();
  }

  void _showDownloadReminder() {
    final context = rootNavigatorKey.currentState?.overlay?.context;
    if (context == null) return;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Installe l\'application Android'),
        content: const Text(
          'Pour une meilleure expérience (scan plus rapide, hors ligne), '
          'installe l\'application Android au lieu d\'utiliser le site web.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Plus tard'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              launchUrl(Uri.base.resolve(_androidApkPath),
                  webOnlyWindowName: '_blank');
            },
            child: const Text('Télécharger'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.read<ProductBloc>().add(LoadProducts());
          context.read<ShopBloc>().add(LoadShopEvent());
          final shopName = state.pendingShopName;
          if (shopName != null && shopName.isNotEmpty) {
            context
                .read<ShopBloc>()
                .add(UpdateShopEvent(Shop(name: shopName)));
          }
        } else if (state is AuthUnauthenticated) {
          context.read<ProductBloc>().add(ClearProducts());
          context.read<ShopBloc>().add(ClearShopEvent());
        }
      },
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return MaterialApp.router(
            key: const ValueKey('authenticated'),
            title: 'Billing App',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            routerConfig: router,
          );
        }
        if (state is AuthUnauthenticated || state is AuthError) {
          return MaterialApp(
            key: const ValueKey('unauthenticated'),
            navigatorKey: rootNavigatorKey,
            title: 'Billing App',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            home: const AuthPage(),
          );
        }
        // AuthInitial / AuthLoading: still resolving whether a session is
        // already persisted — avoid flashing the login screen.
        return MaterialApp(
          key: const ValueKey('loading'),
          navigatorKey: rootNavigatorKey,
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
