import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_selection_group.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/entities/alojamiento.dart';
import 'alojamiento_constants.dart';
import 'ciudad_selector.dart';

class AlojamientoForm extends StatelessWidget {
  const AlojamientoForm({
    super.key,
    required this.formKey,
    required this.tituloController,
    required this.descripcionController,
    required this.reglasController,
    required this.precioController,
    // Ubicación estructurada: ciudad + barrio/dirección opcional
    required this.ciudad,
    required this.onCiudadChanged,
    required this.barrioController,
    this.ciudadError,
    required this.tipoEspacio,
    required this.tipoPrivacidad,
    required this.tipoAcceso,
    required this.serviciosSeleccionados,
    required this.fotosLocales,
    required this.fotosExistentes,
    required this.onTipoEspacioChanged,
    required this.onTipoPrivacidadChanged,
    required this.onTipoAccesoChanged,
    required this.onServicioToggled,
    required this.onPickImages,
    required this.onRemoveLocalPhoto,
    required this.onRemoveExistingPhoto,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController tituloController;
  final TextEditingController descripcionController;
  final TextEditingController reglasController;
  final TextEditingController precioController;
  final String? ciudad;
  final ValueChanged<String> onCiudadChanged;
  final TextEditingController barrioController;
  final String? ciudadError;
  final TipoEspacio? tipoEspacio;
  final TipoPrivacidad? tipoPrivacidad;
  final String? tipoAcceso;
  final Set<String> serviciosSeleccionados;
  final List<XFile> fotosLocales;
  final List<String> fotosExistentes;
  final ValueChanged<TipoEspacio> onTipoEspacioChanged;
  final ValueChanged<TipoPrivacidad> onTipoPrivacidadChanged;
  final ValueChanged<String> onTipoAccesoChanged;
  final ValueChanged<String> onServicioToggled;
  final VoidCallback onPickImages;
  final ValueChanged<int> onRemoveLocalPhoto;
  final ValueChanged<int> onRemoveExistingPhoto;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            label: 'Titulo',
            controller: tituloController,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El titulo es obligatorio';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Descripcion',
            controller: descripcionController,
            maxLines: 4,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'La descripcion es obligatoria';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppSelectionGroup<TipoEspacio>(
            label: 'Tipo de espacio',
            selectedValue: tipoEspacio,
            onSelected: onTipoEspacioChanged,
            options: const [
              AppSelectionOption(
                label: 'Habitacion',
                value: TipoEspacio.habitacion,
              ),
              AppSelectionOption(
                label: 'Apartaestudio',
                value: TipoEspacio.apartaestudio,
              ),
              AppSelectionOption(
                label: 'Compartido',
                value: TipoEspacio.compartido,
              ),
            ],
          ),
          if (tipoEspacio == null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Selecciona un tipo de espacio',
                style: AppTextStyles.small.copyWith(color: AppColors.error),
              ),
            ),
          const SizedBox(height: 16),
          AppSelectionGroup<TipoPrivacidad>(
            label: 'Tipo de privacidad',
            selectedValue: tipoPrivacidad,
            onSelected: onTipoPrivacidadChanged,
            options: const [
              AppSelectionOption(
                label: 'Privado',
                value: TipoPrivacidad.privado,
              ),
              AppSelectionOption(
                label: 'Compartido',
                value: TipoPrivacidad.compartido,
              ),
            ],
          ),
          if (tipoPrivacidad == null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Selecciona un tipo de privacidad',
                style: AppTextStyles.small.copyWith(color: AppColors.error),
              ),
            ),
          const SizedBox(height: 16),
          AppSelectionGroup<String>(
            label: 'Tipo de acceso',
            selectedValue: tipoAcceso,
            onSelected: onTipoAccesoChanged,
            options:
                kTiposAcceso
                    .map((tipo) => AppSelectionOption(label: tipo, value: tipo))
                    .toList(),
          ),
          if (tipoAcceso == null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Selecciona un tipo de acceso',
                style: AppTextStyles.small.copyWith(color: AppColors.error),
              ),
            ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Reglas',
            controller: reglasController,
            maxLines: 3,
            hintText: 'Opcional',
          ),
          const SizedBox(height: 16),
          Text(
            'Servicios disponibles',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                kServiciosDisponibles.map((servicio) {
                  final selected = serviciosSeleccionados.contains(servicio);
                  return FilterChip(
                    label: Text(servicio),
                    selected: selected,
                    onSelected: (_) => onServicioToggled(servicio),
                  );
                }).toList(),
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Precio mensual',
            controller: precioController,
            keyboardType: TextInputType.number,
            validator: (value) {
              final precio = double.tryParse(value ?? '');
              if (precio == null || precio <= 0) {
                return 'El precio debe ser mayor a 0';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // ── Ubicación estructurada ────────────────────────────────────
          CiudadSelector(
            initialValue: ciudad,
            onCiudadSelected: onCiudadChanged,
            errorText: ciudadError,
          ),
          const SizedBox(height: 12),
          AppTextField(
            label: 'Barrio / Dirección adicional',
            controller: barrioController,
            hintText: 'Ej: Chapinero, Calle 123 # 45-67 (opcional)',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Fotografias',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onPickImages,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Agregar'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (fotosExistentes.isEmpty && fotosLocales.isEmpty)
            Text(
              'Puedes agregar hasta 10 imagenes (JPG, PNG o WEBP).',
              style: AppTextStyles.small,
            ),
          if (fotosExistentes.isNotEmpty || fotosLocales.isNotEmpty)
            SizedBox(
              height: 110,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ...fotosExistentes.asMap().entries.map((entry) {
                    return _PhotoPreview(
                      image: NetworkImage('$kBaseUrl${entry.value}'),
                      onRemove: () => onRemoveExistingPhoto(entry.key),
                    );
                  }),
                  ...fotosLocales.asMap().entries.map((entry) {
                    return _PhotoPreview(
                      image: FileImage(File(entry.value.path)),
                      onRemove: () => onRemoveLocalPhoto(entry.key),
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  const _PhotoPreview({required this.image, required this.onRemove});

  final ImageProvider image;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image(
              image: image,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: InkWell(
              onTap: onRemove,
              child: const CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.error,
                child: Icon(Icons.close, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
