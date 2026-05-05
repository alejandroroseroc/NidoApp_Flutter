import 'package:equatable/equatable.dart';

enum ModoActivo { invitado, anfitrion }

// Entidad de dominio para el usuario autenticado.
class Usuario extends Equatable {
  const Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.modoActivo,
    this.telefono,
    this.fotoPerfil,
    this.descripcion,
    this.tieneMascotas,
    this.esFumador,
    this.nivelRuido,
    this.genero,
    this.otrasPreferencias = const [],
  });

  final String id;
  final String nombre;
  final String correo;
  final String? telefono;
  final String? fotoPerfil;
  final String? descripcion;
  final ModoActivo modoActivo;

  // Preferencias de convivencia
  final bool? tieneMascotas;
  final bool? esFumador;
  final String? nivelRuido;
  final String? genero;
  final List<String> otrasPreferencias;

  @override
  List<Object?> get props => [
    id,
    nombre,
    correo,
    telefono,
    fotoPerfil,
    descripcion,
    modoActivo,
    tieneMascotas,
    esFumador,
    nivelRuido,
    genero,
    otrasPreferencias,
  ];
}
