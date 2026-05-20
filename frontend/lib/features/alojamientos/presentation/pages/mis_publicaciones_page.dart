import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../../domain/entities/alojamiento.dart';
import '../providers/alojamiento_provider.dart';

class MisPublicacionesPage extends ConsumerStatefulWidget {
  const MisPublicacionesPage({super.key});

  @override
  ConsumerState<MisPublicacionesPage> createState() =>
      _MisPublicacionesPageState();
}

class _MisPublicacionesPageState extends ConsumerState<MisPublicacionesPage> {
  String _formatPrecio(double value) =>
      '\$${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(alojamientoProvider.notifier).loadMisPublicaciones(),
    );
  }

  Future<void> _reload() async {
    await ref.read(alojamientoProvider.notifier).loadMisPublicaciones();
  }

  Future<void> _confirmDelete(Alojamiento alojamiento) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar publicacion'),
            content: Text(
              '¿Deseas eliminar "${alojamiento.titulo}"? Esta accion no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await ref.read(alojamientoProvider.notifier).delete(alojamiento.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AlojamientoState>(alojamientoProvider, (previous, next) {
      final message = next.errorMessage ?? next.successMessage;
      if (message != null &&
          message != previous?.errorMessage &&
          message != previous?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor:
                next.errorMessage != null ? AppColors.error : AppColors.success,
            content: Text(message),
          ),
        );
      }
    });

    final state = ref.watch(alojamientoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis publicaciones'),
        actions: [
          IconButton(
            tooltip: 'Crear alojamiento',
            onPressed: () async {
              final created = await Navigator.of(
                context,
              ).pushNamed('/crear-alojamiento');
              if (created == true) _reload();
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child:
            state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.publicaciones.isEmpty
                ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 120),
                    Icon(
                      Icons.home_work_outlined,
                      size: 64,
                      color: AppColors.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Aun no tienes publicaciones',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.title,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crea tu primer alojamiento para empezar a recibir interesados.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: AppPrimaryButton(
                        text: 'Crear alojamiento',
                        onPressed: () async {
                          final created = await Navigator.of(
                            context,
                          ).pushNamed('/crear-alojamiento');
                          if (created == true) _reload();
                        },
                      ),
                    ),
                  ],
                )
                : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: state.publicaciones.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = state.publicaciones[index];
                    return _PublicacionCard(
                      alojamiento: item,
                      precioLabel: _formatPrecio(item.precioMensual),
                      onEdit: () async {
                        final updated = await Navigator.of(
                          context,
                        ).pushNamed('/editar-alojamiento', arguments: item.id);
                        if (updated == true) _reload();
                      },
                      onToggleEstado:
                          () => ref
                              .read(alojamientoProvider.notifier)
                              .toggleEstado(item.id),
                      onDelete: () => _confirmDelete(item),
                    );
                  },
                ),
      ),
    );
  }
}

class _PublicacionCard extends StatelessWidget {
  const _PublicacionCard({
    required this.alojamiento,
    required this.precioLabel,
    required this.onEdit,
    required this.onToggleEstado,
    required this.onDelete,
  });

  final Alojamiento alojamiento;
  final String precioLabel;
  final VoidCallback onEdit;
  final VoidCallback onToggleEstado;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final foto = alojamiento.fotoPrincipal;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (foto != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                '$kBaseUrl$foto',
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => Container(
                      height: 160,
                      color: AppColors.badgeBackground,
                      child: const Icon(Icons.image_not_supported_outlined),
                    ),
              ),
            ),
          if (foto != null) const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(alojamiento.titulo, style: AppTextStyles.title),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color:
                      alojamiento.isActivo
                          ? AppColors.successBackground
                          : AppColors.errorBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  alojamiento.isActivo ? 'Activo' : 'Inactivo',
                  style: AppTextStyles.small.copyWith(
                    color:
                        alojamiento.isActivo
                            ? AppColors.success
                            : AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            alojamiento.ubicacion,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            '$precioLabel / mes',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Editar'),
              ),
              TextButton.icon(
                onPressed: onToggleEstado,
                icon: Icon(
                  alojamiento.isActivo
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                ),
                label: Text(alojamiento.isActivo ? 'Desactivar' : 'Activar'),
              ),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Eliminar'),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
