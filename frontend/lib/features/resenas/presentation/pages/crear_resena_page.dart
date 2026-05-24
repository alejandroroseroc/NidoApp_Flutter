import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../reservas/domain/entities/reserva_invitado.dart';
import 'package:nido_app/features/resenas/presentation/providers/resenas_provider.dart';

class CrearResenaPage extends ConsumerStatefulWidget {
  const CrearResenaPage({super.key, required this.reserva});

  final ReservaInvitado reserva;

  @override
  ConsumerState<CrearResenaPage> createState() => _CrearResenaPageState();
}

class _CrearResenaPageState extends ConsumerState<CrearResenaPage> {
  final _comentarioController = TextEditingController();
  int _rating = 5;

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ResenasState>(resenasProvider, (previous, next) {
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
        ref.read(resenasProvider.notifier).clearStatus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text('Reseña publicada'),
          ),
        );
        Navigator.of(context).pop(true);
      }
    });

    final state = ref.watch(resenasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Dejar reseña')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.reserva.alojamientoTitulo, style: AppTextStyles.subtitle),
                  const SizedBox(height: 8),
                  Text(widget.reserva.alojamientoUbicacion, style: AppTextStyles.small),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('¿Como estuvo tu estadia?', style: AppTextStyles.title),
            const SizedBox(height: 8),
            Text(
              'Tu valoracion ayuda a otros invitados a decidir con confianza.',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final value = index + 1;
                return IconButton(
                  iconSize: 42,
                  onPressed: () => setState(() => _rating = value),
                  icon: Icon(
                    value <= _rating ? Icons.star_rounded : Icons.star_border_rounded,
                    color: AppColors.primary,
                  ),
                );
              }),
            ),
            Center(
              child: Text(
                '$_rating de 5',
                style: AppTextStyles.subtitle.copyWith(color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: 'Comentario',
              hintText: 'Cuenta que te gusto del alojamiento...',
              controller: _comentarioController,
              maxLines: 5,
              prefixIcon: const Icon(Icons.rate_review_outlined),
              validator: (value) {
                if ((value ?? '').trim().length > 500) {
                  return 'El comentario debe tener maximo 500 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            AppPrimaryButton(
              text: 'Publicar reseña',
              isLoading: state.isSaving,
              onPressed: () {
                ref.read(resenasProvider.notifier).create(
                      alojamientoId: widget.reserva.alojamientoId,
                      calificacion: _rating,
                      comentario: _comentarioController.text,
                    );
              },
            ),
          ],
        ),
      ),
    );
  }
}
