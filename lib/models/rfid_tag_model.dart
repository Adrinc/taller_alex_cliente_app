class RfidTag {
  final String id;
  final String codigo;
  final bool activo;
  final String? nota;
  final DateTime createdAt;

  RfidTag({
    required this.id,
    required this.codigo,
    required this.activo,
    this.nota,
    required this.createdAt,
  });

  factory RfidTag.fromJson(Map<String, dynamic> json) {
    return RfidTag(
      id: json['id'] as String,
      codigo: json['codigo'] as String,
      activo: json['activo'] as bool,
      nota: json['nota'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'activo': activo,
      'nota': nota,
      'created_at': createdAt.toIso8601String(),
    };
  }

  RfidTag copyWith({
    String? id,
    String? codigo,
    bool? activo,
    String? nota,
    DateTime? createdAt,
  }) {
    return RfidTag(
      id: id ?? this.id,
      codigo: codigo ?? this.codigo,
      activo: activo ?? this.activo,
      nota: nota ?? this.nota,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
