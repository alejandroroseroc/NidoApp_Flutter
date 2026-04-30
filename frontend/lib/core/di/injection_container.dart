import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/providers/register_provider.dart';
import '../constants/api_constants.dart';

final sl = GetIt.instance;

// Registra dependencias de autenticacion con ciclo de vida apropiado.
Future<void> setupDependencies() async {
  sl.registerLazySingleton<Dio>(
    () => Dio(
      BaseOptions(
        baseUrl: kBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
      ),
    ),
  );

  sl.registerLazySingleton<AuthRemoteDatasource>(() => AuthRemoteDatasourceImpl(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerFactory(() => RegisterUseCase(sl()));
  sl.registerFactory(() => RegisterNotifier(sl()));
}
