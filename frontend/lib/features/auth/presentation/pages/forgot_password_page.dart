import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../providers/forgot_password_provider.dart';

// Pantalla de recuperacion: primero pide el correo, luego el codigo + nueva contrasena.
class ForgotPasswordPage extends ConsumerWidget {
  ForgotPasswordPage({super.key});

  final _emailFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();
  final RegExp _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(forgotPasswordProvider);

    ref.listen<ForgotPasswordState>(forgotPasswordProvider, (previous, next) {
      if (next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(next.errorMessage!),
          ),
        );
      }

      if (next.resetExitoso && previous?.resetExitoso != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text('Contrasena actualizada. Inicia sesion.'),
          ),
        );
        ref.read(forgotPasswordProvider.notifier).reiniciar();
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child:
              state.codigoEnviado
                  ? _ResetForm(formKey: _resetFormKey, state: state)
                  : _EmailForm(formKey: _emailFormKey, emailRegex: _emailRegex),
        ),
      ),
    );
  }
}

// Paso 1: ingresar el correo para recibir el código.
class _EmailForm extends ConsumerWidget {
  const _EmailForm({required this.formKey, required this.emailRegex});

  final GlobalKey<FormState> formKey;
  final RegExp emailRegex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(forgotPasswordProvider);
    String correo = '';

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const Icon(Icons.lock_reset, size: 64, color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            'Olvidaste tu contrasena',
            style: AppTextStyles.title,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Ingresa tu correo y te enviaremos un codigo de 6 digitos.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          AppTextField(
            label: 'Correo electronico',
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) => correo = value.trim(),
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'El correo es obligatorio';
              if (!emailRegex.hasMatch(value.trim()))
                return 'Ingresa un correo valido';
              return null;
            },
          ),
          const SizedBox(height: 32),
          AppPrimaryButton(
            text: 'Enviar codigo',
            isLoading: state.isLoading,
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                ref.read(forgotPasswordProvider.notifier).enviarCodigo(correo);
              }
            },
          ),
        ],
      ),
    );
  }
}

// Paso 2: ingresar el código recibido y la nueva contraseña.
// Usa ConsumerStatefulWidget para manejar la visibilidad de las contrasenas.
class _ResetForm extends ConsumerStatefulWidget {
  const _ResetForm({required this.formKey, required this.state});

  final GlobalKey<FormState> formKey;
  final ForgotPasswordState state;

  @override
  ConsumerState<_ResetForm> createState() => _ResetFormState();
}

class _ResetFormState extends ConsumerState<_ResetForm> {
  final _codigoController = TextEditingController();
  final _nuevaContrasenaController = TextEditingController();
  final _confirmarContrasenaController = TextEditingController();

  bool _nuevaVisible = false;
  bool _confirmarVisible = false;

  @override
  void dispose() {
    _codigoController.dispose();
    _nuevaContrasenaController.dispose();
    _confirmarContrasenaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const Icon(Icons.mark_email_read, size: 64, color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            'Revisa tu correo',
            style: AppTextStyles.title,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Enviamos un codigo de 6 digitos a ${widget.state.correo}',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          AppTextField(
            label: 'Codigo de 6 digitos',
            controller: _codigoController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
            validator: (value) {
              if (value == null || value.trim().isEmpty)
                return 'El codigo es obligatorio';
              if (value.trim().length != 6)
                return 'El codigo debe tener 6 digitos';
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Nueva contrasena',
            controller: _nuevaContrasenaController,
            obscureText: !_nuevaVisible,
            suffixIcon: IconButton(
              icon: Icon(
                _nuevaVisible ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textSecondary,
              ),
              onPressed: () => setState(() => _nuevaVisible = !_nuevaVisible),
            ),
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'La contrasena es obligatoria';
              if (value.length < 8) return 'Minimo 8 caracteres';
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Confirmar contrasena',
            controller: _confirmarContrasenaController,
            obscureText: !_confirmarVisible,
            suffixIcon: IconButton(
              icon: Icon(
                _confirmarVisible ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textSecondary,
              ),
              onPressed:
                  () => setState(() => _confirmarVisible = !_confirmarVisible),
            ),
            validator: (value) {
              if (value == null || value.isEmpty)
                return 'Confirma tu contrasena';
              if (value != _nuevaContrasenaController.text) {
                return 'Las contrasenas no coinciden';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          AppPrimaryButton(
            text: 'Restablecer contrasena',
            isLoading: widget.state.isLoading,
            onPressed: () {
              if (widget.formKey.currentState?.validate() ?? false) {
                ref
                    .read(forgotPasswordProvider.notifier)
                    .resetearContrasena(
                      codigo: _codigoController.text.trim(),
                      nuevaContrasena: _nuevaContrasenaController.text,
                    );
              }
            },
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed:
                () => ref.read(forgotPasswordProvider.notifier).reiniciar(),
            child: Text(
              'Usar otro correo',
              style: AppTextStyles.body.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
