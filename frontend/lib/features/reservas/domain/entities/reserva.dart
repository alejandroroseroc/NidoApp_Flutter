import 'package:equatable/equatable.dart';

enum EstadoReserva { pendiente, aceptada, rechazada }

// Entidad de reserva vista por el anfitrion (HU-15).
class Reserva extends Equatable {
  const Reserva({
    required this.id,
    required this.estado,
    required this.fechaIngreso,
    required this.duracionDias,
    required this.fechaSolicitud,
    required this.invitadoNombre,
    required this.invitadoCorreo,
    this.invitadoTelefono,
    this.invitadoFoto,
    required this.alojamientoId,
    required this.alojamientoTitulo,
    required this.alojamientoUbicacion,
    this.alojamientoFoto,
    this.precioNoche,
    this.precioTotal,
  });

  final String id;
  final EstadoReserva estado;
  final DateTime fechaIngreso;
  final int duracionDias;
  final DateTime fechaSolicitud;
  final String invitadoNombre;
  final String invitadoCorreo;
  final String? invitadoTelefono;
  final String? invitadoFoto;
  final String alojamientoId;
  final String alojamientoTitulo;
  final String alojamientoUbicacion;
  final String? alojamientoFoto;
  final double? precioNoche;
  final double? precioTotal;

  bool get esPendiente => estado == EstadoReserva.pendiente;

  String get duracionTexto =>
      '$duracionDias ${duracionDias == 1 ? 'noche' : 'noches'}';

  @override
  List<Object?> get props => [
    id,
    estado,
    fechaIngreso,
    duracionDias,
    fechaSolicitud,
    invitadoNombre,
    invitadoCorreo,
    invitadoTelefono,
    invitadoFoto,
    alojamientoId,
    alojamientoTitulo,
    alojamientoUbicacion,
    alojamientoFoto,
    precioNoche,
    precioTotal,
  ];
}
