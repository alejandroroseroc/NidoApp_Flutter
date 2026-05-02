import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/register_provider.dart';

final _passwordVisibleProvider = StateProvider<bool>((ref) => false);
final _confirmPasswordVisibleProvider = StateProvider<bool>((ref) => false);
final _passwordProvider = StateProvider<String>((ref) => '');
final _confirmPasswordProvider = StateProvider<String>((ref) => '');
final _nameProvider = StateProvider<String>((ref) => '');
final _emailProvider = StateProvider<String>((ref) => '');
final _phoneProvider = StateProvider<String>((ref) => '');

// Pantalla de registro con validaciones y feedback de estado.
class RegisterPage extends ConsumerWidget {
  RegisterPage({super.key});

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final RegExp _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
  final RegExp _phoneRegex = RegExp(r'^\d{7,15}$');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<RegisterState>(registerProvider, (previous, next) {
      if (next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(next.errorMessage!),
          ),
        );
      }

      if (next.isSuccess && previous?.isSuccess != true) {
        ref.read(registerProvider.notifier).clearStatus();
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });

    final registerState = ref.watch(registerProvider);
    final isPasswordVisible = ref.watch(_passwordVisibleProvider);
    final isConfirmPasswordVisible = ref.watch(_confirmPasswordVisibleProvider);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Icon(
                    Icons.home_rounded,
                    size: 48,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Crear cuenta', style: AppTextStyles.subtitle),
                const SizedBox(height: 8),
                const Text(
                  'Unete a NidoApp y encuentra tu alojamiento ideal',
                  style: AppTextStyles.small,
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'Nombre completo',
                  prefixIcon: const Icon(Icons.person_outline),
                  onChanged:
                      (value) =>
                          ref.read(_nameProvider.notifier).state = value.trim(),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return 'El nombre es obligatorio';
                    if (text.length < 2) {
                      return 'Debe tener minimo 2 caracteres';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Correo electronico',
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  onChanged:
                      (value) =>
                          ref.read(_emailProvider.notifier).state =
                              value.trim(),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return 'El correo es obligatorio';
                    if (!_emailRegex.hasMatch(text)) {
                      return 'Ingresa un correo valido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Contrasena',
                  prefixIcon: const Icon(Icons.lock_outline),
                  obscureText: !isPasswordVisible,
                  suffixIcon: IconButton(
                    onPressed: () {
                      ref.read(_passwordVisibleProvider.notifier).state =
                          !isPasswordVisible;
                    },
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                  validator: (value) {
                    final text = value ?? '';
                    if (text.isEmpty) return 'La contrasena es obligatoria';
                    if (text.length < 8) {
                      return 'Debe tener minimo 8 caracteres';
                    }
                    return null;
                  },
                  onChanged:
                      (value) =>
                          ref.read(_passwordProvider.notifier).state = value,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Confirmar contrasena',
                  prefixIcon: const Icon(Icons.lock_outline),
                  obscureText: !isConfirmPasswordVisible,
                  suffixIcon: IconButton(
                    onPressed: () {
                      ref.read(_confirmPasswordVisibleProvider.notifier).state =
                          !isConfirmPasswordVisible;
                    },
                    icon: Icon(
                      isConfirmPasswordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                  validator: (value) {
                    final text = value ?? '';
                    if (text.isEmpty) return 'Confirma tu contrasena';
                    if (text != ref.read(_passwordProvider)) {
                      return 'Las contrasenas no coinciden';
                    }
                    return null;
                  },
                  onChanged:
                      (value) =>
                          ref.read(_confirmPasswordProvider.notifier).state =
                              value,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Telefono',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  keyboardType: TextInputType.phone,
                  onChanged:
                      (value) =>
                          ref.read(_phoneProvider.notifier).state =
                              value.trim(),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) return 'El telefono es obligatorio';
                    if (!_phoneRegex.hasMatch(text)) {
                      return 'Debe tener entre 7 y 15 digitos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                AppPrimaryButton(
                  text: 'Registrarme',
                  isLoading: registerState.isLoading,
                  onPressed: () {
                    final formState = _formKey.currentState;
                    if (formState == null || !formState.validate()) return;

                    final nombre = ref.read(_nameProvider);
                    final correo = ref.read(_emailProvider);
                    final contrasena = ref.read(_passwordProvider);
                    final telefono = ref.read(_phoneProvider);

                    ref
                        .read(registerProvider.notifier)
                        .register(
                          nombre: nombre,
                          correo: correo,
                          contrasena: contrasena,
                          telefono: telefono,
                        );
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/login'),
                    child: const Text('Ya tienes cuenta? Inicia sesion'),
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
