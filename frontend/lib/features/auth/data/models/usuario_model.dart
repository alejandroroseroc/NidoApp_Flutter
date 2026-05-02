import '../../domain/entities/usuario.dart';

// DTO de usuario para serializacion con la API.
class UsuarioModel extends Usuario {
  const UsuarioModel({
    required super.id,
    required super.nombre,
    required super.correo,
    required super.modoActivo,
    super.telefono,
    super.fotoPerfil,
    super.descripcion,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      correo: json['correo'] as String,
      telefono: json['telefono'] as String?,
      fotoPerfil: json['fotoPerfil'] as String?,
      descripcion: json['descripcion'] as String?,
      modoActivo: modoActivoFromString(json['modoActivo'] as String?),
    );
  }

  factory UsuarioModel.fromEntity(Usuario usuario) {
    return UsuarioModel(
      id: usuario.id,
      nombre: usuario.nombre,
      correo: usuario.correo,
      telefono: usuario.telefono,
      fotoPerfil: usuario.fotoPerfil,
      descripcion: usuario.descripcion,
      modoActivo: usuario.modoActivo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
      'telefono': telefono,
      'fotoPerfil': fotoPerfil,
      'descripcion': descripcion,
      'modoActivo': modoActivoToString(modoActivo),
    };
  }

  static ModoActivo modoActivoFromString(String? value) {
    switch (value) {
      case 'ANFITRION':
        return ModoActivo.anfitrion;
      case 'INVITADO':
      default:
        return ModoActivo.invitado;
    }
  }

  static String modoActivoToString(ModoActivo mode) {
    switch (mode) {
      case ModoActivo.anfitrion:
        return 'ANFITRION';
      case ModoActivo.invitado:
        return 'INVITADO';
    }
  }
}
