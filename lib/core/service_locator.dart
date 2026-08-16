import 'package:get_it/get_it.dart';
import 'data/hive_database.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../features/product/domain/usecases/product_usecases.dart';
import '../../features/product/presentation/bloc/product_bloc.dart';
import '../../features/shop/data/repositories/shop_repository_impl.dart';
import '../../features/shop/domain/repositories/shop_repository.dart';
import '../../features/shop/domain/usecases/shop_usecases.dart';
import '../../features/shop/presentation/bloc/shop_bloc.dart';
import '../../features/settings/data/repositories/printer_repository_impl.dart';
import '../../features/settings/domain/repositories/printer_repository.dart';
import '../../features/settings/presentation/bloc/printer_bloc.dart';
import '../../features/settings/data/repositories/hive_app_preferences_repository.dart';
import '../../features/settings/domain/repositories/app_preferences_repository.dart';
import '../../features/settings/presentation/bloc/app_preferences_cubit.dart';
import 'services/scan_feedback_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton<AppPreferencesRepository>(
    () => HiveAppPreferencesRepository(box: HiveDatabase.settingsBox),
  );
  sl.registerLazySingleton(() => AppPreferencesCubit(repository: sl()));

  final scanFeedback = await ScanFeedbackService.create();
  sl.registerSingleton<ScanFeedback>(
    scanFeedback,
    dispose: (_) => scanFeedback.dispose(),
  );

  // Features - Auth
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl());

  // Features - Product
  // Bloc
  sl.registerFactory(
    () => ProductBloc(
      getProductsUseCase: sl(),
      addProductUseCase: sl(),
      updateProductUseCase: sl(),
      deleteProductUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => ShopBloc(getShopUseCase: sl(), updateShopUseCase: sl()),
  );

  sl.registerFactory(() => PrinterBloc(repository: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => AddProductUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProductUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProductUseCase(sl()));
  sl.registerLazySingleton(() => GetProductByBarcodeUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl());

  // Features - Shop
  // Use cases
  sl.registerLazySingleton(() => GetShopUseCase(sl()));
  sl.registerLazySingleton(() => UpdateShopUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ShopRepository>(() => ShopRepositoryImpl());

  // Features - Settings / Printer
  sl.registerLazySingleton<PrinterRepository>(() => PrinterRepositoryImpl());
}
