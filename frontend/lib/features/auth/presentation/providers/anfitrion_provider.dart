import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../domain/entities/usuario.dart';

// Carga el perfil público de un anfitrión por su ID.
// Se usa en la página de detalle de alojamiento (HU-12).
// Errores se propagan al AsyncValue.error para que la UI los maneje.
final anfitrionProvider =
    FutureProvider.family<Usuario?, String>((ref, anfitrionId) async {
  if (anfitrionId.isEmpty) return null;
  return sl<AuthRemoteDatasource>().getUsuarioById(anfitrionId);
});
