import 'package:flutter/material.dart';

import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/reserva_invitado.dart';

class MiReservaCard extends StatelessWidget {
  const MiReservaCard({super.key, required this.reserva});

  final ReservaInvitado reserva;

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String? _imageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    return path.startsWith('http') ? path : '$kBaseUrl$path';
  }

  @override
  Widget build(BuildContext context) {
    final fotoUrl = _imageUrl(reserva.alojamientoFoto);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (fotoUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.network(
                fotoUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholderImage(),
              ),
            )
          else
            _placeholderImage(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reserva.alojamientoTitulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        reserva.alojamientoUbicacion,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(reserva.fechaIngreso),
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Duración: ${reserva.duracionDias} día${reserva.duracionDias == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                _EstadoBadge(estado: reserva.estado),
                if (reserva.estado == EstadoReservaInvitado.aceptada) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 16,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Anfitrión: ${reserva.anfitrionNombre}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  if (reserva.anfitrionTelefono != null &&
                      reserva.anfitrionTelefono!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.phone,
                          size: 16,
                          color: Colors.grey.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          reserva.anfitrionTelefono!,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ],
                const SizedBox(height: 10),
                Text(
                  'Solicitado el ${_formatDate(reserva.fechaSolicitud)}',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      height: 120,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.home_outlined, size: 48, color: Colors.grey),
      ),
    );
  }
}

class _EstadoBadge extends StatelessWidget {
  const _EstadoBadge({required this.estado});

  final EstadoReservaInvitado estado;

  @override
  Widget build(BuildContext context) {
    late Color bg;
    late Color fg;
    late String label;

    switch (estado) {
      case EstadoReservaInvitado.pendiente:
        bg = const Color(0xFFFFF3CD);
        fg = const Color(0xFF856404);
        label = 'En revisión ⏳';
      case EstadoReservaInvitado.aceptada:
        bg = const Color(0xFF2D7D6F);
        fg = Colors.white;
        label = 'Aceptada ✓';
      case EstadoReservaInvitado.rechazada:
        bg = const Color(0xFFD94444);
        fg = Colors.white;
        label = 'No aceptada ✗';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
