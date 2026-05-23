import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/alojamiento.dart';
import '../../domain/entities/filtros_alojamiento.dart';
import 'alojamiento_constants.dart';

/// Abre el Bottom Sheet de filtros y devuelve los filtros seleccionados,
/// o null si el usuario lo cierra sin aplicar.
Future<FiltrosAlojamiento?> showFiltrosBottomSheet(
  BuildContext context, {
  required FiltrosAlojamiento filtrosActuales,
}) {
  return showModalBottomSheet<FiltrosAlojamiento>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _FiltrosSheet(filtrosActuales: filtrosActuales),
  );
}

class _FiltrosSheet extends StatefulWidget {
  const _FiltrosSheet({required this.filtrosActuales});

  final FiltrosAlojamiento filtrosActuales;

  @override
  State<_FiltrosSheet> createState() => _FiltrosSheetState();
}

class _FiltrosSheetState extends State<_FiltrosSheet> {
  late TipoEspacio? _tipoEspacio;
  late TextEditingController _precioMinCtrl;
  late TextEditingController _precioMaxCtrl;
  late List<String> _servicios;
  late TextEditingController _ubicacionCtrl;

  @override
  void initState() {
    super.initState();
    final f = widget.filtrosActuales;
    _tipoEspacio  = f.tipoEspacio;
    _precioMinCtrl = TextEditingController(
      text: f.precioMin != null ? f.precioMin!.toStringAsFixed(0) : '',
    );
    _precioMaxCtrl = TextEditingController(
      text: f.precioMax != null ? f.precioMax!.toStringAsFixed(0) : '',
    );
    _servicios    = List.from(f.servicios);
    _ubicacionCtrl = TextEditingController(text: f.ubicacion);
  }

  @override
  void dispose() {
    _precioMinCtrl.dispose();
    _precioMaxCtrl.dispose();
    _ubicacionCtrl.dispose();
    super.dispose();
  }

  void _toggleServicio(String servicio) {
    setState(() {
      if (_servicios.contains(servicio)) {
        _servicios.remove(servicio);
      } else {
        _servicios.add(servicio);
      }
    });
  }

  void _aplicar() {
    final precioMin = double.tryParse(_precioMinCtrl.text.replaceAll('.', ''));
    final precioMax = double.tryParse(_precioMaxCtrl.text.replaceAll('.', ''));

    Navigator.of(context).pop(
      FiltrosAlojamiento(
        tipoEspacio: _tipoEspacio,
        precioMin: precioMin,
        precioMax: precioMax,
        servicios: List.from(_servicios),
        ubicacion: _ubicacionCtrl.text.trim(),
      ),
    );
  }

  void _limpiar() {
    setState(() {
      _tipoEspacio = null;
      _precioMinCtrl.clear();
      _precioMaxCtrl.clear();
      _servicios.clear();
      _ubicacionCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Título
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filtros', style: AppTextStyles.subtitle),
              TextButton(
                onPressed: _limpiar,
                child: Text(
                  'Limpiar todo',
                  style: AppTextStyles.body.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Tipo de espacio ─────────────────────────────────────
                  _SectionTitle(title: 'Tipo de espacio'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      _TipoChip(
                        label: 'Habitación',
                        icon: Icons.bed_outlined,
                        selected: _tipoEspacio == TipoEspacio.habitacion,
                        onTap: () => setState(() {
                          _tipoEspacio = _tipoEspacio == TipoEspacio.habitacion
                              ? null
                              : TipoEspacio.habitacion;
                        }),
                      ),
                      _TipoChip(
                        label: 'Apartaestudio',
                        icon: Icons.apartment_outlined,
                        selected: _tipoEspacio == TipoEspacio.apartaestudio,
                        onTap: () => setState(() {
                          _tipoEspacio =
                              _tipoEspacio == TipoEspacio.apartaestudio
                                  ? null
                                  : TipoEspacio.apartaestudio;
                        }),
                      ),
                      _TipoChip(
                        label: 'Compartido',
                        icon: Icons.people_outline,
                        selected: _tipoEspacio == TipoEspacio.compartido,
                        onTap: () => setState(() {
                          _tipoEspacio = _tipoEspacio == TipoEspacio.compartido
                              ? null
                              : TipoEspacio.compartido;
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Precio ───────────────────────────────────────────────
                  _SectionTitle(title: 'Precio mensual (COP)'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _PrecioField(
                          controller: _precioMinCtrl,
                          label: 'Mínimo',
                          hint: '300.000',
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('–', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PrecioField(
                          controller: _precioMaxCtrl,
                          label: 'Máximo',
                          hint: '2.000.000',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Ubicación ────────────────────────────────────────────
                  _SectionTitle(title: 'Ubicación'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _ubicacionCtrl,
                    decoration: InputDecoration(
                      hintText: 'Ej: Bogotá, Chapinero...',
                      hintStyle: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      prefixIcon: const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Servicios ────────────────────────────────────────────
                  _SectionTitle(title: 'Servicios incluidos'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: kServiciosDisponibles
                        .map(
                          (s) => _ServicioChip(
                            label: s,
                            selected: _servicios.contains(s),
                            onTap: () => _toggleServicio(s),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Botón aplicar ────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _aplicar,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Aplicar filtros',
                style: AppTextStyles.button.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Widgets internos ────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _TipoChip extends StatelessWidget {
  const _TipoChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.small.copyWith(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServicioChip extends StatelessWidget {
  const _ServicioChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.successBackground : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.success
                : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.check, size: 14, color: AppColors.success),
              ),
            Text(
              label,
              style: AppTextStyles.small.copyWith(
                color: selected ? AppColors.success : AppColors.textPrimary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrecioField extends StatelessWidget {
  const _PrecioField({
    required this.controller,
    required this.label,
    required this.hint,
  });

  final TextEditingController controller;
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: AppTextStyles.small,
        hintStyle: AppTextStyles.small,
        prefixText: '\$ ',
        prefixStyle: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }
}
