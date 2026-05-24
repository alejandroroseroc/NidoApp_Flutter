import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/auth_check_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/alojamientos/presentation/pages/crear_alojamiento_page.dart';
import 'features/alojamientos/presentation/pages/editar_alojamiento_page.dart';
import 'features/alojamientos/domain/entities/alojamiento.dart';
import 'features/alojamientos/presentation/pages/detalle_alojamiento_page.dart';
import 'features/alojamientos/presentation/pages/explorar_alojamientos_page.dart';
import 'features/alojamientos/presentation/pages/mis_publicaciones_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/reservas/presentation/pages/host_reservations_page.dart';
import 'features/reservas/presentation/pages/mis_reservas_page.dart';
import 'features/reservas/presentation/pages/solicitud_reserva_page.dart';
import 'features/style_guide/presentation/style_guide_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NidoApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routes: {
        '/style-guide': (_) => const StyleGuidePage(),
        '/register': (_) => RegisterPage(),
        '/login': (_) => const LoginPage(),
        '/forgot-password': (_) => ForgotPasswordPage(),
        '/home': (_) => const HomePage(),
        '/profile': (_) => const ProfilePage(),
        '/explorar': (_) => const ExplorarAlojamientosPage(),
        '/detalle-alojamiento': (context) {
          final alojamiento =
              ModalRoute.of(context)!.settings.arguments as Alojamiento;
          return DetalleAlojamientoPage(alojamiento: alojamiento);
        },
        '/solicitar-reserva': (context) {
          final alojamiento =
              ModalRoute.of(context)!.settings.arguments as Alojamiento;
          return SolicitudReservaPage(alojamiento: alojamiento);
        },
        '/mis-reservas': (_) => const MisReservasPage(),
        '/host/reservations': (_) => const HostReservationsPage(),
        '/mis-publicaciones': (_) => const MisPublicacionesPage(),
        '/crear-alojamiento': (_) => const CrearAlojamientoPage(),
        '/editar-alojamiento': (context) {
          final id = ModalRoute.of(context)!.settings.arguments as String;
          return EditarAlojamientoPage(alojamientoId: id);
        },
      },
      home: const AuthCheckPage(),
    );
  }
}
