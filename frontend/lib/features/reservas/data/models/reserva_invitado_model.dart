import '../../domain/entities/reserva_invitado.dart';

class ReservaInvitadoModel extends ReservaInvitado {
  const ReservaInvitadoModel({
    required super.id,
    required super.estado,
    required super.fechaIngreso,
    required super.duracionDias,
    required super.fechaSolicitud,
    required super.alojamientoTitulo,
    required super.alojamientoUbicacion,
    super.alojamientoFoto,
    required super.anfitrionNombre,
    super.anfitrionTelefono,
  });

  factory ReservaInvitadoModel.fromJson(Map<String, dynamic> json) {
    final alojamiento = json['alojamiento'] as Map<String, dynamic>? ?? {};
    final anfitrion = alojamiento['anfitrion'] as Map<String, dynamic>? ?? {};
    final fotos = alojamiento['fotografias'];

    return ReservaInvitadoModel(
      id: json['id'] as String,
      estado: _parseEstado(json['estado'] as String?),
      fechaIngreso: DateTime.parse(json['fechaIngreso'] as String),
      duracionDias: json['duracionDias'] as int? ?? 1,
      fechaSolicitud: DateTime.parse(json['fechaSolicitud'] as String),
      alojamientoTitulo: alojamiento['titulo'] as String? ?? '',
      alojamientoUbicacion: alojamiento['ubicacion'] as String? ?? '',
      alojamientoFoto: _firstPhoto(fotos),
      anfitrionNombre: anfitrion['nombre'] as String? ?? '',
      anfitrionTelefono: anfitrion['telefono'] as String?,
    );
  }

  static EstadoReservaInvitado _parseEstado(String? value) {
    switch (value) {
      case 'ACEPTADA':
        return EstadoReservaInvitado.aceptada;
      case 'RECHAZADA':
        return EstadoReservaInvitado.rechazada;
      default:
        return EstadoReservaInvitado.pendiente;
    }
  }

  static String? _firstPhoto(dynamic fotos) {
    if (fotos is List && fotos.isNotEmpty) {
      return fotos.first as String?;
    }
    return null;
  }
}
