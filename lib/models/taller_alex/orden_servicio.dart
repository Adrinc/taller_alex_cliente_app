// Enums para Órdenes de Servicio
enum EstadoOrdenServicio {
  abierta,
  diagnostico,
  esperando_aprobacion,
  esperando_refaccion,
  en_proceso,
  finalizada,
  entregada,
  cancelada
}

extension EstadoOrdenServicioExtension on EstadoOrdenServicio {
  String get displayName {
    switch (this) {
      case EstadoOrdenServicio.abierta:
        return 'Abierta';
      case EstadoOrdenServicio.diagnostico:
        return 'En Diagnóstico';
      case EstadoOrdenServicio.esperando_aprobacion:
        return 'Esperando Aprobación';
      case EstadoOrdenServicio.esperando_refaccion:
        return 'Esperando Refacción';
      case EstadoOrdenServicio.en_proceso:
        return 'En Proceso';
      case EstadoOrdenServicio.finalizada:
        return 'Finalizada';
      case EstadoOrdenServicio.entregada:
        return 'Entregada';
      case EstadoOrdenServicio.cancelada:
        return 'Cancelada';
    }
  }

  String get description {
    switch (this) {
      case EstadoOrdenServicio.abierta:
        return 'La orden ha sido creada y está pendiente de iniciar';
      case EstadoOrdenServicio.diagnostico:
        return 'El técnico está realizando el diagnóstico del vehículo';
      case EstadoOrdenServicio.esperando_aprobacion:
        return 'Servicios adicionales detectados, esperando su aprobación';
      case EstadoOrdenServicio.esperando_refaccion:
        return 'En espera de refacciones para continuar';
      case EstadoOrdenServicio.en_proceso:
        return 'Los servicios están siendo ejecutados';
      case EstadoOrdenServicio.finalizada:
        return 'Todos los servicios han sido completados';
      case EstadoOrdenServicio.entregada:
        return 'El vehículo ha sido entregado al cliente';
      case EstadoOrdenServicio.cancelada:
        return 'La orden ha sido cancelada';
    }
  }

  static EstadoOrdenServicio fromString(String value) {
    switch (value.toLowerCase()) {
      case 'abierta':
        return EstadoOrdenServicio.abierta;
      case 'diagnostico':
        return EstadoOrdenServicio.diagnostico;
      case 'esperando_aprobacion':
        return EstadoOrdenServicio.esperando_aprobacion;
      case 'esperando_refaccion':
        return EstadoOrdenServicio.esperando_refaccion;
      case 'en_proceso':
        return EstadoOrdenServicio.en_proceso;
      case 'finalizada':
        return EstadoOrdenServicio.finalizada;
      case 'entregada':
        return EstadoOrdenServicio.entregada;
      case 'cancelada':
        return EstadoOrdenServicio.cancelada;
      default:
        return EstadoOrdenServicio.abierta;
    }
  }
}

// Modelo Orden de Servicio - basado en tabla 'ordenes_servicio'
class OrdenServicio {
  final String id;
  final String citaId;
  final String numero;
  final EstadoOrdenServicio estado;
  final String? empleadoResponsableId;
  final DateTime fechaInicio;
  final DateTime? fechaFinEstimada;
  final DateTime? fechaFinReal;
  final int? kilometraje;
  final int? nivelCombustible;
  final String? observacionesInternas;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrdenServicio({
    required this.id,
    required this.citaId,
    required this.numero,
    required this.estado,
    this.empleadoResponsableId,
    required this.fechaInicio,
    this.fechaFinEstimada,
    this.fechaFinReal,
    this.kilometraje,
    this.nivelCombustible,
    this.observacionesInternas,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrdenServicio.fromJson(Map<String, dynamic> json) {
    return OrdenServicio(
      id: json['id'],
      citaId: json['cita_id'],
      numero: json['numero'],
      estado: EstadoOrdenServicioExtension.fromString(json['estado']),
      empleadoResponsableId: json['empleado_responsable_id'],
      fechaInicio: DateTime.parse(json['fecha_inicio']),
      fechaFinEstimada: json['fecha_fin_estimada'] != null
          ? DateTime.parse(json['fecha_fin_estimada'])
          : null,
      fechaFinReal: json['fecha_fin_real'] != null
          ? DateTime.parse(json['fecha_fin_real'])
          : null,
      kilometraje: json['kilometraje'],
      nivelCombustible: json['nivel_combustible'],
      observacionesInternas: json['observaciones_internas'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cita_id': citaId,
      'numero': numero,
      'estado': estado.name,
      'empleado_responsable_id': empleadoResponsableId,
      'fecha_inicio': fechaInicio.toIso8601String(),
      'fecha_fin_estimada': fechaFinEstimada?.toIso8601String(),
      'fecha_fin_real': fechaFinReal?.toIso8601String(),
      'kilometraje': kilometraje,
      'nivel_combustible': nivelCombustible,
      'observaciones_internas': observacionesInternas,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  OrdenServicio copyWith({
    String? id,
    String? citaId,
    String? numero,
    EstadoOrdenServicio? estado,
    String? empleadoResponsableId,
    DateTime? fechaInicio,
    DateTime? fechaFinEstimada,
    DateTime? fechaFinReal,
    int? kilometraje,
    int? nivelCombustible,
    String? observacionesInternas,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrdenServicio(
      id: id ?? this.id,
      citaId: citaId ?? this.citaId,
      numero: numero ?? this.numero,
      estado: estado ?? this.estado,
      empleadoResponsableId:
          empleadoResponsableId ?? this.empleadoResponsableId,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFinEstimada: fechaFinEstimada ?? this.fechaFinEstimada,
      fechaFinReal: fechaFinReal ?? this.fechaFinReal,
      kilometraje: kilometraje ?? this.kilometraje,
      nivelCombustible: nivelCombustible ?? this.nivelCombustible,
      observacionesInternas:
          observacionesInternas ?? this.observacionesInternas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helpers
  bool get isActive =>
      estado != EstadoOrdenServicio.entregada &&
      estado != EstadoOrdenServicio.cancelada;

  bool get isCompleted =>
      estado == EstadoOrdenServicio.finalizada ||
      estado == EstadoOrdenServicio.entregada;

  bool get needsApproval => estado == EstadoOrdenServicio.esperando_aprobacion;

  Duration? get estimatedDuration {
    if (fechaFinEstimada != null) {
      return fechaFinEstimada!.difference(fechaInicio);
    }
    return null;
  }

  Duration? get actualDuration {
    if (fechaFinReal != null) {
      return fechaFinReal!.difference(fechaInicio);
    }
    return null;
  }
}
