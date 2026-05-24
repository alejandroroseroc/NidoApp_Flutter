import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/host_reservations_provider.dart';
import '../widgets/reservation_host_card.dart';

class HostReservationsPage extends ConsumerStatefulWidget {
  const HostReservationsPage({super.key});

  @override
  ConsumerState<HostReservationsPage> createState() =>
      _HostReservationsPageState();
}

class _HostReservationsPageState extends ConsumerState<HostReservationsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(hostReservationsProvider.notifier).loadReservations(),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<HostReservationsState>(hostReservationsProvider, (
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
    });

    final state = ref.watch(hostReservationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Solicitudes de reserva')),
      body: SafeArea(
        child: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(HostReservationsState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.reservations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 72,
                color: AppColors.primary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No tienes solicitudes de reserva aún',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(hostReservationsProvider.notifier).loadReservations(),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: state.reservations.length,
        itemBuilder: (context, index) {
          final reserva = state.reservations[index];
          final isProcessing = state.processingId == reserva.id;

          return ReservationHostCard(
            reserva: reserva,
            isProcessing: isProcessing,
            onAccept: () => ref
                .read(hostReservationsProvider.notifier)
                .updateStatus(reserva.id, 'ACEPTADA'),
            onReject: () => ref
                .read(hostReservationsProvider.notifier)
                .updateStatus(reserva.id, 'RECHAZADA'),
          );
        },
      ),
    );
  }
}
