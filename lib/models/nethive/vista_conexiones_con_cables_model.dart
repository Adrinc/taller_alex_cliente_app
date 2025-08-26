class VistaConexionesConCables {
  final String conexionId;
  final String? descripcion;
  final bool activo;
  final String origenId;
  final String componenteOrigen;
  final String destinoId;
  final String componenteDestino;
  final String? cableId;
  final String? cableUsado;
  final String? tipoCable;
  final String? color;
  final double? tamano;
  final String? tipoConector;
  final String? rfidOrigenLegacy;
  final String? rfidDestinoLegacy;
  final String? rfidCableLegacy;

  VistaConexionesConCables({
    required this.conexionId,
    this.descripcion,
    required this.activo,
    required this.origenId,
    required this.componenteOrigen,
    required this.destinoId,
    required this.componenteDestino,
    this.cableId,
    this.cableUsado,
    this.tipoCable,
    this.color,
    this.tamano,
    this.tipoConector,
    this.rfidOrigenLegacy,
    this.rfidDestinoLegacy,
    this.rfidCableLegacy,
  });

  factory VistaConexionesConCables.fromMap(Map<String, dynamic> map) {
    return VistaConexionesConCables(
      conexionId: map['conexion_id'] ?? '',
      descripcion: map['descripcion'],
      activo: map['activo'] ?? true,
      origenId: map['origen_id'] ?? '',
      componenteOrigen: map['componente_origen'] ?? '',
      destinoId: map['destino_id'] ?? '',
      componenteDestino: map['componente_destino'] ?? '',
      cableId: map['cable_id'],
      cableUsado: map['cable_usado'],
      tipoCable: map['tipo_cable'],
      color: map['color'],
      tamano: map['tamaño'] != null
          ? double.tryParse(map['tamaño'].toString())
          : null,
      tipoConector: map['tipo_conector'],
      rfidOrigenLegacy: map['rfid_origen_legacy'],
      rfidDestinoLegacy: map['rfid_destino_legacy'],
      rfidCableLegacy: map['rfid_cable_legacy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'conexion_id': conexionId,
      'descripcion': descripcion,
      'activo': activo,
      'origen_id': origenId,
      'componente_origen': componenteOrigen,
      'destino_id': destinoId,
      'componente_destino': componenteDestino,
      'cable_id': cableId,
      'cable_usado': cableUsado,
      'tipo_cable': tipoCable,
      'color': color,
      'tamaño': tamano,
      'tipo_conector': tipoConector,
      'rfid_origen_legacy': rfidOrigenLegacy,
      'rfid_destino_legacy': rfidDestinoLegacy,
      'rfid_cable_legacy': rfidCableLegacy,
    };
  }

  // Getter para determinar si la conexión está completa (tiene cable)
  bool get isCompleteConnection => cableId != null && cableUsado != null;

  // Getter para obtener una descripción completa de la conexión
  String get connectionDescription {
    String desc = '$componenteOrigen → $componenteDestino';
    if (cableUsado != null) {
      desc += ' (via $cableUsado)';
    }
    return desc;
  }

  // Getter para el estado de la conexión
  String get connectionStatus {
    if (!activo) return 'Inactiva';
    if (!isCompleteConnection) return 'Pendiente';
    return 'Completada';
  }

  // Getter para RFID del origen (usando legacy)
  String? get rfidOrigen => rfidOrigenLegacy;

  // Getter para RFID del destino (usando legacy)
  String? get rfidDestino => rfidDestinoLegacy;

  // Getter para RFID del cable (usando legacy)
  String? get rfidCable => rfidCableLegacy;
}
