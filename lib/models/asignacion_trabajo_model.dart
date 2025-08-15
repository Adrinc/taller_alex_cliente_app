enum EstadoTrabajo { enProgreso, completado, pausado }

class AsignacionTrabajo {
  final String id;
  final String tecnicoId;
  final String negocioId;
  final EstadoTrabajo estado;
  final int prioridad;
  final String? tipoTrabajo;
  final String? descripcionTrabajo;
  final String? notas;
  final DateTime fechaInicio;
  final DateTime? fechaFin;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  AsignacionTrabajo({
    required this.id,
    required this.tecnicoId,
    required this.negocioId,
    required this.estado,
    required this.prioridad,
    this.tipoTrabajo,
    this.descripcionTrabajo,
    this.notas,
    required this.fechaInicio,
    this.fechaFin,
    this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AsignacionTrabajo.fromJson(Map<String, dynamic> json) {
    return AsignacionTrabajo(
      id: json['id'] as String,
      tecnicoId: json['tecnico_id'] as String,
      negocioId: json['negocio_id'] as String,
      estado: _parseEstado(json['estado'] as String),
      prioridad: json['prioridad'] as int,
      tipoTrabajo: json['tipo_trabajo'] as String?,
      descripcionTrabajo: json['descripcion_trabajo'] as String?,
      notas: json['notas'] as String?,
      fechaInicio: DateTime.parse(json['fecha_inicio'] as String),
      fechaFin: json['fecha_fin'] != null
          ? DateTime.parse(json['fecha_fin'] as String)
          : null,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  static EstadoTrabajo _parseEstado(String estado) {
    switch (estado) {
      case 'en_progreso':
        return EstadoTrabajo.enProgreso;
      case 'completado':
        return EstadoTrabajo.completado;
      case 'pausado':
        return EstadoTrabajo.pausado;
      default:
        return EstadoTrabajo.enProgreso;
    }
  }

  String get estadoString {
    switch (estado) {
      case EstadoTrabajo.enProgreso:
        return 'en_progreso';
      case EstadoTrabajo.completado:
        return 'completado';
      case EstadoTrabajo.pausado:
        return 'pausado';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tecnico_id': tecnicoId,
      'negocio_id': negocioId,
      'estado': estadoString,
      'prioridad': prioridad,
      'tipo_trabajo': tipoTrabajo,
      'descripcion_trabajo': descripcionTrabajo,
      'notas': notas,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_fin': fechaFin?.toIso8601String(),
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
