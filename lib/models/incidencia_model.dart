enum TipoIncidencia { dano, faltante, malEtiquetado, otro }

enum EstadoIncidencia { abierta, enRevision, resuelta }

class Incidencia {
  final String id;
  final String tecnicoId;
  final String? componenteId;
  final String? trabajoId;
  final TipoIncidencia tipoIncidencia;
  final String? descripcion;
  final EstadoIncidencia estado;
  final DateTime fechaReporte;
  final List<String> evidencias; // URLs de fotos

  Incidencia({
    required this.id,
    required this.tecnicoId,
    this.componenteId,
    this.trabajoId,
    required this.tipoIncidencia,
    this.descripcion,
    required this.estado,
    required this.fechaReporte,
    this.evidencias = const [],
  });

  factory Incidencia.fromJson(Map<String, dynamic> json) {
    return Incidencia(
      id: json['id'] as String,
      tecnicoId: json['tecnico_id'] as String,
      componenteId: json['componente_id'] as String?,
      trabajoId: json['trabajo_id'] as String?,
      tipoIncidencia: _parseTipoIncidencia(json['tipo_incidencia'] as String),
      descripcion: json['descripcion'] as String?,
      estado: _parseEstadoIncidencia(json['estado'] as String),
      fechaReporte: DateTime.parse(json['fecha_reporte'] as String),
      evidencias: json['evidencias'] != null
          ? List<String>.from(json['evidencias'] as List)
          : [],
    );
  }

  static TipoIncidencia _parseTipoIncidencia(String tipo) {
    switch (tipo) {
      case 'daño':
        return TipoIncidencia.dano;
      case 'faltante':
        return TipoIncidencia.faltante;
      case 'mal_etiquetado':
        return TipoIncidencia.malEtiquetado;
      case 'otro':
        return TipoIncidencia.otro;
      default:
        return TipoIncidencia.otro;
    }
  }

  static EstadoIncidencia _parseEstadoIncidencia(String estado) {
    switch (estado) {
      case 'abierta':
        return EstadoIncidencia.abierta;
      case 'en_revision':
        return EstadoIncidencia.enRevision;
      case 'resuelta':
        return EstadoIncidencia.resuelta;
      default:
        return EstadoIncidencia.abierta;
    }
  }

  String get tipoIncidenciaString {
    switch (tipoIncidencia) {
      case TipoIncidencia.dano:
        return 'daño';
      case TipoIncidencia.faltante:
        return 'faltante';
      case TipoIncidencia.malEtiquetado:
        return 'mal_etiquetado';
      case TipoIncidencia.otro:
        return 'otro';
    }
  }

  String get estadoString {
    switch (estado) {
      case EstadoIncidencia.abierta:
        return 'abierta';
      case EstadoIncidencia.enRevision:
        return 'en_revision';
      case EstadoIncidencia.resuelta:
        return 'resuelta';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tecnico_id': tecnicoId,
      'componente_id': componenteId,
      'trabajo_id': trabajoId,
      'tipo_incidencia': tipoIncidenciaString,
      'descripcion': descripcion,
      'estado': estadoString,
      'fecha_reporte': fechaReporte.toIso8601String(),
      'evidencias': evidencias,
    };
  }
}
