import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/app_selection_group.dart';
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
  final _otraPreferenciaController = TextEditingController();
  final _imagePicker = ImagePicker();
  bool _filledForm = false;

  // Preferencias de convivencia
  bool? _tieneMascotas;
  bool? _esFumador;
  String? _nivelRuido;
  String? _genero;
  List<String> _otrasPreferencias = [];

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
    _otraPreferenciaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ProfileState>(profileProvider, (previous, next) {
      if (next.usuario != null && !_filledForm) {
        _nombreController.text = next.usuario!.nombre;
        _telefonoController.text = next.usuario!.telefono ?? '';
        _descripcionController.text = next.usuario!.descripcion ?? '';

        // Cargar preferencias
        _tieneMascotas = next.usuario!.tieneMascotas;
        _esFumador = next.usuario!.esFumador;
        _nivelRuido = next.usuario!.nivelRuido;
        _genero = next.usuario!.genero;
        _otrasPreferencias = List.from(next.usuario!.otrasPreferencias);

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
                        Text(
                          'Preferencias de convivencia',
                          style: AppTextStyles.subtitle,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cuentanos sobre tus habitos para ayudarte a encontrar el companero ideal.',
                          style: AppTextStyles.small,
                        ),
                        const SizedBox(height: 20),
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AppSelectionGroup<bool>(
                                label: '¿Tienes mascotas?',
                                selectedValue: _tieneMascotas,
                                options: const [
                                  AppSelectionOption(
                                    label: 'Si, tengo mascotas',
                                    value: true,
                                    icon: Icons.pets_outlined,
                                  ),
                                  AppSelectionOption(
                                    label: 'No tengo',
                                    value: false,
                                    icon: Icons.block_outlined,
                                  ),
                                ],
                                onSelected: (val) {
                                  setState(() => _tieneMascotas = val);
                                },
                              ),
                              const SizedBox(height: 24),
                              AppSelectionGroup<bool>(
                                label: '¿Eres fumador?',
                                selectedValue: _esFumador,
                                options: const [
                                  AppSelectionOption(
                                    label: 'Si, fumo',
                                    value: true,
                                    icon: Icons.smoking_rooms_outlined,
                                  ),
                                  AppSelectionOption(
                                    label: 'No fumo',
                                    value: false,
                                    icon: Icons.smoke_free_outlined,
                                  ),
                                ],
                                onSelected: (val) {
                                  setState(() => _esFumador = val);
                                },
                              ),
                              const SizedBox(height: 24),
                              AppSelectionGroup<String>(
                                label: 'Nivel de ruido',
                                selectedValue: _nivelRuido,
                                helperText:
                                    '¿Que tan ruidoso eres en el dia a dia?',
                                options: const [
                                  AppSelectionOption(
                                    label: 'Bajo',
                                    value: 'bajo',
                                    icon: Icons.volume_mute_outlined,
                                  ),
                                  AppSelectionOption(
                                    label: 'Medio',
                                    value: 'medio',
                                    icon: Icons.volume_down_outlined,
                                  ),
                                  AppSelectionOption(
                                    label: 'Alto',
                                    value: 'alto',
                                    icon: Icons.volume_up_outlined,
                                  ),
                                ],
                                onSelected: (val) {
                                  setState(() => _nivelRuido = val);
                                },
                              ),
                              const SizedBox(height: 24),
                              AppSelectionGroup<String>(
                                label: 'Genero',
                                selectedValue: _genero,
                                options: const [
                                  AppSelectionOption(
                                    label: 'Masculino',
                                    value: 'masculino',
                                  ),
                                  AppSelectionOption(
                                    label: 'Femenino',
                                    value: 'femenino',
                                  ),
                                  AppSelectionOption(
                                    label: 'Otro',
                                    value: 'otro',
                                  ),
                                  AppSelectionOption(
                                    label: 'Prefiero no decir',
                                    value: 'no_decir',
                                  ),
                                ],
                                onSelected: (val) {
                                  setState(() => _genero = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Otras preferencias',
                                style: AppTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Agrega cualquier otro detalle (ej. vegetariano, deportista, etc.)',
                                style: AppTextStyles.small,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppTextField(
                                      label: 'Nueva preferencia',
                                      controller: _otraPreferenciaController,
                                      hintText: 'Ej. Vegano',
                                      onFieldSubmitted: (_) => _addPreference(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton.filled(
                                    onPressed: _addPreference,
                                    icon: const Icon(Icons.add),
                                    style: IconButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_otrasPreferencias.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children:
                                      _otrasPreferencias.map((pref) {
                                        return Chip(
                                          label: Text(pref),
                                          deleteIcon: const Icon(
                                            Icons.close,
                                            size: 16,
                                          ),
                                          onDeleted:
                                              () => _removePreference(pref),
                                          backgroundColor:
                                              AppColors.badgeBackground,
                                          labelStyle:
                                              AppTextStyles.small.copyWith(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                          side: BorderSide.none,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        );
                                      }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
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
          tieneMascotas: _tieneMascotas,
          esFumador: _esFumador,
          nivelRuido: _nivelRuido,
          genero: _genero,
          otrasPreferencias: _otrasPreferencias,
        );
  }

  void _addPreference() {
    final text = _otraPreferenciaController.text.trim();
    if (text.isEmpty) return;
    if (_otrasPreferencias.contains(text)) {
      _otraPreferenciaController.clear();
      return;
    }
    setState(() {
      _otrasPreferencias.add(text);
      _otraPreferenciaController.clear();
    });
  }

  void _removePreference(String text) {
    setState(() {
      _otrasPreferencias.remove(text);
    });
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
