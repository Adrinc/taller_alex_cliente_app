// Enums para Citas
enum EstadoCita {
  pendiente,
  confirmada,
  en_proceso,
  finalizada,
  cancelada,
  no_asistio
}

enum FuenteCita { app_cliente, telefono, presencial, whatsapp, web }

extension EstadoCitaExtension on EstadoCita {
  String get displayName {
    switch (this) {
      case EstadoCita.pendiente:
        return 'Pendiente';
      case EstadoCita.confirmada:
        return 'Confirmada';
      case EstadoCita.en_proceso:
        return 'En Proceso';
      case EstadoCita.finalizada:
        return 'Finalizada';
      case EstadoCita.cancelada:
        return 'Cancelada';
      case EstadoCita.no_asistio:
        return 'No Asistió';
    }
  }

  static EstadoCita fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pendiente':
        return EstadoCita.pendiente;
      case 'confirmada':
        return EstadoCita.confirmada;
      case 'en_proceso':
        return EstadoCita.en_proceso;
      case 'finalizada':
        return EstadoCita.finalizada;
      case 'cancelada':
        return EstadoCita.cancelada;
      case 'no_asistio':
        return EstadoCita.no_asistio;
      default:
        return EstadoCita.pendiente;
    }
  }
}

extension FuenteCitaExtension on FuenteCita {
  String get displayName {
    switch (this) {
      case FuenteCita.app_cliente:
        return 'App Cliente';
      case FuenteCita.telefono:
        return 'Teléfono';
      case FuenteCita.presencial:
        return 'Presencial';
      case FuenteCita.whatsapp:
        return 'WhatsApp';
      case FuenteCita.web:
        return 'Web';
    }
  }

  static FuenteCita fromString(String value) {
    switch (value.toLowerCase()) {
      case 'app_cliente':
        return FuenteCita.app_cliente;
      case 'telefono':
        return FuenteCita.telefono;
      case 'presencial':
        return FuenteCita.presencial;
      case 'whatsapp':
        return FuenteCita.whatsapp;
      case 'web':
        return FuenteCita.web;
      default:
        return FuenteCita.app_cliente;
    }
  }
}

// Modelo Cita - basado en tabla 'citas'
class Cita {
  final String id;
  final String clienteId;
  final String vehiculoId;
  final String sucursalId;
  final DateTime inicio;
  final DateTime fin;
  final EstadoCita estado;
  final FuenteCita fuente;
  final String? promocionId;
  final String? notasCliente;
  final String? notasInternas;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cita({
    required this.id,
    required this.clienteId,
    required this.vehiculoId,
    required this.sucursalId,
    required this.inicio,
    required this.fin,
    required this.estado,
    required this.fuente,
    this.promocionId,
    this.notasCliente,
    this.notasInternas,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      id: json['id'],
      clienteId: json['cliente_id'],
      vehiculoId: json['vehiculo_id'],
      sucursalId: json['sucursal_id'],
      inicio: DateTime.parse(json['inicio']),
      fin: DateTime.parse(json['fin']),
      estado: EstadoCitaExtension.fromString(json['estado']),
      fuente: FuenteCitaExtension.fromString(json['fuente']),
      promocionId: json['promocion_id'],
      notasCliente: json['notas_cliente'],
      notasInternas: json['notas_internas'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'vehiculo_id': vehiculoId,
      'sucursal_id': sucursalId,
      'inicio': inicio.toIso8601String(),
      'fin': fin.toIso8601String(),
      'estado': estado.name,
      'fuente': fuente.name,
      'promocion_id': promocionId,
      'notas_cliente': notasCliente,
      'notas_internas': notasInternas,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Cita copyWith({
    String? id,
    String? clienteId,
    String? vehiculoId,
    String? sucursalId,
    DateTime? inicio,
    DateTime? fin,
    EstadoCita? estado,
    FuenteCita? fuente,
    String? promocionId,
    String? notasCliente,
    String? notasInternas,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cita(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      vehiculoId: vehiculoId ?? this.vehiculoId,
      sucursalId: sucursalId ?? this.sucursalId,
      inicio: inicio ?? this.inicio,
      fin: fin ?? this.fin,
      estado: estado ?? this.estado,
      fuente: fuente ?? this.fuente,
      promocionId: promocionId ?? this.promocionId,
      notasCliente: notasCliente ?? this.notasCliente,
      notasInternas: notasInternas ?? this.notasInternas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helpers
  Duration get duration => fin.difference(inicio);
  bool get isActive =>
      estado == EstadoCita.confirmada || estado == EstadoCita.en_proceso;
  bool get canCancel =>
      estado == EstadoCita.pendiente || estado == EstadoCita.confirmada;
}
