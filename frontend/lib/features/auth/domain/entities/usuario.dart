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
  });

  final String id;
  final String nombre;
  final String correo;
  final String? telefono;
  final String? fotoPerfil;
  final ModoActivo modoActivo;

  @override
  List<Object?> get props => [
    id,
    nombre,
    correo,
    telefono,
    fotoPerfil,
    modoActivo,
  ];
}
