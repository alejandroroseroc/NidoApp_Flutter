import 'package:image_picker/image_picker.dart';

import '../entities/alojamiento.dart';
import '../entities/filtros_alojamiento.dart';

abstract class AlojamientoRepository {
  Future<Alojamiento> createAlojamiento({
    required String titulo,
    required String descripcion,
    required TipoEspacio tipoEspacio,
    required TipoPrivacidad tipoPrivacidad,
    required String tipoAcceso,
    required double precioMensual,
    required String ubicacion,
    String? reglas,
    List<String> servicios,
    List<XFile> fotografias,
  });

  Future<List<Alojamiento>> getMisPublicaciones();

  Future<List<Alojamiento>> getAlojamientosDisponibles({
    FiltrosAlojamiento? filtros,
  });

  Future<Alojamiento> getById(String id);

  Future<Alojamiento> updateAlojamiento({
    required String id,
    required String titulo,
    required String descripcion,
    required TipoEspacio tipoEspacio,
    required TipoPrivacidad tipoPrivacidad,
    required String tipoAcceso,
    required double precioMensual,
    required String ubicacion,
    String? reglas,
    List<String> servicios,
    List<String> fotografiasExistentes,
    List<XFile> nuevasFotografias,
  });

  Future<Alojamiento> toggleEstado(String id);

  Future<void> deleteAlojamiento(String id);
}
