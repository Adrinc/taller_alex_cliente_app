import 'dart:convert';

class ConexionComponente {
  final String id;
  final String componenteOrigenId;
  final String componenteDestinoId;
  final String? cableId;
  final String? descripcion;
  final bool activo;
  final DateTime? fechaCreacion;
  final DateTime? fechaModificacion;
  final String? tecnicoId;

  ConexionComponente({
    required this.id,
    required this.componenteOrigenId,
    required this.componenteDestinoId,
    this.cableId,
    this.descripcion,
    required this.activo,
    this.fechaCreacion,
    this.fechaModificacion,
    this.tecnicoId,
  });

  factory ConexionComponente.fromMap(Map<String, dynamic> map) {
    return ConexionComponente(
      id: map['id']?.toString() ?? '',
      componenteOrigenId: map['componente_origen_id']?.toString() ?? '',
      componenteDestinoId: map['componente_destino_id']?.toString() ?? '',
      cableId: map['cable_id']?.toString(),
      descripcion: map['descripcion']?.toString(),
      activo: map['activo'] == true,
      fechaCreacion: map['fecha_creacion'] != null
          ? DateTime.parse(map['fecha_creacion'].toString())
          : null,
      fechaModificacion: map['fecha_modificacion'] != null
          ? DateTime.parse(map['fecha_modificacion'].toString())
          : null,
      tecnicoId: map['tecnico_id']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'componente_origen_id': componenteOrigenId,
      'componente_destino_id': componenteDestinoId,
      'cable_id': cableId,
      'descripcion': descripcion,
      'activo': activo,
      'fecha_creacion': fechaCreacion?.toIso8601String(),
      'fecha_modificacion': fechaModificacion?.toIso8601String(),
      'tecnico_id': tecnicoId,
    };
  }

  factory ConexionComponente.fromJson(String source) =>
      ConexionComponente.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'ConexionComponente(id: $id, origen: $componenteOrigenId, destino: $componenteDestinoId, activo: $activo)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConexionComponente && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
