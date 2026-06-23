import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/inventory/data/datasources/product_local_ds.dart';
import '../../features/inventory/data/datasources/product_remote_ds.dart';
import '../../features/inventory/data/repositories/movement_repository_impl.dart';
import '../../features/inventory/data/repositories/product_repository_impl.dart';
import '../../features/inventory/domain/repositories/product_repository.dart';
import '../../features/inventory/domain/usecases/get_pending_sync_count_usecase.dart';
import '../../features/inventory/domain/usecases/get_products_usecase.dart';
import '../../features/inventory/domain/usecases/register_movement_usecase.dart';
import '../../features/inventory/domain/usecases/scan_product_usecase.dart';
import '../../features/inventory/domain/usecases/sync_pending_movements_usecase.dart';
import '../../features/reports/domain/usecases/get_inventory_report_usecase.dart';
import '../database/app_database.dart';
import '../network/dio_client.dart';
import '../network/interceptors/auth_interceptor.dart';
import '../network/interceptors/connectivity_interceptor.dart';
import '../network/interceptors/workspace_interceptor.dart';
import '../network/network_info.dart';

extension GetItInjectableX on GetIt {
  Future<GetIt> init() async {
    final preferences = await SharedPreferences.getInstance();

    registerLazySingleton<SharedPreferences>(() => preferences);
    registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(),
    );
    registerLazySingleton<Connectivity>(() => Connectivity());
    registerLazySingleton<NetworkInfo>(
      () => ConnectivityPlusNetworkInfo(get<Connectivity>()),
    );
    registerLazySingleton<Dio>(() {
      final dio = Dio();
      dio.interceptors.addAll([
        ConnectivityInterceptor(get<NetworkInfo>()),
        AuthInterceptor(get<FlutterSecureStorage>()),
        WorkspaceInterceptor(get<SharedPreferences>()),
      ]);
      return dio;
    });
    registerLazySingleton<DioClient>(() => DioClient(dio: get<Dio>()));
    registerLazySingleton<AppDatabase>(() => AppDatabase());
    registerLazySingleton<AuthRemoteDataSource>(
      () => DioAuthRemoteDataSource(get<DioClient>()),
    );
    registerLazySingleton<AuthLocalDataSource>(
      () => PreferencesAuthLocalDataSource(get<SharedPreferences>()),
    );
    registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: get<AuthRemoteDataSource>(),
        localDataSource: get<AuthLocalDataSource>(),
      ),
    );
    registerLazySingleton<ProductRemoteDataSource>(
      () => DioProductRemoteDataSource(get<DioClient>()),
    );
    registerLazySingleton<ProductLocalDataSource>(
      () => DriftProductLocalDataSource(get<AppDatabase>()),
    );
    registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(
        remote: get<ProductRemoteDataSource>(),
        local: get<ProductLocalDataSource>(),
        network: get<NetworkInfo>(),
      ),
    );
    registerLazySingleton<MovementRepository>(
      () => MovementRepositoryImpl(get<AppDatabase>()),
    );
    registerLazySingleton<GetProductsUseCase>(
      () => GetProductsUseCase(get<ProductRepository>()),
    );
    registerLazySingleton<RegisterMovementUseCase>(
      () => RegisterMovementUseCase(
        get<MovementRepository>(),
        get<ProductRepository>(),
      ),
    );
    registerLazySingleton<ScanProductUseCase>(
      () => ScanProductUseCase(get<ProductRepository>()),
    );
    registerLazySingleton<GetPendingSyncCountUseCase>(
      () => GetPendingSyncCountUseCase(get<MovementRepository>()),
    );
    registerLazySingleton<SyncPendingMovementsUseCase>(
      () => SyncPendingMovementsUseCase(get<MovementRepository>()),
    );
    registerLazySingleton<GetInventoryReportUseCase>(
      () => GetInventoryReportUseCase(get<ProductRepository>()),
    );

    return this;
  }
}
