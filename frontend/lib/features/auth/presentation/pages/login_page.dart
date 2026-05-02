import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/login_provider.dart';

// Pantalla de inicio de sesion con validaciones y persistencia de token.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
  bool _contrasenaVisible = false;

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LoginState>(loginProvider, (previous, next) {
      if (next.errorMessage != null && previous?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(next.errorMessage!),
          ),
        );
      }

      if (next.isSuccess && previous?.isSuccess != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text('Bienvenido a NidoApp'),
          ),
        );
        ref.read(loginProvider.notifier).clearStatus();
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });

    final loginState = ref.watch(loginProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Text(
                  'Bienvenido',
                  style: AppTextStyles.title,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Inicia sesion en tu cuenta',
                  style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                AppTextField(
                  label: 'Correo electronico',
                  controller: _correoController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'El correo es obligatorio';
                    }
                    if (!_emailRegex.hasMatch(value.trim())) {
                      return 'Ingresa un correo valido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Contrasena',
                  controller: _contrasenaController,
                  obscureText: !_contrasenaVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _contrasenaVisible ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () =>
                        setState(() => _contrasenaVisible = !_contrasenaVisible),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La contrasena es obligatoria';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                AppPrimaryButton(
                  text: 'Iniciar sesion',
                  isLoading: loginState.isLoading,
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      ref.read(loginProvider.notifier).login(
                            correo: _correoController.text.trim(),
                            contrasena: _contrasenaController.text,
                          );
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pushNamed('/forgot-password'),
                  child: Text(
                    'Olvidaste tu contrasena',
                    style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pushNamed('/register'),
                  child: Text(
                    'No tienes cuenta? Registrate',
                    style: AppTextStyles.body.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
