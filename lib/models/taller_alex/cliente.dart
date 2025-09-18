// Modelo Cliente - basado en tabla 'clientes'
class Cliente {
  final String id;
  final String? usuarioId;
  final String nombre;
  final String? correo;
  final String? telefono;
  final String? direccion;
  final String? rfc;
  final String? notas;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cliente({
    required this.id,
    this.usuarioId,
    required this.nombre,
    this.correo,
    this.telefono,
    this.direccion,
    this.rfc,
    this.notas,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      id: json['id'],
      usuarioId: json['usuario_id'],
      nombre: json['nombre'],
      correo: json['correo'],
      telefono: json['telefono'],
      direccion: json['direccion'],
      rfc: json['rfc'],
      notas: json['notas'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'nombre': nombre,
      'correo': correo,
      'telefono': telefono,
      'direccion': direccion,
      'rfc': rfc,
      'notas': notas,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Cliente copyWith({
    String? id,
    String? usuarioId,
    String? nombre,
    String? correo,
    String? telefono,
    String? direccion,
    String? rfc,
    String? notas,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cliente(
      id: id ?? this.id,
      usuarioId: usuarioId ?? this.usuarioId,
      nombre: nombre ?? this.nombre,
      correo: correo ?? this.correo,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      rfc: rfc ?? this.rfc,
      notas: notas ?? this.notas,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Enums necesarios
enum CombustibleTipo { gasolina, diesel, hibrido, electrico, gas }

extension CombustibleTipoExtension on CombustibleTipo {
  String get displayName {
    switch (this) {
      case CombustibleTipo.gasolina:
        return 'Gasolina';
      case CombustibleTipo.diesel:
        return 'Diésel';
      case CombustibleTipo.hibrido:
        return 'Híbrido';
      case CombustibleTipo.electrico:
        return 'Eléctrico';
      case CombustibleTipo.gas:
        return 'Gas';
    }
  }

  static CombustibleTipo fromString(String value) {
    switch (value.toLowerCase()) {
      case 'gasolina':
        return CombustibleTipo.gasolina;
      case 'diesel':
        return CombustibleTipo.diesel;
      case 'hibrido':
        return CombustibleTipo.hibrido;
      case 'electrico':
        return CombustibleTipo.electrico;
      case 'gas':
        return CombustibleTipo.gas;
      default:
        return CombustibleTipo.gasolina;
    }
  }
}
