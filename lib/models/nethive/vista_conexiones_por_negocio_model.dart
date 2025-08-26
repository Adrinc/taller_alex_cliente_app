import 'dart:convert';

class VistaConexionesPorNegocio {
  final String conexionId;
  final String tipo; // 'alimentacion' o 'componente'
  final String origenId;
  final String origenNombre;
  final String origenUbicacion;
  final String destinoId;
  final String destinoNombre;
  final String destinoUbicacion;
  final String? cableId;
  final String? cableNombre;
  final String? rfidCable;
  final bool activo;
  final String? notas;
  final String negocioId;
  final String negocioNombre;
  final String? tecnicoId;
  final String? tecnicoNombre;
  final DateTime fechaCreacion;
  final DateTime? fechaModificacion;

  VistaConexionesPorNegocio({
    required this.conexionId,
    required this.tipo,
    required this.origenId,
    required this.origenNombre,
    required this.origenUbicacion,
    required this.destinoId,
    required this.destinoNombre,
    required this.destinoUbicacion,
    this.cableId,
    this.cableNombre,
    this.rfidCable,
    required this.activo,
    this.notas,
    required this.negocioId,
    required this.negocioNombre,
    this.tecnicoId,
    this.tecnicoNombre,
    required this.fechaCreacion,
    this.fechaModificacion,
  });

  factory VistaConexionesPorNegocio.fromMap(Map<String, dynamic> map) {
    return VistaConexionesPorNegocio(
      conexionId: map['conexion_id']?.toString() ?? '',
      tipo: map['tipo']?.toString() ?? '',
      origenId: map['origen_id']?.toString() ?? '',
      origenNombre: map['origen_nombre']?.toString() ?? '',
      origenUbicacion: map['origen_ubicacion']?.toString() ?? '',
      destinoId: map['destino_id']?.toString() ?? '',
      destinoNombre: map['destino_nombre']?.toString() ?? '',
      destinoUbicacion: map['destino_ubicacion']?.toString() ?? '',
      cableId: map['cable_id']?.toString(),
      cableNombre: map['cable_nombre']?.toString(),
      rfidCable: map['rfid_cable']?.toString(),
      activo: map['activo'] == true,
      notas: map['notas']?.toString(),
      negocioId: map['negocio_id']?.toString() ?? '',
      negocioNombre: map['negocio_nombre']?.toString() ?? '',
      tecnicoId: map['tecnico_id']?.toString(),
      tecnicoNombre: map['tecnico_nombre']?.toString(),
      fechaCreacion: DateTime.parse(map['fecha_creacion'].toString()),
      fechaModificacion: map['fecha_modificacion'] != null
          ? DateTime.parse(map['fecha_modificacion'].toString())
          : null,
    );
  }

  factory VistaConexionesPorNegocio.fromJson(String source) =>
      VistaConexionesPorNegocio.fromMap(json.decode(source));

  Map<String, dynamic> toMap() {
    return {
      'conexion_id': conexionId,
      'tipo': tipo,
      'origen_id': origenId,
      'origen_nombre': origenNombre,
      'origen_ubicacion': origenUbicacion,
      'destino_id': destinoId,
      'destino_nombre': destinoNombre,
      'destino_ubicacion': destinoUbicacion,
      'cable_id': cableId,
      'cable_nombre': cableNombre,
      'rfid_cable': rfidCable,
      'activo': activo,
      'notas': notas,
      'negocio_id': negocioId,
      'negocio_nombre': negocioNombre,
      'tecnico_id': tecnicoId,
      'tecnico_nombre': tecnicoNombre,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_modificacion': fechaModificacion?.toIso8601String(),
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'VistaConexionesPorNegocio(conexionId: $conexionId, tipo: $tipo, origen: $origenNombre, destino: $destinoNombre, cable: $cableNombre, activo: $activo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VistaConexionesPorNegocio && other.conexionId == conexionId;
  }

  @override
  int get hashCode => conexionId.hashCode;

  // Métodos de utilidad
  bool get tieneRfid => rfidCable != null && rfidCable!.isNotEmpty;
  bool get esTipoAlimentacion => tipo == 'alimentacion';
  bool get esTipoComponente => tipo == 'componente';

  String get descripcionCompleta {
    return '$origenNombre → $destinoNombre${cableNombre != null ? ' (Cable: $cableNombre)' : ''}';
  }

  String get estadoConexion {
    if (!activo) return 'Inactiva';
    if (tieneRfid) return 'Completada';
    return 'Pendiente';
  }
}
