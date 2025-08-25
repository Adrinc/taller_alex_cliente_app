import 'dart:convert';

class Distribucion {
  final String id;
  final String negocioId;
  final int tipoId;
  final String nombre;
  final String? descripcion;

  Distribucion({
    required this.id,
    required this.negocioId,
    required this.tipoId,
    required this.nombre,
    this.descripcion,
  });

  factory Distribucion.fromMap(Map<String, dynamic> map) {
    return Distribucion(
      id: map['id'],
      negocioId: map['negocio_id'],
      tipoId: map['tipo_id'],
      nombre: map['nombre'],
      descripcion: map['descripcion'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'negocio_id': negocioId,
      'tipo_id': tipoId,
      'nombre': nombre,
      'descripcion': descripcion,
    };
  }

  factory Distribucion.fromJson(String source) =>
      Distribucion.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());
}
