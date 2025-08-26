import 'dart:convert';

class VistaAlimentacionComponentes {
  final String componenteId;
  final String componenteNombre;
  final String ubicacion;
  final String negocioId;
  final String negocioNombre;
  final String categoriaId;
  final String categoriaNombre;
  final String rolLogicoId;
  final String rolLogicoNombre;
  final bool requiereAlimentacion;
  final double? potenciaMaximaWatts;
  final String? voltajeOperacion;
  final String? amperajeMaximo;
  final List<ConexionAlimentacionInfo> conexionesAlimentacion;
  final bool tieneAlimentacionCompleta;
  final int totalConexionesAlimentacion;
  final DateTime fechaCreacion;
  final DateTime? fechaModificacion;

  VistaAlimentacionComponentes({
    required this.componenteId,
    required this.componenteNombre,
    required this.ubicacion,
    required this.negocioId,
    required this.negocioNombre,
    required this.categoriaId,
    required this.categoriaNombre,
    required this.rolLogicoId,
    required this.rolLogicoNombre,
    required this.requiereAlimentacion,
    this.potenciaMaximaWatts,
    this.voltajeOperacion,
    this.amperajeMaximo,
    required this.conexionesAlimentacion,
    required this.tieneAlimentacionCompleta,
    required this.totalConexionesAlimentacion,
    required this.fechaCreacion,
    this.fechaModificacion,
  });

  factory VistaAlimentacionComponentes.fromMap(Map<String, dynamic> map) {
    // Procesar las conexiones de alimentación si vienen como JSON
    List<ConexionAlimentacionInfo> conexiones = [];
    if (map['conexiones_alimentacion'] != null) {
      if (map['conexiones_alimentacion'] is String) {
        // Si viene como JSON string
        final List<dynamic> conexionesJson =
            json.decode(map['conexiones_alimentacion']);
        conexiones = conexionesJson
            .map((c) => ConexionAlimentacionInfo.fromMap(c))
            .toList();
      } else if (map['conexiones_alimentacion'] is List) {
        // Si viene como lista directa
        conexiones = (map['conexiones_alimentacion'] as List)
            .map((c) => ConexionAlimentacionInfo.fromMap(c))
            .toList();
      }
    }

    return VistaAlimentacionComponentes(
      componenteId: map['componente_id']?.toString() ?? '',
      componenteNombre: map['componente_nombre']?.toString() ?? '',
      ubicacion: map['ubicacion']?.toString() ?? '',
      negocioId: map['negocio_id']?.toString() ?? '',
      negocioNombre: map['negocio_nombre']?.toString() ?? '',
      categoriaId: map['categoria_id']?.toString() ?? '',
      categoriaNombre: map['categoria_nombre']?.toString() ?? '',
      rolLogicoId: map['rol_logico_id']?.toString() ?? '',
      rolLogicoNombre: map['rol_logico_nombre']?.toString() ?? '',
      requiereAlimentacion: map['requiere_alimentacion'] == true,
      potenciaMaximaWatts: map['potencia_maxima_watts']?.toDouble(),
      voltajeOperacion: map['voltaje_operacion']?.toString(),
      amperajeMaximo: map['amperaje_maximo']?.toString(),
      conexionesAlimentacion: conexiones,
      tieneAlimentacionCompleta: map['tiene_alimentacion_completa'] == true,
      totalConexionesAlimentacion:
          map['total_conexiones_alimentacion']?.toInt() ?? 0,
      fechaCreacion: DateTime.parse(map['fecha_creacion'].toString()),
      fechaModificacion: map['fecha_modificacion'] != null
          ? DateTime.parse(map['fecha_modificacion'].toString())
          : null,
    );
  }

  factory VistaAlimentacionComponentes.fromJson(String source) =>
      VistaAlimentacionComponentes.fromMap(json.decode(source));

  Map<String, dynamic> toMap() {
    return {
      'componente_id': componenteId,
      'componente_nombre': componenteNombre,
      'ubicacion': ubicacion,
      'negocio_id': negocioId,
      'negocio_nombre': negocioNombre,
      'categoria_id': categoriaId,
      'categoria_nombre': categoriaNombre,
      'rol_logico_id': rolLogicoId,
      'rol_logico_nombre': rolLogicoNombre,
      'requiere_alimentacion': requiereAlimentacion,
      'potencia_maxima_watts': potenciaMaximaWatts,
      'voltaje_operacion': voltajeOperacion,
      'amperaje_maximo': amperajeMaximo,
      'conexiones_alimentacion':
          conexionesAlimentacion.map((c) => c.toMap()).toList(),
      'tiene_alimentacion_completa': tieneAlimentacionCompleta,
      'total_conexiones_alimentacion': totalConexionesAlimentacion,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_modificacion': fechaModificacion?.toIso8601String(),
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'VistaAlimentacionComponentes(componenteId: $componenteId, nombre: $componenteNombre, requiereAlimentacion: $requiereAlimentacion, tieneAlimentacionCompleta: $tieneAlimentacionCompleta)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VistaAlimentacionComponentes &&
        other.componenteId == componenteId;
  }

  @override
  int get hashCode => componenteId.hashCode;

  // Métodos de utilidad
  String get estadoAlimentacion {
    if (!requiereAlimentacion) return 'No requiere';
    if (tieneAlimentacionCompleta) return 'Completa';
    if (totalConexionesAlimentacion > 0) return 'Parcial';
    return 'Sin alimentación';
  }

  double get porcentajeAlimentacion {
    if (!requiereAlimentacion) return 100.0;
    if (totalConexionesAlimentacion == 0) return 0.0;
    return tieneAlimentacionCompleta
        ? 100.0
        : 50.0; // Simplificado, puede ser más complejo
  }

  bool get necesitaAtencion =>
      requiereAlimentacion && !tieneAlimentacionCompleta;
}

class ConexionAlimentacionInfo {
  final String conexionId;
  final String origenId;
  final String origenNombre;
  final String? cableId;
  final String? cableNombre;
  final String? rfidCable;
  final bool activo;
  final String? tecnicoId;
  final DateTime fechaCreacion;

  ConexionAlimentacionInfo({
    required this.conexionId,
    required this.origenId,
    required this.origenNombre,
    this.cableId,
    this.cableNombre,
    this.rfidCable,
    required this.activo,
    this.tecnicoId,
    required this.fechaCreacion,
  });

  factory ConexionAlimentacionInfo.fromMap(Map<String, dynamic> map) {
    return ConexionAlimentacionInfo(
      conexionId: map['conexion_id']?.toString() ?? '',
      origenId: map['origen_id']?.toString() ?? '',
      origenNombre: map['origen_nombre']?.toString() ?? '',
      cableId: map['cable_id']?.toString(),
      cableNombre: map['cable_nombre']?.toString(),
      rfidCable: map['rfid_cable']?.toString(),
      activo: map['activo'] == true,
      tecnicoId: map['tecnico_id']?.toString(),
      fechaCreacion: DateTime.parse(map['fecha_creacion'].toString()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'conexion_id': conexionId,
      'origen_id': origenId,
      'origen_nombre': origenNombre,
      'cable_id': cableId,
      'cable_nombre': cableNombre,
      'rfid_cable': rfidCable,
      'activo': activo,
      'tecnico_id': tecnicoId,
      'fecha_creacion': fechaCreacion.toIso8601String(),
    };
  }

  bool get tieneRfid => rfidCable != null && rfidCable!.isNotEmpty;
  String get estado =>
      activo ? (tieneRfid ? 'Completada' : 'Pendiente') : 'Inactiva';
}
