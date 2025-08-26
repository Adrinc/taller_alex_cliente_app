class ConexionAlimentacion {
  final String id;
  final String origenId;
  final String destinoId;
  final String? cableId;
  final String? descripcion;
  final bool activo;
  final DateTime? fechaCreacion;
  final String? tecnicoId;

  ConexionAlimentacion({
    required this.id,
    required this.origenId,
    required this.destinoId,
    this.cableId,
    this.descripcion,
    required this.activo,
    this.fechaCreacion,
    this.tecnicoId,
  });

  factory ConexionAlimentacion.fromMap(Map<String, dynamic> map) {
    return ConexionAlimentacion(
      id: map['id'] ?? '',
      origenId: map['origen_id'] ?? '',
      destinoId: map['destino_id'] ?? '',
      cableId: map['cable_id'],
      descripcion: map['descripcion'],
      activo: map['activo'] ?? true,
      fechaCreacion: map['fecha_creacion'] != null
          ? DateTime.parse(map['fecha_creacion'])
          : null,
      tecnicoId: map['tecnico_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'origen_id': origenId,
      'destino_id': destinoId,
      'cable_id': cableId,
      'descripcion': descripcion,
      'activo': activo,
      'fecha_creacion': fechaCreacion?.toIso8601String(),
      'tecnico_id': tecnicoId,
    };
  }
}
