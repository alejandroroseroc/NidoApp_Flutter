import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_alert.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../alojamientos/domain/entities/alojamiento.dart';
import '../providers/solicitud_reserva_provider.dart';

class SolicitudReservaPage extends ConsumerStatefulWidget {
  const SolicitudReservaPage({super.key, required this.alojamiento});

  final Alojamiento alojamiento;

  @override
  ConsumerState<SolicitudReservaPage> createState() =>
      _SolicitudReservaPageState();
}

class _SolicitudReservaPageState extends ConsumerState<SolicitudReservaPage> {
  final _formKey = GlobalKey<FormState>();
  final _fechaController = TextEditingController();
  final _duracionController = TextEditingController(text: '30');
  DateTime? _fechaIngreso;
  DuracionUnidad _unidad = DuracionUnidad.dias;

  @override
  void dispose() {
    _fechaController.dispose();
    _duracionController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _formatPrecio(double value) =>
      '\$${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  @override
  Widget build(BuildContext context) {
    ref.listen<SolicitudReservaState>(solicitudReservaProvider, (
      previous,
      next,
    ) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text('Solicitud de reserva enviada'),
          ),
        );
        ref.read(solicitudReservaProvider.notifier).clearStatus();
        Navigator.of(context).pop();
      }
    });

    final state = ref.watch(solicitudReservaProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Solicitar reserva')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.alojamiento.titulo,
                        style: AppTextStyles.subtitle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.alojamiento.ubicacion,
                        style: AppTextStyles.small,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${_formatPrecio(widget.alojamiento.precioMensual)} / mes',
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const AppAlert(
                  title: 'Solicitud pendiente',
                  message:
                      'El anfitrion revisara tu fecha de ingreso y duracion antes de aceptar.',
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Fecha de ingreso',
                  controller: _fechaController,
                  readOnly: true,
                  prefixIcon: const Icon(Icons.event_outlined),
                  suffixIcon: const Icon(Icons.calendar_today_outlined),
                  onTap: _selectDate,
                  validator: (_) {
                    if (_fechaIngreso == null) {
                      return 'Selecciona la fecha de ingreso';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: _unidad == DuracionUnidad.dias
                      ? 'Duracion en dias'
                      : 'Duracion en meses',
                  controller: _duracionController,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.timelapse_outlined),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    final duration = int.tryParse(value ?? '');
                    if (duration == null) return 'Ingresa la duracion';
                    if (_unidad == DuracionUnidad.dias &&
                        (duration < 1 || duration > 730)) {
                      return 'La duracion debe estar entre 1 y 730 dias';
                    }
                    if (_unidad == DuracionUnidad.meses &&
                        (duration < 1 || duration > 24)) {
                      return 'La duracion debe estar entre 1 y 24 meses';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                SegmentedButton<DuracionUnidad>(
                  segments: const [
                    ButtonSegment<DuracionUnidad>(
                      value: DuracionUnidad.dias,
                      label: Text('Dias'),
                      icon: Icon(Icons.today_outlined),
                    ),
                    ButtonSegment<DuracionUnidad>(
                      value: DuracionUnidad.meses,
                      label: Text('Meses'),
                      icon: Icon(Icons.calendar_month_outlined),
                    ),
                  ],
                  selected: {_unidad},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _unidad = selection.first;
                      _duracionController.text =
                          _unidad == DuracionUnidad.dias ? '30' : '1';
                    });
                  },
                ),
                const SizedBox(height: 24),
                AppPrimaryButton(
                  text: 'Enviar solicitud',
                  isLoading: state.isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _fechaIngreso ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
    );

    if (selected == null) return;
    setState(() {
      _fechaIngreso = selected;
      _fechaController.text = _formatDate(selected);
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ref.read(solicitudReservaProvider.notifier).enviarSolicitud(
          alojamientoId: widget.alojamiento.id,
          fechaIngreso: _fechaIngreso!,
          duracionDias: _unidad == DuracionUnidad.dias
              ? int.parse(_duracionController.text)
              : null,
          duracionMeses: _unidad == DuracionUnidad.meses
              ? int.parse(_duracionController.text)
              : null,
        );
  }
}

enum DuracionUnidad { dias, meses }
