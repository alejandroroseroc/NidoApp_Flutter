import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../alojamientos/domain/repositories/alojamiento_repository.dart';
import '../../domain/entities/reserva_invitado.dart';
import '../providers/mis_reservas_provider.dart';
import '../widgets/mi_reserva_card.dart';

class MisReservasPage extends ConsumerStatefulWidget {
  const MisReservasPage({super.key});

  @override
  ConsumerState<MisReservasPage> createState() => _MisReservasPageState();
}

class _MisReservasPageState extends ConsumerState<MisReservasPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(misReservasProvider.notifier).startPolling(),
    );
  }

  @override
  void dispose() {
    ref.read(misReservasProvider.notifier).stopPolling();
    super.dispose();
  }

  void _showCambioSnackBar(ReservaInvitado reserva) {
    final alojamiento = reserva.alojamientoTitulo;
    final isAceptada = reserva.estado == EstadoReservaInvitado.aceptada;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor:
            isAceptada ? const Color(0xFF2D7D6F) : const Color(0xFFD94444),
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            Icon(
              isAceptada ? Icons.check_circle : Icons.info_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isAceptada
                    ? '¡Tu reserva en $alojamiento fue aceptada!'
                    : 'Tu solicitud en $alojamiento no fue aceptada.',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<MisReservasState>(misReservasProvider, (previous, next) {
      if (next.reservasConCambio.isNotEmpty &&
          next.reservasConCambio != previous?.reservasConCambio) {
        for (final reserva in next.reservasConCambio) {
          _showCambioSnackBar(reserva);
        }
        ref.read(misReservasProvider.notifier).clearCambios();
      }

      if (next.errorMessage != null &&
          previous?.errorMessage != next.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(next.errorMessage!),
          ),
        );
      }
    });

    final state = ref.watch(misReservasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis reservas'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(misReservasProvider.notifier).loadReservas(),
          ),
        ],
      ),
      body: SafeArea(child: _buildBody(state)),
    );
  }

  Widget _buildBody(MisReservasState state) {
    if (state.isLoading && state.reservas.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.reservas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hotel_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Aún no tienes reservas',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(misReservasProvider.notifier).loadReservas(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: state.reservas.length,
        itemBuilder: (context, index) {
          final reserva = state.reservas[index];
          return MiReservaCard(
            reserva: reserva,
            onReviewPressed: () async {
              final created = await Navigator.of(context).pushNamed(
                '/crear-resena',
                arguments: reserva,
              );
              if (created == true && mounted) {
                ref.read(misReservasProvider.notifier).loadReservas();
              }
            },
            onViewReviewsPressed: () => _openAlojamientoReviews(reserva),
          );
        },
      ),
    );
  }

  Future<void> _openAlojamientoReviews(ReservaInvitado reserva) async {
    try {
      final alojamiento = await sl<AlojamientoRepository>().getById(
        reserva.alojamientoId,
      );
      if (!mounted) return;
      Navigator.of(context).pushNamed(
        '/detalle-alojamiento',
        arguments: alojamiento,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.error,
          content: Text('No se pudo abrir el alojamiento'),
        ),
      );
    }
  }
}
