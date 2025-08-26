import 'dart:convert';

class VistaCablesEnUso {
  final String cableId;
  final String cableNombre;
  final String? rfidCable;
  final String tipoCableId;
  final String tipoCableNombre;
  final double? longitud;
  final String? color;
  final String? especificaciones;
  final String negocioId;
  final String negocioNombre;
  final bool enUso;
  final int totalConexiones;
  final List<ConexionCableInfo> conexiones;
  final DateTime fechaCreacion;
  final DateTime? fechaModificacion;

  VistaCablesEnUso({
    required this.cableId,
    required this.cableNombre,
    this.rfidCable,
    required this.tipoCableId,
    required this.tipoCableNombre,
    this.longitud,
    this.color,
    this.especificaciones,
    required this.negocioId,
    required this.negocioNombre,
    required this.enUso,
    required this.totalConexiones,
    required this.conexiones,
    required this.fechaCreacion,
    this.fechaModificacion,
  });

  factory VistaCablesEnUso.fromMap(Map<String, dynamic> map) {
    // Procesar las conexiones si vienen como JSON
    List<ConexionCableInfo> conexionesList = [];
    if (map['conexiones'] != null) {
      if (map['conexiones'] is String) {
        // Si viene como JSON string
        final List<dynamic> conexionesJson = json.decode(map['conexiones']);
        conexionesList =
            conexionesJson.map((c) => ConexionCableInfo.fromMap(c)).toList();
      } else if (map['conexiones'] is List) {
        // Si viene como lista directa
        conexionesList = (map['conexiones'] as List)
            .map((c) => ConexionCableInfo.fromMap(c))
            .toList();
      }
    }

    return VistaCablesEnUso(
      cableId: map['cable_id']?.toString() ?? '',
      cableNombre: map['cable_nombre']?.toString() ?? '',
      rfidCable: map['rfid_cable']?.toString(),
      tipoCableId: map['tipo_cable_id']?.toString() ?? '',
      tipoCableNombre: map['tipo_cable_nombre']?.toString() ?? '',
      longitud: map['longitud']?.toDouble(),
      color: map['color']?.toString(),
      especificaciones: map['especificaciones']?.toString(),
      negocioId: map['negocio_id']?.toString() ?? '',
      negocioNombre: map['negocio_nombre']?.toString() ?? '',
      enUso: map['en_uso'] == true,
      totalConexiones: map['total_conexiones']?.toInt() ?? 0,
      conexiones: conexionesList,
      fechaCreacion: DateTime.parse(map['fecha_creacion'].toString()),
      fechaModificacion: map['fecha_modificacion'] != null
          ? DateTime.parse(map['fecha_modificacion'].toString())
          : null,
    );
  }

  factory VistaCablesEnUso.fromJson(String source) =>
      VistaCablesEnUso.fromMap(json.decode(source));

  Map<String, dynamic> toMap() {
    return {
      'cable_id': cableId,
      'cable_nombre': cableNombre,
      'rfid_cable': rfidCable,
      'tipo_cable_id': tipoCableId,
      'tipo_cable_nombre': tipoCableNombre,
      'longitud': longitud,
      'color': color,
      'especificaciones': especificaciones,
      'negocio_id': negocioId,
      'negocio_nombre': negocioNombre,
      'en_uso': enUso,
      'total_conexiones': totalConexiones,
      'conexiones': conexiones.map((c) => c.toMap()).toList(),
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_modificacion': fechaModificacion?.toIso8601String(),
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'VistaCablesEnUso(cableId: $cableId, nombre: $cableNombre, enUso: $enUso, totalConexiones: $totalConexiones)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VistaCablesEnUso && other.cableId == cableId;
  }

  @override
  int get hashCode => cableId.hashCode;

  // Métodos de utilidad
  bool get tieneRfid => rfidCable != null && rfidCable!.isNotEmpty;

  String get estado {
    if (enUso) return 'En uso';
    return 'Disponible';
  }

  String get descripcionCompleta {
    String desc = '$cableNombre ($tipoCableNombre)';
    if (longitud != null) desc += ' - ${longitud}m';
    if (color != null) desc += ' - $color';
    return desc;
  }

  double get porcentajeUso {
    if (totalConexiones == 0) return 0.0;
    // Simplificado: asumimos que más de 0 conexiones = en uso al 100%
    return enUso ? 100.0 : 0.0;
  }

  String get estadoDetallado {
    if (!enUso) return 'Disponible para uso';
    if (totalConexiones == 1) return 'En uso (1 conexión)';
    return 'En uso ($totalConexiones conexiones)';
  }
}

class ConexionCableInfo {
  final String conexionId;
  final String tipo; // 'alimentacion' o 'componente'
  final String origenId;
  final String origenNombre;
  final String destinoId;
  final String destinoNombre;
  final bool activo;
  final String? tecnicoId;
  final DateTime fechaCreacion;

  ConexionCableInfo({
    required this.conexionId,
    required this.tipo,
    required this.origenId,
    required this.origenNombre,
    required this.destinoId,
    required this.destinoNombre,
    required this.activo,
    this.tecnicoId,
    required this.fechaCreacion,
  });

  factory ConexionCableInfo.fromMap(Map<String, dynamic> map) {
    return ConexionCableInfo(
      conexionId: map['conexion_id']?.toString() ?? '',
      tipo: map['tipo']?.toString() ?? '',
      origenId: map['origen_id']?.toString() ?? '',
      origenNombre: map['origen_nombre']?.toString() ?? '',
      destinoId: map['destino_id']?.toString() ?? '',
      destinoNombre: map['destino_nombre']?.toString() ?? '',
      activo: map['activo'] == true,
      tecnicoId: map['tecnico_id']?.toString(),
      fechaCreacion: DateTime.parse(map['fecha_creacion'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'conexion_id': conexionId,
      'tipo': tipo,
      'origen_id': origenId,
      'origen_nombre': origenNombre,
      'destino_id': destinoId,
      'destino_nombre': destinoNombre,
      'activo': activo,
      'tecnico_id': tecnicoId,
      'fecha_creacion': fechaCreacion.toIso8601String(),
    };
  }

  String get descripcion => '$origenNombre → $destinoNombre';
  String get estado => activo ? 'Activa' : 'Inactiva';
  bool get esTipoAlimentacion => tipo == 'alimentacion';
  bool get esTipoComponente => tipo == 'componente';
}
