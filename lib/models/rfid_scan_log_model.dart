enum AccionScan { asignado, reasignado, consultado }

class RfidScanLog {
  final String id;
  final String rfidTagId;
  final String? tecnicoId;
  final String? trabajoId;
  final String? componenteId;
  final AccionScan accion;
  final String? ubicacionGps; // Formato: "POINT(lng lat)"
  final DateTime timestampScan;

  RfidScanLog({
    required this.id,
    required this.rfidTagId,
    this.tecnicoId,
    this.trabajoId,
    this.componenteId,
    required this.accion,
    this.ubicacionGps,
    required this.timestampScan,
  });

  factory RfidScanLog.fromJson(Map<String, dynamic> json) {
    return RfidScanLog(
      id: json['id'] as String,
      rfidTagId: json['rfid_tag_id'] as String,
      tecnicoId: json['tecnico_id'] as String?,
      trabajoId: json['trabajo_id'] as String?,
      componenteId: json['componente_id'] as String?,
      accion: _parseAccion(json['accion'] as String),
      ubicacionGps: json['ubicacion_gps'] as String?,
      timestampScan: DateTime.parse(json['timestamp_scan'] as String),
    );
  }

  static AccionScan _parseAccion(String accion) {
    switch (accion) {
      case 'asignado':
        return AccionScan.asignado;
      case 'reasignado':
        return AccionScan.reasignado;
      case 'consultado':
        return AccionScan.consultado;
      default:
        return AccionScan.consultado;
    }
  }

  String get accionString {
    switch (accion) {
      case AccionScan.asignado:
        return 'asignado';
      case AccionScan.reasignado:
        return 'reasignado';
      case AccionScan.consultado:
        return 'consultado';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rfid_tag_id': rfidTagId,
      'tecnico_id': tecnicoId,
      'trabajo_id': trabajoId,
      'componente_id': componenteId,
      'accion': accionString,
      'ubicacion_gps': ubicacionGps,
      'timestamp_scan': timestampScan.toIso8601String(),
    };
  }
}
