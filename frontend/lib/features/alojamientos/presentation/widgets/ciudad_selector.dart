import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Ciudades principales de Colombia ordenadas alfabéticamente.
const List<String> kCiudadesColombia = [
  'Armenia',
  'Arauca',
  'Barranquilla',
  'Bogotá',
  'Bucaramanga',
  'Buenaventura',
  'Cali',
  'Cartagena',
  'Cúcuta',
  'Florencia',
  'Ibagué',
  'Inírida',
  'Leticia',
  'Manizales',
  'Medellín',
  'Mitú',
  'Mocoa',
  'Montería',
  'Neiva',
  'Pasto',
  'Pereira',
  'Popayán',
  'Puerto Carreño',
  'Quibdó',
  'Riohacha',
  'San Andrés',
  'Santa Marta',
  'Sincelejo',
  'Tunja',
  'Valledupar',
  'Villavicencio',
  'Yopal',
];

/// Selector autocompletado de ciudad con lista de ciudades colombianas.
/// Muestra sugerencias al escribir y resalta la ciudad seleccionada.
class CiudadSelector extends StatefulWidget {
  const CiudadSelector({
    super.key,
    required this.onCiudadSelected,
    this.initialValue,
    this.errorText,
  });

  /// Ciudad inicialmente seleccionada (para modo edición).
  final String? initialValue;

  /// Callback cuando el usuario selecciona o escribe una ciudad.
  final ValueChanged<String> onCiudadSelected;

  /// Texto de error a mostrar debajo del campo.
  final String? errorText;

  @override
  State<CiudadSelector> createState() => _CiudadSelectorState();
}

class _CiudadSelectorState extends State<CiudadSelector> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void didUpdateWidget(CiudadSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != null &&
        _controller.text.isEmpty) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ciudad',
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Autocomplete<String>(
          initialValue: TextEditingValue(text: widget.initialValue ?? ''),
          optionsBuilder: (textEditingValue) {
            final query = textEditingValue.text.toLowerCase().trim();
            if (query.isEmpty) return kCiudadesColombia;
            return kCiudadesColombia
                .where((c) => c.toLowerCase().contains(query))
                .toList();
          },
          onSelected: (ciudad) {
            widget.onCiudadSelected(ciudad);
          },
          fieldViewBuilder: (
            context,
            controller,
            focusNode,
            onFieldSubmitted,
          ) {
            return TextFormField(
              controller: controller,
              focusNode: focusNode,
              style: AppTextStyles.body,
              onChanged: (value) {
                // Notifica al padre aunque no haya seleccionado de la lista
                widget.onCiudadSelected(value.trim());
              },
              decoration: InputDecoration(
                hintText: 'Ej: Bogotá, Medellín...',
                hintStyle: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                prefixIcon: const Icon(
                  Icons.location_city_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            size: 18, color: AppColors.textSecondary),
                        onPressed: () {
                          controller.clear();
                          widget.onCiudadSelected('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                errorText: widget.errorText,
                errorStyle: AppTextStyles.error,
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
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                color: AppColors.surface,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final ciudad = options.elementAt(index);
                      return InkWell(
                        onTap: () => onSelected(ciudad),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(ciudad, style: AppTextStyles.body),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
