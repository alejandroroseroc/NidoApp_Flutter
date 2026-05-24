import 'package:flutter/material.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_badge.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../../../../shared/widgets/app_secondary_button.dart';
import '../../domain/entities/reserva.dart';

class ReservationHostCard extends StatelessWidget {
  const ReservationHostCard({
    super.key,
    required this.reserva,
    required this.isProcessing,
    required this.onAccept,
    required this.onReject,
  });

  final Reserva reserva;
  final bool isProcessing;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String? _imageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    return path.startsWith('http') ? path : '$kBaseUrl$path';
  }

  ({String label, Color bg, Color fg}) _estadoStyle(EstadoReserva estado) {
    switch (estado) {
      case EstadoReserva.aceptada:
        return (
          label: 'Aceptada',
          bg: AppColors.successBackground,
          fg: AppColors.primary,
        );
      case EstadoReserva.rechazada:
        return (
          label: 'Rechazada',
          bg: AppColors.errorBackground,
          fg: AppColors.error,
        );
      case EstadoReserva.pendiente:
        return (
          label: 'Pendiente',
          bg: const Color(0xFFFFF3E0),
          fg: const Color(0xFFE65100),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = _estadoStyle(reserva.estado);
    final fotoInvitado = _imageUrl(reserva.invitadoFoto);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.badgeBackground,
                  backgroundImage:
                      fotoInvitado != null ? NetworkImage(fotoInvitado) : null,
                  child: fotoInvitado == null
                      ? const Icon(
                          Icons.person_outline,
                          color: AppColors.primary,
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reserva.invitadoNombre,
                        style: AppTextStyles.subtitle,
                      ),
                      Text(
                        reserva.invitadoCorreo,
                        style: AppTextStyles.small,
                      ),
                    ],
                  ),
                ),
                AppBadge(
                  text: estado.label,
                  backgroundColor: estado.bg,
                  textColor: estado.fg,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.home_work_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reserva.alojamientoTitulo,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        reserva.alojamientoUbicacion,
                        style: AppTextStyles.small,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.event_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Ingreso: ${_formatDate(reserva.fechaIngreso)}',
                  style: AppTextStyles.small,
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.timelapse_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  reserva.duracionTexto,
                  style: AppTextStyles.small,
                ),
              ],
            ),
            if (reserva.esPendiente) ...[
              const SizedBox(height: 20),
              if (isProcessing)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    ),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        outlinedButtonTheme: OutlinedButtonThemeData(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error),
                            foregroundColor: AppColors.error,
                          ),
                        ),
                      ),
                      child: AppSecondaryButton(
                        text: 'Rechazar',
                        enabled: !isProcessing,
                        onPressed: onReject,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppPrimaryButton(
                      text: 'Aceptar',
                      enabled: !isProcessing,
                      onPressed: onAccept,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
