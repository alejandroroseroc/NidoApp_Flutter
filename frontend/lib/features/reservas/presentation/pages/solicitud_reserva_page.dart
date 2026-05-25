import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
  final _duracionController = TextEditingController(text: '1');
  DateTime? _fechaIngreso;
  int _duracionDias = 1;

  static final _fmt = NumberFormat('#,##0', 'es_CO');

  @override
  void initState() {
    super.initState();
    _duracionController.addListener(_onDuracionChanged);
  }

  @override
  void dispose() {
    _duracionController.removeListener(_onDuracionChanged);
    _fechaController.dispose();
    _duracionController.dispose();
    super.dispose();
  }

  void _onDuracionChanged() {
    final dias = int.tryParse(_duracionController.text) ?? 0;
    if (dias != _duracionDias) {
      setState(() => _duracionDias = dias);
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _formatPrecio(double value) => '\$${_fmt.format(value)}';

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
    final precioNoche = widget.alojamiento.precioNoche;
    final precioTotal =
        _duracionDias > 0 ? precioNoche * _duracionDias : null;

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
                // Resumen del alojamiento
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
                        '${_formatPrecio(precioNoche)} / noche',
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
                      'El anfitrión revisará tu fecha de ingreso y número de noches antes de aceptar.',
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
                  label: 'Número de noches',
                  hintText: 'Ej: 5',
                  controller: _duracionController,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.timelapse_outlined),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    final duration = int.tryParse(value ?? '');
                    if (duration == null) return 'Ingresa el número de noches';
                    if (duration < 1 || duration > 365) {
                      return 'La duración debe estar entre 1 y 365 noches';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Calculadora de precio en tiempo real
                if (_duracionDias > 0 && precioTotal != null)
                  _ResumenPrecio(
                    precioNoche: precioNoche,
                    duracionDias: _duracionDias,
                    precioTotal: precioTotal,
                    formatPrecio: _formatPrecio,
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
          duracionDias: int.parse(_duracionController.text),
        );
  }
}

// Widget de resumen de precio que se actualiza en tiempo real.
class _ResumenPrecio extends StatelessWidget {
  const _ResumenPrecio({
    required this.precioNoche,
    required this.duracionDias,
    required this.precioTotal,
    required this.formatPrecio,
  });

  final double precioNoche;
  final int duracionDias;
  final double precioTotal;
  final String Function(double) formatPrecio;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2D7D6F)),
        ),
        child: Column(
          children: [
            _FilaPrecio(
              etiqueta: 'Precio por noche:',
              valor: formatPrecio(precioNoche),
            ),
            const SizedBox(height: 8),
            _FilaPrecio(
              etiqueta: 'Número de noches:',
              valor: '$duracionDias',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(color: Color(0xFF2D7D6F), height: 1),
            ),
            _FilaPrecio(
              etiqueta: 'Total estimado:',
              valor: formatPrecio(precioTotal),
              enNegrita: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilaPrecio extends StatelessWidget {
  const _FilaPrecio({
    required this.etiqueta,
    required this.valor,
    this.enNegrita = false,
  });

  final String etiqueta;
  final String valor;
  final bool enNegrita;

  @override
  Widget build(BuildContext context) {
    final estilo = TextStyle(
      color: const Color(0xFF2D7D6F),
      fontWeight: enNegrita ? FontWeight.w700 : FontWeight.w500,
      fontSize: enNegrita ? 15 : 14,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(etiqueta, style: estilo),
        Text(valor, style: estilo),
      ],
    );
  }
}
