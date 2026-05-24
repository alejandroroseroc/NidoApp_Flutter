import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/resena_model.dart';
import '../providers/resenas_provider.dart';

class ResenasAlojamientoPage extends ConsumerStatefulWidget {
  const ResenasAlojamientoPage({
    super.key,
    required this.alojamientoId,
    required this.titulo,
  });

  final String alojamientoId;
  final String titulo;

  @override
  ConsumerState<ResenasAlojamientoPage> createState() =>
      _ResenasAlojamientoPageState();
}

class _ResenasAlojamientoPageState
    extends ConsumerState<ResenasAlojamientoPage> {
  int? _selectedStars;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(resenasProvider.notifier).load(widget.alojamientoId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resenasProvider);
    final counts = <int, int>{
      for (var stars = 5; stars >= 1; stars--)
        stars: state.resenas.where((r) => r.calificacion == stars).length,
    };
    final filtered = _selectedStars == null
        ? state.resenas
        : state.resenas
            .where((resena) => resena.calificacion == _selectedStars)
            .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Reseñas')),
      body: SafeArea(
        child: state.isLoading && state.resenas.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(widget.titulo, style: AppTextStyles.subtitle),
                  const SizedBox(height: 18),
                  _ReviewSummary(
                    promedio: state.resumen.promedio,
                    total: state.resumen.total,
                    counts: counts,
                  ),
                  const SizedBox(height: 20),
                  _StarFilters(
                    selectedStars: _selectedStars,
                    counts: counts,
                    onSelected: (stars) {
                      setState(() {
                        _selectedStars = _selectedStars == stars ? null : stars;
                      });
                    },
                  ),
                  const SizedBox(height: 22),
                  if (filtered.isEmpty)
                    Text(
                      _selectedStars == null
                          ? 'Este alojamiento aun no tiene reseñas.'
                          : 'No hay reseñas de $_selectedStars estrella${_selectedStars == 1 ? '' : 's'}.',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    )
                  else
                    ...filtered.map((resena) => _ReviewRow(resena: resena)),
                ],
              ),
      ),
    );
  }
}

class _ReviewSummary extends StatelessWidget {
  const _ReviewSummary({
    required this.promedio,
    required this.total,
    required this.counts,
  });

  final double promedio;
  final int total;
  final Map<int, int> counts;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 720;
        final score = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, color: AppColors.primary, size: 34),
            const SizedBox(width: 8),
            Text(
              total == 0
                  ? 'Sin reseñas'
                  : '${promedio.toStringAsFixed(1)} · $total reseñas',
              style: AppTextStyles.title,
            ),
          ],
        );

        final bars = Column(
          children: List.generate(5, (index) {
            final stars = 5 - index;
            final count = counts[stars] ?? 0;
            final ratio = total == 0 ? 0.0 : count / total;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  SizedBox(
                    width: 78,
                    child: Text('$stars estrellas', style: AppTextStyles.small),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 7,
                        value: ratio,
                        backgroundColor: AppColors.border,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 24,
                    child: Text('$count', style: AppTextStyles.small),
                  ),
                ],
              ),
            );
          }),
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 330, child: score),
              Expanded(child: bars),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [score, const SizedBox(height: 16), bars],
        );
      },
    );
  }
}

class _StarFilters extends StatelessWidget {
  const _StarFilters({
    required this.selectedStars,
    required this.counts,
    required this.onSelected,
  });

  final int? selectedStars;
  final Map<int, int> counts;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(5, (index) {
        final stars = 5 - index;
        final selected = selectedStars == stars;
        return ChoiceChip(
          selected: selected,
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$stars'),
              const SizedBox(width: 3),
              const Icon(Icons.star_rounded, size: 16),
              const SizedBox(width: 4),
              Text('(${counts[stars] ?? 0})'),
            ],
          ),
          selectedColor: AppColors.primary,
          backgroundColor: AppColors.surface,
          labelStyle: AppTextStyles.small.copyWith(
            color: selected ? AppColors.surface : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          side: const BorderSide(color: AppColors.border),
          onSelected: (_) => onSelected(stars),
        );
      }),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.resena});

  final Resena resena;

  @override
  Widget build(BuildContext context) {
    final foto = resena.autorFoto;
    final imageUrl = foto == null || foto.isEmpty
        ? null
        : foto.startsWith('http')
            ? foto
            : '$kBaseUrl$foto';

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.badgeBackground,
            backgroundImage: imageUrl == null ? null : NetworkImage(imageUrl),
            child: imageUrl == null
                ? const Icon(Icons.person_outline, color: AppColors.primary)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resena.autorNombre,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(
                    5,
                    (index) => Icon(
                      index < resena.calificacion
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  resena.comentario?.isNotEmpty == true
                      ? resena.comentario!
                      : 'El usuario dejo una calificacion sin comentario.',
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
