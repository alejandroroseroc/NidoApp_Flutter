import 'alojamiento.dart';

class FiltrosAlojamiento {
  const FiltrosAlojamiento({
    this.tipoEspacio,
    this.precioMin,
    this.precioMax,
    this.servicios = const [],
    this.ubicacion = '',
  });

  final TipoEspacio? tipoEspacio;
  final double? precioMin;
  final double? precioMax;
  final List<String> servicios;
  final String ubicacion;

  bool get isActive =>
      tipoEspacio != null ||
      precioMin != null ||
      precioMax != null ||
      servicios.isNotEmpty ||
      ubicacion.trim().isNotEmpty;

  /// Cantidad de grupos de filtros activos (para el badge del botón).
  int get activeCount {
    int count = 0;
    if (tipoEspacio != null) count++;
    if (precioMin != null || precioMax != null) count++;
    if (servicios.isNotEmpty) count++;
    if (ubicacion.trim().isNotEmpty) count++;
    return count;
  }

  /// Convierte los filtros activos a query params para la API.
  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};
    if (tipoEspacio != null) {
      params['tipoEspacio'] = _tipoEspacioToApi(tipoEspacio!);
    }
    if (precioMin != null) params['precioMin'] = precioMin!.toStringAsFixed(0);
    if (precioMax != null) params['precioMax'] = precioMax!.toStringAsFixed(0);
    if (servicios.isNotEmpty) params['servicios'] = servicios.join(',');
    if (ubicacion.trim().isNotEmpty) params['ubicacion'] = ubicacion.trim();
    return params;
  }

  FiltrosAlojamiento copyWith({
    TipoEspacio? tipoEspacio,
    double? precioMin,
    double? precioMax,
    List<String>? servicios,
    String? ubicacion,
    bool clearTipo = false,
    bool clearPrecioMin = false,
    bool clearPrecioMax = false,
  }) {
    return FiltrosAlojamiento(
      tipoEspacio: clearTipo ? null : (tipoEspacio ?? this.tipoEspacio),
      precioMin: clearPrecioMin ? null : (precioMin ?? this.precioMin),
      precioMax: clearPrecioMax ? null : (precioMax ?? this.precioMax),
      servicios: servicios ?? this.servicios,
      ubicacion: ubicacion ?? this.ubicacion,
    );
  }

  static String _tipoEspacioToApi(TipoEspacio tipo) {
    switch (tipo) {
      case TipoEspacio.habitacion:
        return 'HABITACION';
      case TipoEspacio.apartaestudio:
        return 'APARTAESTUDIO';
      case TipoEspacio.compartido:
        return 'COMPARTIDO';
    }
  }
}
