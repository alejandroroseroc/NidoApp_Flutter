import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/alojamiento.dart';
import '../../domain/entities/filtros_alojamiento.dart';
import '../providers/explorar_provider.dart';
import '../widgets/filtros_bottom_sheet.dart';
import 'detalle_alojamiento_page.dart';

class ExplorarAlojamientosPage extends ConsumerStatefulWidget {
  const ExplorarAlojamientosPage({super.key});

  @override
  ConsumerState<ExplorarAlojamientosPage> createState() =>
      _ExplorarAlojamientosPageState();
}

class _ExplorarAlojamientosPageState
    extends ConsumerState<ExplorarAlojamientosPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(explorarProvider.notifier).loadDisponibles(),
    );
  }

  Future<void> _reload() async {
    await ref.read(explorarProvider.notifier).loadDisponibles();
  }

  Future<void> _openFiltros() async {
    final filtrosActuales = ref.read(explorarProvider).filtros;
    final resultado = await showFiltrosBottomSheet(
      context,
      filtrosActuales: filtrosActuales,
    );
    if (resultado != null && mounted) {
      await ref.read(explorarProvider.notifier).applyFiltros(resultado);
    }
  }

  Future<void> _onTipoChipTap(TipoEspacio? tipo) async {
    final current = ref.read(explorarProvider).filtros;
    final nuevo = current.copyWith(
      tipoEspacio: tipo,
      clearTipo: tipo == null,
    );
    await ref.read(explorarProvider.notifier).applyFiltros(nuevo);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(explorarProvider);
    final filtros = state.filtros;
    final activeCount = filtros.activeCount;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Explorar alojamientos',
          style: AppTextStyles.subtitle.copyWith(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Badge con cantidad de filtros activos
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                tooltip: 'Filtros',
                icon: const Icon(Icons.tune_rounded, color: Colors.white),
                onPressed: _openFiltros,
              ),
              if (activeCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$activeCount',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Chips de tipo de espacio ──────────────────────────────────
          _TipoChipsRow(
            seleccionado: filtros.tipoEspacio,
            onSelected: _onTipoChipTap,
          ),

          // ── Chips de filtros activos (precio, ubicación, servicios) ───
          if (filtros.isActive)
            _FiltrosActivosBanner(
              filtros: filtros,
              onClear: () =>
                  ref.read(explorarProvider.notifier).clearFiltros(),
            ),

          // ── Lista de resultados ───────────────────────────────────────
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _reload,
              child: _buildBody(state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ExplorarState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (state.errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 100),
          const Icon(Icons.wifi_off_outlined,
              size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text('Algo salió mal',
              textAlign: TextAlign.center, style: AppTextStyles.subtitle),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              state.errorMessage!,
              textAlign: TextAlign.center,
              style:
                  AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: OutlinedButton.icon(
              onPressed: _reload,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ),
        ],
      );
    }

    if (state.disponibles.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 100),
          Icon(
            state.filtros.isActive
                ? Icons.filter_list_off
                : Icons.search_off_outlined,
            size: 64,
            color: AppColors.primary.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            state.filtros.isActive
                ? 'Sin resultados para estos filtros'
                : 'Sin alojamientos disponibles',
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle,
          ),
          const SizedBox(height: 8),
          Text(
            state.filtros.isActive
                ? 'Prueba ajustando o limpiando los filtros.'
                : 'Por el momento no hay publicaciones activas.',
            textAlign: TextAlign.center,
            style:
                AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          if (state.filtros.isActive) ...[
            const SizedBox(height: 20),
            Center(
              child: OutlinedButton.icon(
                onPressed: () =>
                    ref.read(explorarProvider.notifier).clearFiltros(),
                icon: const Icon(Icons.clear),
                label: const Text('Limpiar filtros'),
              ),
            ),
          ],
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: state.disponibles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final item = state.disponibles[index];
        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DetalleAlojamientoPage(alojamiento: item),
            ),
          ),
          child: _AlojamientoCard(alojamiento: item),
        );
      },
    );
  }
}

// ─── Chips de tipo de espacio ────────────────────────────────────────────────

class _TipoChipsRow extends StatelessWidget {
  const _TipoChipsRow({
    required this.seleccionado,
    required this.onSelected,
  });

  final TipoEspacio? seleccionado;
  final ValueChanged<TipoEspacio?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withOpacity(0.04),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _QuickChip(
              label: 'Todos',
              icon: Icons.apps_rounded,
              selected: seleccionado == null,
              onTap: () => onSelected(null),
            ),
            const SizedBox(width: 8),
            _QuickChip(
              label: 'Habitación',
              icon: Icons.bed_outlined,
              selected: seleccionado == TipoEspacio.habitacion,
              onTap: () => onSelected(TipoEspacio.habitacion),
            ),
            const SizedBox(width: 8),
            _QuickChip(
              label: 'Apartaestudio',
              icon: Icons.apartment_outlined,
              selected: seleccionado == TipoEspacio.apartaestudio,
              onTap: () => onSelected(TipoEspacio.apartaestudio),
            ),
            const SizedBox(width: 8),
            _QuickChip(
              label: 'Compartido',
              icon: Icons.people_outline,
              selected: seleccionado == TipoEspacio.compartido,
              onTap: () => onSelected(TipoEspacio.compartido),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 15,
                color: selected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTextStyles.small.copyWith(
                color: selected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Banner de filtros activos ───────────────────────────────────────────────

class _FiltrosActivosBanner extends StatelessWidget {
  const _FiltrosActivosBanner({
    required this.filtros,
    required this.onClear,
  });

  final FiltrosAlojamiento filtros;
  final VoidCallback onClear;

  String _formatPrecio(double v) =>
      '\$${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  List<String> _resumen() {
    final parts = <String>[];
    if (filtros.precioMin != null && filtros.precioMax != null) {
      parts.add(
          '${_formatPrecio(filtros.precioMin!)} – ${_formatPrecio(filtros.precioMax!)}');
    } else if (filtros.precioMin != null) {
      parts.add('Desde ${_formatPrecio(filtros.precioMin!)}');
    } else if (filtros.precioMax != null) {
      parts.add('Hasta ${_formatPrecio(filtros.precioMax!)}');
    }
    if (filtros.ubicacion.trim().isNotEmpty) parts.add(filtros.ubicacion.trim());
    if (filtros.servicios.isNotEmpty) {
      parts.add('${filtros.servicios.length} servicio(s)');
    }
    return parts;
  }

  @override
  Widget build(BuildContext context) {
    final resumen = _resumen();
    if (resumen.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.infoBackground,
      child: Row(
        children: [
          const Icon(Icons.filter_alt_outlined,
              size: 16, color: AppColors.secondary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              resumen.join(' · '),
              style: AppTextStyles.small.copyWith(color: AppColors.secondary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: onClear,
            child: const Icon(Icons.close, size: 16, color: AppColors.secondary),
          ),
        ],
      ),
    );
  }
}

// ─── Card de alojamiento ─────────────────────────────────────────────────────

class _AlojamientoCard extends StatelessWidget {
  const _AlojamientoCard({required this.alojamiento});

  final Alojamiento alojamiento;

  String _formatPrecio(double value) =>
      '\$${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';

  String _labelTipo(TipoEspacio tipo) {
    switch (tipo) {
      case TipoEspacio.habitacion:
        return 'Habitación';
      case TipoEspacio.apartaestudio:
        return 'Apartaestudio';
      case TipoEspacio.compartido:
        return 'Espacio compartido';
    }
  }

  IconData _iconTipo(TipoEspacio tipo) {
    switch (tipo) {
      case TipoEspacio.habitacion:
        return Icons.bed_outlined;
      case TipoEspacio.apartaestudio:
        return Icons.apartment_outlined;
      case TipoEspacio.compartido:
        return Icons.people_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final foto = alojamiento.fotoPrincipal;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FotoHeader(foto: foto),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TipoBadge(
                  label: _labelTipo(alojamiento.tipoEspacio),
                  icon: _iconTipo(alojamiento.tipoEspacio),
                ),
                const SizedBox(height: 8),
                Text(
                  alojamiento.titulo,
                  style: AppTextStyles.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 15, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        alojamiento.ubicacion,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(color: AppColors.border, height: 1),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatPrecio(alojamiento.precioNoche),
                          style: AppTextStyles.subtitle.copyWith(
                            color: AppColors.primary,
                            fontSize: 18,
                          ),
                        ),
                        Text('/ noche', style: AppTextStyles.small),
                      ],
                    ),
                    if (alojamiento.servicios.isNotEmpty)
                      _ServiciosPills(servicios: alojamiento.servicios),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FotoHeader extends StatelessWidget {
  const _FotoHeader({this.foto});
  final String? foto;

  @override
  Widget build(BuildContext context) {
    if (foto == null) {
      return Container(
        height: 180,
        color: AppColors.badgeBackground,
        child: const Center(
          child: Icon(Icons.home_outlined, size: 56, color: AppColors.textSecondary),
        ),
      );
    }
    return Image.network(
      '$kBaseUrl$foto',
      height: 200,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 200,
          color: AppColors.badgeBackground,
          child: const Center(
            child: CircularProgressIndicator(
                color: AppColors.primary, strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (_, __, ___) => Container(
        height: 200,
        color: AppColors.badgeBackground,
        child: const Center(
          child: Icon(Icons.image_not_supported_outlined,
              size: 40, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

class _TipoBadge extends StatelessWidget {
  const _TipoBadge({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.badgeBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.small.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiciosPills extends StatelessWidget {
  const _ServiciosPills({required this.servicios});
  final List<String> servicios;

  @override
  Widget build(BuildContext context) {
    final visibles = servicios.take(2).toList();
    final extra = servicios.length - visibles.length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...visibles.map(
          (s) => Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.successBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                s,
                style: AppTextStyles.small.copyWith(
                  color: AppColors.success,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ),
        if (extra > 0)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              '+$extra',
              style: AppTextStyles.small.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
