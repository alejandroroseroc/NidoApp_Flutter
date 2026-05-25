import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../../../auth/domain/entities/usuario.dart';
import '../../../auth/presentation/providers/anfitrion_provider.dart';
import '../../../resenas/presentation/widgets/resenas_section.dart';
import '../../domain/entities/alojamiento.dart';

class DetalleAlojamientoPage extends ConsumerStatefulWidget {
  const DetalleAlojamientoPage({super.key, required this.alojamiento});

  final Alojamiento alojamiento;

  @override
  ConsumerState<DetalleAlojamientoPage> createState() =>
      _DetalleAlojamientoPageState();
}

class _DetalleAlojamientoPageState
    extends ConsumerState<DetalleAlojamientoPage> {
  int _currentPhotoIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

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

  String _labelPrivacidad(TipoPrivacidad privacidad) {
    switch (privacidad) {
      case TipoPrivacidad.privado:
        return 'Privado';
      case TipoPrivacidad.compartido:
        return 'Compartido';
    }
  }

  @override
  Widget build(BuildContext context) {
    final alojamiento = widget.alojamiento;
    final fotos = alojamiento.fotografias;
    final anfitrionAsync = ref.watch(anfitrionProvider(alojamiento.anfitrionId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar con galería ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.primary,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: fotos.isEmpty
                  ? _PlaceholderFoto()
                  : _GaleriaFotos(
                      fotos: fotos,
                      currentIndex: _currentPhotoIndex,
                      controller: _pageController,
                      onPageChanged: (i) =>
                          setState(() => _currentPhotoIndex = i),
                    ),
            ),
          ),

          // ── Contenido ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indicador de fotos si hay más de una
                  if (fotos.length > 1)
                    _PhotoIndicator(
                      total: fotos.length,
                      current: _currentPhotoIndex,
                    ),
                  if (fotos.length > 1) const SizedBox(height: 12),

                  // Tipo + badge
                  _TipoBadge(
                    label: _labelTipo(alojamiento.tipoEspacio),
                    icon: _iconTipo(alojamiento.tipoEspacio),
                  ),
                  const SizedBox(height: 10),

                  // Título
                  Text(alojamiento.titulo, style: AppTextStyles.title),
                  const SizedBox(height: 8),

                  // Ubicación
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          alojamiento.ubicacion,
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Precio destacado
                  _PrecioCard(
                    precio: _formatPrecio(alojamiento.precioNoche),
                  ),

                  const SizedBox(height: 24),
                  const _Divider(),

                  // Descripción
                  _Seccion(
                    titulo: 'Descripción',
                    icon: Icons.description_outlined,
                    child: Text(
                      alojamiento.descripcion,
                      style: AppTextStyles.body.copyWith(height: 1.6),
                    ),
                  ),

                  // Servicios
                  if (alojamiento.servicios.isNotEmpty) ...[
                    const _Divider(),
                    _Seccion(
                      titulo: 'Servicios incluidos',
                      icon: Icons.check_circle_outline,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: alojamiento.servicios
                            .map((s) => _ServicioChip(label: s))
                            .toList(),
                      ),
                    ),
                  ],

                  // Reglas
                  if (alojamiento.reglas != null &&
                      alojamiento.reglas!.isNotEmpty) ...[
                    const _Divider(),
                    _Seccion(
                      titulo: 'Reglas del alojamiento',
                      icon: Icons.rule_outlined,
                      child: Text(
                        alojamiento.reglas!,
                        style: AppTextStyles.body.copyWith(height: 1.6),
                      ),
                    ),
                  ],

                  // Privacidad y acceso
                  const _Divider(),
                  _Seccion(
                    titulo: 'Privacidad y acceso',
                    icon: Icons.lock_outline,
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.shield_outlined,
                          label: 'Tipo de privacidad',
                          valor: _labelPrivacidad(alojamiento.tipoPrivacidad),
                        ),
                        const SizedBox(height: 10),
                        _InfoRow(
                          icon: Icons.door_front_door_outlined,
                          label: 'Tipo de acceso',
                          valor: alojamiento.tipoAcceso,
                        ),
                      ],
                    ),
                  ),

                  // Perfil del anfitrión
                  const _Divider(),
                  _Seccion(
                    titulo: 'Anfitrión',
                    icon: Icons.person_outline,
                    child: anfitrionAsync.when(
                      loading: () => const _AnfitrionSkeleton(),
                      error: (_, __) => const _AnfitrionNoDisponible(),
                      data: (usuario) => usuario == null
                          ? const _AnfitrionNoDisponible()
                          : _AnfitrionCard(usuario: usuario),
                    ),
                  ),

                  const _Divider(),
                  _Seccion(
                    titulo: 'Reseñas',
                    icon: Icons.star_rounded,
                    child: ResenasSection(
                      alojamientoId: alojamiento.id,
                      titulo: alojamiento.titulo,
                    ),
                  ),

                  const SizedBox(height: 16),
                  AppPrimaryButton(
                    text: 'Solicitar reserva',
                    onPressed: () => Navigator.of(context).pushNamed(
                      '/solicitar-reserva',
                      arguments: alojamiento,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Galería de fotos ────────────────────────────────────────────────────────

class _GaleriaFotos extends StatelessWidget {
  const _GaleriaFotos({
    required this.fotos,
    required this.currentIndex,
    required this.controller,
    required this.onPageChanged,
  });

  final List<String> fotos;
  final int currentIndex;
  final PageController controller;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: controller,
      itemCount: fotos.length,
      onPageChanged: onPageChanged,
      itemBuilder: (context, index) {
        return Image.network(
          '$kBaseUrl${fotos[index]}',
          fit: BoxFit.cover,
          width: double.infinity,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: AppColors.badgeBackground,
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                ),
              ),
            );
          },
          errorBuilder: (_, __, ___) => Container(
            color: AppColors.badgeBackground,
            child: const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                size: 48,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PlaceholderFoto extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.badgeBackground,
      child: const Center(
        child: Icon(
          Icons.home_outlined,
          size: 72,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ─── Indicador de fotos ──────────────────────────────────────────────────────

class _PhotoIndicator extends StatelessWidget {
  const _PhotoIndicator({required this.total, required this.current});

  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        total,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: i == current ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: i == current ? AppColors.primary : AppColors.border,
          ),
        ),
      ),
    );
  }
}

// ─── Precio ─────────────────────────────────────────────────────────────────

class _PrecioCard extends StatelessWidget {
  const _PrecioCard({required this.precio});

  final String precio;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.successBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.payments_outlined, color: AppColors.success, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                precio,
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.success,
                  fontSize: 22,
                ),
              ),
              Text(
                'por noche',
                style: AppTextStyles.small.copyWith(color: AppColors.success),
              ),
              Text(
                'El total se calculará según los días de estadía',
                style: AppTextStyles.small.copyWith(
                  color: AppColors.success.withOpacity(0.8),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Sección genérica ────────────────────────────────────────────────────────

class _Seccion extends StatelessWidget {
  const _Seccion({
    required this.titulo,
    required this.icon,
    required this.child,
  });

  final String titulo;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(titulo, style: AppTextStyles.subtitle),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(color: AppColors.border, height: 1);
  }
}

// ─── Badge de tipo ───────────────────────────────────────────────────────────

class _TipoBadge extends StatelessWidget {
  const _TipoBadge({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.badgeBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
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

// ─── Chip de servicio ────────────────────────────────────────────────────────

class _ServicioChip extends StatelessWidget {
  const _ServicioChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.successBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, size: 14, color: AppColors.success),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.small.copyWith(color: AppColors.success),
          ),
        ],
      ),
    );
  }
}

// ─── Fila de info ────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.valor,
  });

  final IconData icon;
  final String label;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.badgeBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.small,
            ),
            Text(
              valor,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Card del anfitrión ──────────────────────────────────────────────────────

class _AnfitrionCard extends StatelessWidget {
  const _AnfitrionCard({required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          _Avatar(fotoPerfil: usuario.fotoPerfil, nombre: usuario.nombre),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  usuario.nombre,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (usuario.descripcion != null &&
                    usuario.descripcion!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    usuario.descripcion!,
                    style: AppTextStyles.small,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (usuario.telefono != null &&
                    usuario.telefono!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        usuario.telefono!,
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({this.fotoPerfil, required this.nombre});

  final String? fotoPerfil;
  final String nombre;

  @override
  Widget build(BuildContext context) {
    final initial = nombre.isNotEmpty ? nombre[0].toUpperCase() : '?';

    if (fotoPerfil != null && fotoPerfil!.isNotEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: AppColors.badgeBackground,
        backgroundImage: NetworkImage('$kBaseUrl$fotoPerfil'),
        onBackgroundImageError: (_, __) {},
        child: null,
      );
    }

    return CircleAvatar(
      radius: 28,
      backgroundColor: AppColors.primary.withOpacity(0.15),
      child: Text(
        initial,
        style: AppTextStyles.subtitle.copyWith(color: AppColors.primary),
      ),
    );
  }
}

class _AnfitrionSkeleton extends StatelessWidget {
  const _AnfitrionSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.border,
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 80,
              height: 11,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AnfitrionNoDisponible extends StatelessWidget {
  const _AnfitrionNoDisponible();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.badgeBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.person_off_outlined,
            color: AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            'Perfil del anfitrión no disponible',
            style: AppTextStyles.small,
          ),
        ],
      ),
    );
  }
}
