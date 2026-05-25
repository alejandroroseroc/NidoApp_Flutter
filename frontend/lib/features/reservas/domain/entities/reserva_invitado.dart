import 'package:equatable/equatable.dart';

enum EstadoReservaInvitado { pendiente, aceptada, rechazada }

// Reserva del invitado con datos del alojamiento y anfitrion.
class ReservaInvitado extends Equatable {
  const ReservaInvitado({
    required this.id,
    required this.estado,
    required this.fechaIngreso,
    required this.duracionDias,
    required this.fechaSolicitud,
    required this.alojamientoId,
    required this.alojamientoTitulo,
    required this.alojamientoUbicacion,
    this.alojamientoFoto,
    required this.anfitrionNombre,
    this.anfitrionTelefono,
    this.precioNoche,
    this.precioTotal,
  });

  final String id;
  final EstadoReservaInvitado estado;
  final DateTime fechaIngreso;
  final int duracionDias;
  final DateTime fechaSolicitud;
  final String alojamientoId;
  final String alojamientoTitulo;
  final String alojamientoUbicacion;
  final String? alojamientoFoto;
  final String anfitrionNombre;
  final String? anfitrionTelefono;
  final double? precioNoche;
  final double? precioTotal;

  @override
  List<Object?> get props => [
    id,
    estado,
    fechaIngreso,
    duracionDias,
    fechaSolicitud,
    alojamientoId,
    alojamientoTitulo,
    alojamientoUbicacion,
    alojamientoFoto,
    anfitrionNombre,
    anfitrionTelefono,
    precioNoche,
    precioTotal,
  ];
}
