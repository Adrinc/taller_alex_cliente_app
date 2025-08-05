import 'dart:convert';

class CategoriaComponente {
  final int id;
  final String nombre;
  final String? colorCategoria; // ← NUEVO campo para color hexadecimal

  CategoriaComponente({
    required this.id,
    required this.nombre,
    this.colorCategoria, // ← NUEVO parámetro
  });

  factory CategoriaComponente.fromMap(Map<String, dynamic> map) {
    return CategoriaComponente(
      id: map['id'],
      nombre: map['nombre'],
      colorCategoria: map['color_categoria'], // ← NUEVO mapeo
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'color_categoria': colorCategoria, // ← NUEVO campo en el map
    };
  }

  factory CategoriaComponente.fromJson(String source) =>
      CategoriaComponente.fromMap(json.decode(source));
  String toJson() => json.encode(toMap());
}
