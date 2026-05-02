import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/providers/active_mode_provider.dart';
import '../providers/profile_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _imagePicker = ImagePicker();
  bool _filledForm = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(activeModeProvider.notifier).loadFromSession();
      ref.read(profileProvider.notifier).loadProfile();
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ProfileState>(profileProvider, (previous, next) {
      if (next.usuario != null && !_filledForm) {
        _nombreController.text = next.usuario!.nombre;
        _telefonoController.text = next.usuario!.telefono ?? '';
        _descripcionController.text = next.usuario!.descripcion ?? '';
        _filledForm = true;
      }

      final message = next.errorMessage ?? next.successMessage;
      if (message != null &&
          message != previous?.errorMessage &&
          message != previous?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor:
                next.errorMessage != null ? AppColors.error : AppColors.success,
            content: Text(message),
          ),
        );
      }
    });

    final state = ref.watch(profileProvider);
    final activeModeState = ref.watch(activeModeProvider);
    final usuario = state.usuario;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi perfil')),
      body: SafeArea(
        child:
            state.isLoading && usuario == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppCard(
                          child: Column(
                            children: [
                              ProfileAvatar(fotoPerfil: usuario?.fotoPerfil),
                              const SizedBox(height: 12),
                              Text(
                                usuario?.correo ?? 'Cuenta NidoApp',
                                style: AppTextStyles.small,
                              ),
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                onPressed: state.isSaving ? null : _pickImage,
                                icon: const Icon(Icons.photo_camera_outlined),
                                label: const Text('Actualizar foto'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Modo activo',
                                style: AppTextStyles.subtitle,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Alterna entre buscar alojamiento o gestionar tus espacios.',
                                style: AppTextStyles.small,
                              ),
                              const SizedBox(height: 16),
                              SegmentedButton<ModoActivo>(
                                segments: const [
                                  ButtonSegment<ModoActivo>(
                                    value: ModoActivo.invitado,
                                    label: Text('Invitado'),
                                    icon: Icon(Icons.search_outlined),
                                  ),
                                  ButtonSegment<ModoActivo>(
                                    value: ModoActivo.anfitrion,
                                    label: Text('Anfitrion'),
                                    icon: Icon(Icons.home_work_outlined),
                                  ),
                                ],
                                selected: {activeModeState.modoActivo},
                                onSelectionChanged:
                                    activeModeState.isLoading
                                        ? null
                                        : (selection) async {
                                          await ref
                                              .read(activeModeProvider.notifier)
                                              .changeMode(selection.first);
                                        },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        AppTextField(
                          label: 'Nombre',
                          controller: _nombreController,
                          prefixIcon: const Icon(Icons.person_outline),
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.length < 2) {
                              return 'El nombre debe tener minimo 2 caracteres';
                            }
                            if (text.length > 80) {
                              return 'El nombre debe tener maximo 80 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Telefono',
                          controller: _telefonoController,
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Icons.phone_outlined),
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) return null;
                            if (!RegExp(r'^\d{7,15}$').hasMatch(text)) {
                              return 'Debe tener entre 7 y 15 digitos';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Descripcion',
                          controller: _descripcionController,
                          prefixIcon: const Icon(Icons.notes_outlined),
                          maxLines: 4,
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.length > 300) {
                              return 'La descripcion debe tener maximo 300 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        AppPrimaryButton(
                          text: 'Guardar cambios',
                          isLoading: state.isSaving,
                          onPressed: _saveProfile,
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return;
    await ref.read(profileProvider.notifier).uploadPhoto(image);
  }

  void _saveProfile() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ref
        .read(profileProvider.notifier)
        .updateProfile(
          nombre: _nombreController.text.trim(),
          telefono: _telefonoController.text.trim(),
          descripcion: _descripcionController.text.trim(),
        );
  }
}

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, this.fotoPerfil});

  final String? fotoPerfil;

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        fotoPerfil == null || fotoPerfil!.isEmpty
            ? null
            : fotoPerfil!.startsWith('http')
            ? fotoPerfil
            : '$kBaseUrl$fotoPerfil';

    return CircleAvatar(
      radius: 48,
      backgroundColor: AppColors.badgeBackground,
      backgroundImage: imageUrl == null ? null : NetworkImage(imageUrl),
      child:
          imageUrl == null
              ? const Icon(
                Icons.person_outline,
                size: 48,
                color: AppColors.primary,
              )
              : null,
    );
  }
}
