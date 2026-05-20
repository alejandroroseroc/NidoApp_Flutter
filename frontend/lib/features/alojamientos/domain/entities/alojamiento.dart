import 'package:equatable/equatable.dart';

enum TipoEspacio { habitacion, apartaestudio, compartido }

enum TipoPrivacidad { privado, compartido }

enum EstadoAlojamiento { activo, inactivo }

class Alojamiento extends Equatable {
  const Alojamiento({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.tipoEspacio,
    required this.tipoPrivacidad,
    required this.tipoAcceso,
    required this.precioMensual,
    required this.ubicacion,
    required this.estado,
    required this.anfitrionId,
    this.reglas,
    this.servicios = const [],
    this.fotografias = const [],
    this.creadoEn,
  });

  final String id;
  final String titulo;
  final String descripcion;
  final TipoEspacio tipoEspacio;
  final TipoPrivacidad tipoPrivacidad;
  final String tipoAcceso;
  final String? reglas;
  final List<String> servicios;
  final double precioMensual;
  final String ubicacion;
  final List<String> fotografias;
  final EstadoAlojamiento estado;
  final String anfitrionId;
  final DateTime? creadoEn;

  bool get isActivo => estado == EstadoAlojamiento.activo;

  String? get fotoPrincipal =>
      fotografias.isNotEmpty ? fotografias.first : null;

  @override
  List<Object?> get props => [id, titulo, estado, precioMensual];
}
