class Resena {
  const Resena({
    required this.id,
    required this.calificacion,
    required this.fecha,
    required this.autorNombre,
    this.comentario,
    this.autorFoto,
  });

  final String id;
  final int calificacion;
  final String? comentario;
  final DateTime fecha;
  final String autorNombre;
  final String? autorFoto;
}

class ResenaResumen {
  const ResenaResumen({required this.promedio, required this.total});

  final double promedio;
  final int total;
}

class ResenasResult {
  const ResenasResult({required this.resumen, required this.resenas});

  final ResenaResumen resumen;
  final List<Resena> resenas;
}

class ResenaModel extends Resena {
  const ResenaModel({
    required super.id,
    required super.calificacion,
    required super.fecha,
    required super.autorNombre,
    super.comentario,
    super.autorFoto,
  });

  factory ResenaModel.fromJson(Map<String, dynamic> json) {
    final autor = json['autor'] as Map<String, dynamic>? ?? {};
    return ResenaModel(
      id: json['id'] as String,
      calificacion: json['calificacion'] as int? ?? 0,
      comentario: json['comentario'] as String?,
      fecha: DateTime.parse(json['fecha'] as String),
      autorNombre: autor['nombre'] as String? ?? 'Usuario NidoApp',
      autorFoto: autor['fotoPerfil'] as String?,
    );
  }
}
