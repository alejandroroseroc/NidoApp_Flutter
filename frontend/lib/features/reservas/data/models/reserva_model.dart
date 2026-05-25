import '../../domain/entities/reserva.dart';

class ReservaModel extends Reserva {
  const ReservaModel({
    required super.id,
    required super.estado,
    required super.fechaIngreso,
    required super.duracionDias,
    required super.fechaSolicitud,
    required super.invitadoNombre,
    required super.invitadoCorreo,
    super.invitadoTelefono,
    super.invitadoFoto,
    required super.alojamientoId,
    required super.alojamientoTitulo,
    required super.alojamientoUbicacion,
    super.alojamientoFoto,
    super.precioNoche,
    super.precioTotal,
  });

  factory ReservaModel.fromJson(Map<String, dynamic> json) {
    final invitado = json['invitado'] as Map<String, dynamic>? ?? {};
    final alojamiento = json['alojamiento'] as Map<String, dynamic>? ?? {};
    final fotos = alojamiento['fotografias'];

    return ReservaModel(
      id: json['id'] as String,
      estado: _parseEstado(json['estado'] as String?),
      fechaIngreso: DateTime.parse(json['fechaIngreso'] as String),
      duracionDias: json['duracionDias'] as int? ?? 1,
      fechaSolicitud: DateTime.parse(json['fechaSolicitud'] as String),
      invitadoNombre: invitado['nombre'] as String? ?? '',
      invitadoCorreo: invitado['correo'] as String? ?? '',
      invitadoTelefono: invitado['telefono'] as String?,
      invitadoFoto: invitado['fotoPerfil'] as String?,
      alojamientoId: alojamiento['id'] as String? ?? '',
      alojamientoTitulo: alojamiento['titulo'] as String? ?? '',
      alojamientoUbicacion: alojamiento['ubicacion'] as String? ?? '',
      alojamientoFoto: _firstPhoto(fotos),
      precioNoche: _parseDouble(json['precioNoche']),
      precioTotal: _parseDouble(json['precioTotal']),
    );
  }

  static EstadoReserva _parseEstado(String? value) {
    switch (value) {
      case 'ACEPTADA':
        return EstadoReserva.aceptada;
      case 'RECHAZADA':
        return EstadoReserva.rechazada;
      default:
        return EstadoReserva.pendiente;
    }
  }

  static String? _firstPhoto(dynamic fotos) {
    if (fotos is List && fotos.isNotEmpty) {
      return fotos.first as String?;
    }
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
