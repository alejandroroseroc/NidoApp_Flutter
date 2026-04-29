import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/app_alert.dart';
import '../../../shared/widgets/app_badge.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_primary_button.dart';
import '../../../shared/widgets/app_secondary_button.dart';
import '../../../shared/widgets/app_text_field.dart';

class StyleGuidePage extends StatelessWidget {
  const StyleGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guia de estilos')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('NidoApp', style: AppTextStyles.title),
            const SizedBox(height: 8),
            Text(
              'Sistema visual para alojamientos temporales en Colombia.',
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'NidoApp usa una interfaz clara, tranquila y cercana para ayudar a encontrar habitaciones y apartaestudios con confianza.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 6),
            Text(
              'Texto pequeno para ayudas, estados y detalles secundarios.',
              style: AppTextStyles.small,
            ),
            const SizedBox(height: 24),
            AppPrimaryButton(text: 'Buscar alojamiento', onPressed: () {}),
            const SizedBox(height: 12),
            AppSecondaryButton(
              text: 'Ver criterios de convivencia',
              onPressed: () {},
            ),
            const SizedBox(height: 24),
            const AppTextField(
              label: 'Barrio o ciudad',
              hintText: 'Ej. Chapinero, Bogota',
              prefixIcon: Icon(Icons.search),
            ),
            const SizedBox(height: 20),
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppBadge(text: 'Habitacion'),
                AppBadge(text: 'Apartaestudio'),
                AppBadge(text: 'Compartido'),
              ],
            ),
            const SizedBox(height: 20),
            const AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.home_outlined, color: AppColors.primary),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Habitacion amoblada en Medellin',
                          style: AppTextStyles.subtitle,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Espacio tranquilo, cerca al metro y con acuerdos claros de convivencia.',
                    style: AppTextStyles.body,
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      AppBadge(text: 'Habitacion'),
                      SizedBox(width: 8),
                      Text('\$850.000 / mes', style: AppTextStyles.small),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const AppAlert(
              title: 'Informacion',
              message:
                  'Revisa ubicacion, reglas y servicios antes de reservar.',
            ),
            const SizedBox(height: 12),
            const AppAlert(
              title: 'Solicitud enviada',
              message: 'El anfitrion recibio tu interes por este alojamiento.',
              variant: AppAlertVariant.success,
            ),
            const SizedBox(height: 12),
            const AppAlert(
              title: 'Falta informacion',
              message: 'Completa los campos obligatorios para continuar.',
              variant: AppAlertVariant.error,
            ),
          ],
        ),
      ),
    );
  }
}
