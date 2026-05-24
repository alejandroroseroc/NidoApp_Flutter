import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/resena_model.dart';
import '../pages/resenas_alojamiento_page.dart';
import '../providers/resenas_provider.dart';

class ResenasSection extends ConsumerStatefulWidget {
  const ResenasSection({
    super.key,
    required this.alojamientoId,
    required this.titulo,
  });

  final String alojamientoId;
  final String titulo;

  @override
  ConsumerState<ResenasSection> createState() => _ResenasSectionState();
}

class _ResenasSectionState extends ConsumerState<ResenasSection> {
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

    if (state.isLoading && state.resenas.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.star_rounded, color: AppColors.primary, size: 26),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                state.resumen.total == 0
                    ? 'Sin reseñas todavía'
                    : '${state.resumen.promedio} · ${state.resumen.total} reseña${state.resumen.total == 1 ? '' : 's'}',
                style: AppTextStyles.subtitle,
              ),
            ),
            if (state.resenas.isNotEmpty)
              TextButton(
                onPressed: _openReviews,
                child: const Text('Ver todas'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (state.resenas.isEmpty)
          Text(
            'Cuando los invitados completen su estadia, sus opiniones apareceran aqui.',
            style: AppTextStyles.small,
          )
        else ...[
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: state.resenas.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _ResenaAirbnbCard(
                resena: state.resenas[index],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openReviews,
              icon: const Icon(Icons.filter_alt_outlined),
              label: const Text('Filtrar reseñas por estrellas'),
            ),
          ),
        ],
      ],
    );
  }

  void _openReviews() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ResenasAlojamientoPage(
          alojamientoId: widget.alojamientoId,
          titulo: widget.titulo,
        ),
      ),
    );
  }
}

class _ResenaAirbnbCard extends StatelessWidget {
  const _ResenaAirbnbCard({required this.resena});

  final Resena resena;

  @override
  Widget build(BuildContext context) {
    final foto = resena.autorFoto;
    final imageUrl = foto == null || foto.isEmpty
        ? null
        : foto.startsWith('http')
            ? foto
            : '$kBaseUrl$foto';

    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.badgeBackground,
                backgroundImage:
                    imageUrl == null ? null : NetworkImage(imageUrl),
                child: imageUrl == null
                    ? const Icon(Icons.person_outline, color: AppColors.primary)
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  resena.autorNombre,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
          const SizedBox(height: 10),
          Expanded(
            child: Text(
              resena.comentario?.isNotEmpty == true
                  ? resena.comentario!
                  : 'El usuario dejo una calificacion sin comentario.',
              style: AppTextStyles.small.copyWith(color: AppColors.textPrimary),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
