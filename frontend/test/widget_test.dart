import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nido_app/features/auth/domain/entities/usuario.dart';
import 'package:nido_app/features/home/presentation/pages/home_page.dart';

void main() {
  testWidgets('muestra contenido de invitado', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ActiveModeContent(modoActivo: ModoActivo.invitado),
        ),
      ),
    );

    expect(find.text('Modo invitado'), findsOneWidget);
    expect(find.textContaining('Busca habitaciones'), findsOneWidget);
  });

  testWidgets('muestra contenido de anfitrion', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ActiveModeContent(modoActivo: ModoActivo.anfitrion),
        ),
      ),
    );

    expect(find.text('Modo anfitrion'), findsOneWidget);
    expect(find.textContaining('Administra tus alojamientos'), findsOneWidget);
    expect(find.text('Crear alojamiento'), findsOneWidget);
    expect(find.text('Mis publicaciones'), findsOneWidget);
  });
}
