import 'package:flutter/material.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/token_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import 'login_page.dart';

// Verifica si hay sesion activa al abrir la app.
// Si existe token, navega al home. Si no, muestra el login.
class AuthCheckPage extends StatefulWidget {
  const AuthCheckPage({super.key});

  @override
  State<AuthCheckPage> createState() => _AuthCheckPageState();
}

class _AuthCheckPageState extends State<AuthCheckPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final tokenStorage = sl<TokenStorageService>();
    final hasToken = await tokenStorage.hasToken();

    if (!mounted) return;

    if (hasToken) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}
