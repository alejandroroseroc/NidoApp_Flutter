import '../../domain/entities/alojamiento.dart';

class AlojamientoModel extends Alojamiento {
  const AlojamientoModel({
    required super.id,
    required super.titulo,
    required super.descripcion,
    required super.tipoEspacio,
    required super.tipoPrivacidad,
    required super.tipoAcceso,
    required super.precioMensual,
    required super.ubicacion,
    required super.estado,
    required super.anfitrionId,
    super.reglas,
    super.servicios,
    super.fotografias,
    super.creadoEn,
  });

  factory AlojamientoModel.fromJson(Map<String, dynamic> json) {
    return AlojamientoModel(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      tipoEspacio: _tipoEspacioFromString(json['tipoEspacio'] as String),
      tipoPrivacidad: _tipoPrivacidadFromString(
        json['tipoPrivacidad'] as String,
      ),
      tipoAcceso: json['tipoAcceso'] as String,
      reglas: json['reglas'] as String?,
      servicios:
          (json['servicios'] as List<dynamic>? ?? [])
              .map((item) => item.toString())
              .toList(),
      precioMensual: _readPrecio(json),
      ubicacion: json['ubicacion'] as String,
      fotografias:
          (json['fotografias'] as List<dynamic>? ?? [])
              .map((item) => item.toString())
              .toList(),
      estado: _estadoFromString(json['estado'] as String),
      anfitrionId: json['anfitrionId'] as String,
      creadoEn:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString())
              : json['creadoEn'] != null
              ? DateTime.tryParse(json['creadoEn'].toString())
              : null,
    );
  }

  static double _readPrecio(Map<String, dynamic> json) {
    final value = json['precioMensual'] ?? json['precio'];
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static TipoEspacio _tipoEspacioFromString(String value) {
    switch (value.toUpperCase()) {
      case 'APARTAESTUDIO':
        return TipoEspacio.apartaestudio;
      case 'COMPARTIDO':
        return TipoEspacio.compartido;
      default:
        return TipoEspacio.habitacion;
    }
  }

  static TipoPrivacidad _tipoPrivacidadFromString(String value) {
    switch (value.toUpperCase()) {
      case 'COMPARTIDO':
        return TipoPrivacidad.compartido;
      default:
        return TipoPrivacidad.privado;
    }
  }

  static EstadoAlojamiento _estadoFromString(String value) {
    return value.toUpperCase() == 'INACTIVO'
        ? EstadoAlojamiento.inactivo
        : EstadoAlojamiento.activo;
  }

  static String tipoEspacioToApi(TipoEspacio value) {
    switch (value) {
      case TipoEspacio.apartaestudio:
        return 'APARTAESTUDIO';
      case TipoEspacio.compartido:
        return 'COMPARTIDO';
      case TipoEspacio.habitacion:
        return 'HABITACION';
    }
  }

  static String tipoPrivacidadToApi(TipoPrivacidad value) {
    switch (value) {
      case TipoPrivacidad.compartido:
        return 'COMPARTIDO';
      case TipoPrivacidad.privado:
        return 'PRIVADO';
    }
  }
}
