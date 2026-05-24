import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';
import '../../features/auth/domain/usecases/update_active_mode_usecase.dart';
import '../../features/auth/presentation/providers/active_mode_provider.dart';
import '../../features/auth/presentation/providers/forgot_password_provider.dart';
import '../../features/auth/presentation/providers/login_provider.dart';
import '../../features/auth/presentation/providers/register_provider.dart';
import '../../features/alojamientos/data/datasources/alojamiento_remote_datasource.dart';
import '../../features/alojamientos/data/repositories/alojamiento_repository_impl.dart';
import '../../features/alojamientos/domain/repositories/alojamiento_repository.dart';
import '../../features/reservas/data/datasources/reserva_remote_datasource.dart';
import '../../features/reservas/data/repositories/reserva_repository_impl.dart';
import '../../features/reservas/domain/repositories/reserva_repository.dart';
import '../../features/reservas/domain/usecases/get_guest_reservations_usecase.dart';
import '../../features/reservas/domain/usecases/get_host_reservations_usecase.dart';
import '../../features/reservas/domain/usecases/update_reservation_status_usecase.dart';
import '../constants/api_constants.dart';
import '../services/token_storage_service.dart';

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

  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  sl.registerLazySingleton<TokenStorageService>(
    () => TokenStorageService(sl()),
  );

  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(sl(), sl()),
  );
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  sl.registerFactory(() => RegisterUseCase(sl()));
  sl.registerFactory(() => RegisterNotifier(sl(), sl()));

  sl.registerFactory(() => LoginUseCase(sl()));
  sl.registerFactory(() => LoginNotifier(sl(), sl()));

  sl.registerFactory(() => ForgotPasswordUseCase(sl()));
  sl.registerFactory(() => ResetPasswordUseCase(sl()));
  sl.registerFactory(() => ForgotPasswordNotifier(sl(), sl()));

  sl.registerFactory(() => UpdateActiveModeUseCase(sl()));
  sl.registerFactory(() => ActiveModeNotifier(sl(), sl()));

  sl.registerLazySingleton<AlojamientoRemoteDatasource>(
    () => AlojamientoRemoteDatasourceImpl(sl(), sl()),
  );
  sl.registerLazySingleton<AlojamientoRepository>(
    () => AlojamientoRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<ReservaRemoteDatasource>(
    () => ReservaRemoteDatasourceImpl(sl(), sl()),
  );
  sl.registerLazySingleton<ReservaRepository>(
    () => ReservaRepositoryImpl(sl()),
  );
  sl.registerFactory(() => GetGuestReservationsUseCase(sl()));
  sl.registerFactory(() => GetHostReservationsUseCase(sl()));
  sl.registerFactory(() => UpdateReservationStatusUseCase(sl()));
}
