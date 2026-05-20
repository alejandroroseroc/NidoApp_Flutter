import 'package:image_picker/image_picker.dart';

import '../../domain/entities/alojamiento.dart';
import '../../domain/repositories/alojamiento_repository.dart';
import '../datasources/alojamiento_remote_datasource.dart';
import '../models/alojamiento_model.dart';

class AlojamientoRepositoryImpl implements AlojamientoRepository {
  const AlojamientoRepositoryImpl(this.remoteDatasource);

  final AlojamientoRemoteDatasource remoteDatasource;

  @override
  Future<Alojamiento> createAlojamiento({
    required String titulo,
    required String descripcion,
    required TipoEspacio tipoEspacio,
    required TipoPrivacidad tipoPrivacidad,
    required String tipoAcceso,
    required double precioMensual,
    required String ubicacion,
    String? reglas,
    List<String> servicios = const [],
    List<XFile> fotografias = const [],
  }) {
    return remoteDatasource.create(
      data: {
        'titulo': titulo,
        'descripcion': descripcion,
        'tipoEspacio': AlojamientoModel.tipoEspacioToApi(tipoEspacio),
        'tipoPrivacidad': AlojamientoModel.tipoPrivacidadToApi(tipoPrivacidad),
        'tipoAcceso': tipoAcceso,
        'reglas': reglas,
        'precioMensual': precioMensual,
        'ubicacion': ubicacion,
        'servicios': servicios,
      },
      fotografias: fotografias,
    );
  }

  @override
  Future<List<Alojamiento>> getMisPublicaciones() {
    return remoteDatasource.getMisPublicaciones();
  }

  @override
  Future<Alojamiento> getById(String id) {
    return remoteDatasource.getById(id);
  }

  @override
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
    List<String> servicios = const [],
    List<String> fotografiasExistentes = const [],
    List<XFile> nuevasFotografias = const [],
  }) {
    return remoteDatasource.update(
      id: id,
      data: {
        'titulo': titulo,
        'descripcion': descripcion,
        'tipoEspacio': AlojamientoModel.tipoEspacioToApi(tipoEspacio),
        'tipoPrivacidad': AlojamientoModel.tipoPrivacidadToApi(tipoPrivacidad),
        'tipoAcceso': tipoAcceso,
        'reglas': reglas,
        'precioMensual': precioMensual,
        'ubicacion': ubicacion,
        'servicios': servicios,
        'fotografias': fotografiasExistentes,
      },
      nuevasFotografias: nuevasFotografias,
    );
  }

  @override
  Future<Alojamiento> toggleEstado(String id) {
    return remoteDatasource.toggleEstado(id);
  }

  @override
  Future<void> deleteAlojamiento(String id) {
    return remoteDatasource.delete(id);
  }
}
