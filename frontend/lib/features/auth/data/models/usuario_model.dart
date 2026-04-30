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
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: json['id'] as String,
      nombre: json['nombre'] as String,
      correo: json['correo'] as String,
      telefono: json['telefono'] as String?,
      fotoPerfil: json['fotoPerfil'] as String?,
      modoActivo: _modoActivoFromString(json['modoActivo'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
      'telefono': telefono,
      'fotoPerfil': fotoPerfil,
      'modoActivo': _modoActivoToString(modoActivo),
    };
  }

  static ModoActivo _modoActivoFromString(String? value) {
    switch (value) {
      case 'ANFITRION':
        return ModoActivo.anfitrion;
      case 'INVITADO':
      default:
        return ModoActivo.invitado;
    }
  }

  static String _modoActivoToString(ModoActivo mode) {
    switch (mode) {
      case ModoActivo.anfitrion:
        return 'ANFITRION';
      case ModoActivo.invitado:
        return 'INVITADO';
    }
  }
}
