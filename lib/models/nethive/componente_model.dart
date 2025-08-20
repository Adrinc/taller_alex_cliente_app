import 'dart:convert';

class Componente {
  final String id;
  final String negocioId;
  final int categoriaId;
  final String nombre;
  final String? descripcion;
  final bool enUso;
  final bool activo;
  final String? ubicacion;
  final String? imagenUrl;
  final DateTime fechaRegistro;
  final String? distribucionId;
  final String? rolLogicoId;
  final String? rfid; // ← NUEVO campo RFID

  Componente({
    required this.id,
    required this.negocioId,
    required this.categoriaId,
    required this.nombre,
    this.descripcion,
    required this.enUso,
    required this.activo,
    this.ubicacion,
    this.imagenUrl,
    required this.fechaRegistro,
    this.distribucionId,
    this.rolLogicoId,
    this.rfid, // ← NUEVO parámetro
  });

  factory Componente.fromMap(Map<String, dynamic> map) {
    try {
      return Componente(
        id: _getStringValue(map['id']) ?? '',
        negocioId: _getStringValue(map['negocio_id']) ?? '',
        categoriaId: _getIntValue(map['categoria_id']) ?? 0,
        nombre: _getStringValue(map['nombre']) ?? '',
        descripcion: _getStringValue(map['descripcion']),
        enUso: _getBoolValue(map['en_uso']) ?? false,
        activo: _getBoolValue(map['activo']) ?? true,
        ubicacion: _getStringValue(map['ubicacion']),
        imagenUrl: _getStringValue(map['imagen_url']),
        fechaRegistro:
            _getDateTimeValue(map['fecha_registro']) ?? DateTime.now(),
        distribucionId: _getStringValue(map['distribucion_id']),
        rolLogicoId: _getStringValue(map['rol_logico_id']),
        rfid: _getStringValue(map['rfid']),
      );
    } catch (e) {
      print('Error en Componente.fromMap: $e');
      print('Data received: $map');
      rethrow;
    }
  }

  // Métodos auxiliares para manejar tipos de datos de forma segura
  static String? _getStringValue(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map) return null; // Ignorar objetos JSON anidados
    return value.toString();
  }

  static int? _getIntValue(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }

  static bool? _getBoolValue(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return null;
  }

  static DateTime? _getDateTimeValue(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'negocio_id': negocioId,
      'categoria_id': categoriaId,
      'nombre': nombre,
      'descripcion': descripcion,
      'en_uso': enUso,
      'activo': activo,
      'ubicacion': ubicacion,
      'imagen_url': imagenUrl,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'distribucion_id': distribucionId,
      'rol_logico_id': rolLogicoId,
      'rfid': rfid, // ← NUEVO en el mapa
    };
  }

  factory Componente.fromJson(String source) =>
      Componente.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());
}
