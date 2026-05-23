import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../../domain/entities/alojamiento.dart';
import '../providers/alojamiento_provider.dart';
import '../widgets/alojamiento_form.dart';

class CrearAlojamientoPage extends ConsumerStatefulWidget {
  const CrearAlojamientoPage({super.key});

  @override
  ConsumerState<CrearAlojamientoPage> createState() =>
      _CrearAlojamientoPageState();
}

class _CrearAlojamientoPageState extends ConsumerState<CrearAlojamientoPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _reglasController = TextEditingController();
  final _precioController = TextEditingController();
  final _barrioController = TextEditingController();
  final _imagePicker = ImagePicker();

  TipoEspacio? _tipoEspacio;
  TipoPrivacidad? _tipoPrivacidad;
  String? _tipoAcceso;
  String? _ciudad;
  String? _ciudadError;
  final Set<String> _servicios = {};
  final List<XFile> _fotos = [];

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _reglasController.dispose();
    _precioController.dispose();
    _barrioController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final images = await _imagePicker.pickMultiImage(imageQuality: 85);
    if (images.isEmpty) return;
    setState(() {
      _fotos.addAll(images.take(10 - _fotos.length));
    });
  }

  Future<void> _submit() async {
    // Validate ciudad
    if (_ciudad == null || _ciudad!.trim().isEmpty) {
      setState(() => _ciudadError = 'La ciudad es obligatoria');
      return;
    }

    if (_tipoEspacio == null ||
        _tipoPrivacidad == null ||
        _tipoAcceso == null) {
      setState(() {});
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final barrio = _barrioController.text.trim();
    final ubicacion = barrio.isNotEmpty ? '${_ciudad!}, $barrio' : _ciudad!;

    final success = await ref
        .read(alojamientoProvider.notifier)
        .create(
          titulo: _tituloController.text.trim(),
          descripcion: _descripcionController.text.trim(),
          tipoEspacio: _tipoEspacio!,
          tipoPrivacidad: _tipoPrivacidad!,
          tipoAcceso: _tipoAcceso!,
          precioMensual: double.parse(_precioController.text.trim()),
          ubicacion: ubicacion,
          reglas:
              _reglasController.text.trim().isEmpty
                  ? null
                  : _reglasController.text.trim(),
          servicios: _servicios.toList(),
          fotografias: _fotos,
        );

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AlojamientoState>(alojamientoProvider, (previous, next) {
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

    final state = ref.watch(alojamientoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Crear alojamiento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            AlojamientoForm(
              formKey: _formKey,
              tituloController: _tituloController,
              descripcionController: _descripcionController,
              reglasController: _reglasController,
              precioController: _precioController,
              ciudad: _ciudad,
              onCiudadChanged: (value) => setState(() {
                _ciudad = value.trim().isEmpty ? null : value;
                _ciudadError = null;
              }),
              barrioController: _barrioController,
              ciudadError: _ciudadError,
              tipoEspacio: _tipoEspacio,
              tipoPrivacidad: _tipoPrivacidad,
              tipoAcceso: _tipoAcceso,
              serviciosSeleccionados: _servicios,
              fotosLocales: _fotos,
              fotosExistentes: const [],
              onTipoEspacioChanged:
                  (value) => setState(() => _tipoEspacio = value),
              onTipoPrivacidadChanged:
                  (value) => setState(() => _tipoPrivacidad = value),
              onTipoAccesoChanged:
                  (value) => setState(() => _tipoAcceso = value),
              onServicioToggled: (servicio) {
                setState(() {
                  if (_servicios.contains(servicio)) {
                    _servicios.remove(servicio);
                  } else {
                    _servicios.add(servicio);
                  }
                });
              },
              onPickImages: _pickImages,
              onRemoveLocalPhoto: (index) {
                setState(() => _fotos.removeAt(index));
              },
              onRemoveExistingPhoto: (_) {},
            ),
            const SizedBox(height: 24),
            AppPrimaryButton(
              text: 'Publicar alojamiento',
              isLoading: state.isSaving,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
