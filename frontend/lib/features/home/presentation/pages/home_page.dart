import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/token_storage_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/providers/active_mode_provider.dart';

// Pantalla principal — placeholder hasta implementar el home real.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<ActiveModeState>(activeModeProvider, (previous, next) {
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

    final activeModeState = ref.watch(activeModeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'NidoApp',
          style: AppTextStyles.title.copyWith(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await sl<TokenStorageService>().clearSession();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ModeSelector(
              selectedMode: activeModeState.modoActivo,
              isLoading: activeModeState.isLoading,
              onChanged: (modoActivo) {
                ref.read(activeModeProvider.notifier).changeMode(modoActivo);
              },
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ActiveModeContent(modoActivo: activeModeState.modoActivo),
            ),
          ],
        ),
      ),
    );
  }
}

class ModeSelector extends StatelessWidget {
  const ModeSelector({
    super.key,
    required this.selectedMode,
    required this.onChanged,
    this.isLoading = false,
  });

  final ModoActivo selectedMode;
  final ValueChanged<ModoActivo> onChanged;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ModoActivo>(
      segments: const [
        ButtonSegment<ModoActivo>(
          value: ModoActivo.invitado,
          label: Text('Invitado'),
          icon: Icon(Icons.search_outlined),
        ),
        ButtonSegment<ModoActivo>(
          value: ModoActivo.anfitrion,
          label: Text('Anfitrion'),
          icon: Icon(Icons.home_work_outlined),
        ),
      ],
      selected: {selectedMode},
      onSelectionChanged:
          isLoading
              ? null
              : (selection) {
                onChanged(selection.first);
              },
    );
  }
}

class ActiveModeContent extends StatelessWidget {
  const ActiveModeContent({super.key, required this.modoActivo});

  final ModoActivo modoActivo;

  @override
  Widget build(BuildContext context) {
    final isHost = modoActivo == ModoActivo.anfitrion;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isHost ? Icons.home_work_outlined : Icons.travel_explore_outlined,
            size: 72,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            isHost ? 'Modo anfitrion' : 'Modo invitado',
            style: AppTextStyles.title,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isHost
                ? 'Administra tus alojamientos y solicitudes desde una sola cuenta.'
                : 'Busca habitaciones y apartaestudios segun tus preferencias.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
