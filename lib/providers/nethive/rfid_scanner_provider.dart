import 'package:flutter/material.dart';
import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/models/nethive/componente_model.dart';

/// Provider para gestionar el escaneo de RFID y las acciones relacionadas
class RfidScannerProvider extends ChangeNotifier {
  // Estado del escáner
  bool isScanning = false;
  bool isConnected = false;
  String? lastScannedRfid;
  DateTime? lastScanTime;

  // Lista de RFIDs escaneados en modo lote
  List<String> batchScannedRfids = [];
  bool isBatchMode = false;

  // Estado de la pistola escáner
  int batteryLevel = 100;
  bool isHidMode = true; // true = HID, false = Bluetooth Serial

  // Variables para controlar si el provider está activo
  bool _isDisposed = false;

  RfidScannerProvider() {
    initializeScanner();
  }

  @override
  void dispose() {
    _isDisposed = true;
    stopScanning();
    super.dispose();
  }

  void _notifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  /// Inicializar el escáner RFID
  Future<void> initializeScanner() async {
    try {
      print('RfidScannerProvider: Inicializando escáner...');
      // TODO: Implementar conexión con pistola escáner
      // Detectar si es HID o Bluetooth Serial
      isConnected = true;
      _notifyListeners();
    } catch (e) {
      print('RfidScannerProvider: Error inicializando escáner: $e');
      isConnected = false;
      _notifyListeners();
    }
  }

  /// Iniciar escaneo de RFID
  Future<void> startScanning() async {
    if (!isConnected) {
      await initializeScanner();
      return;
    }

    try {
      isScanning = true;
      _notifyListeners();

      print('RfidScannerProvider: Escaneo iniciado...');
      // TODO: Implementar lectura continua de RFID
    } catch (e) {
      print('RfidScannerProvider: Error iniciando escaneo: $e');
      isScanning = false;
      _notifyListeners();
    }
  }

  /// Detener escaneo de RFID
  void stopScanning() {
    isScanning = false;
    _notifyListeners();
    print('RfidScannerProvider: Escaneo detenido');
  }

  /// Procesar RFID escaneado
  Future<RfidScanResult> processScannedRfid(String rfidCode) async {
    try {
      lastScannedRfid = rfidCode;
      lastScanTime = DateTime.now();

      // Buscar si el RFID ya está asignado
      final response = await supabaseLU
          .from('componente')
          .select('*, categoria_componente(*)')
          .eq('rfid', rfidCode)
          .maybeSingle();

      if (response != null) {
        // RFID ya está asignado
        final componente = Componente.fromJson(response);
        _notifyListeners();
        return RfidScanResult.assigned(componente);
      } else {
        // RFID no está asignado
        if (isBatchMode) {
          batchScannedRfids.add(rfidCode);
        }
        _notifyListeners();
        return RfidScanResult.unassigned(rfidCode);
      }
    } catch (e) {
      print('RfidScannerProvider: Error procesando RFID: $e');
      return RfidScanResult.error('Error procesando RFID: $e');
    }
  }

  /// Simular escaneo manual (fallback)
  Future<RfidScanResult> manualRfidInput(String rfidCode) async {
    return await processScannedRfid(rfidCode);
  }

  /// Activar/desactivar modo lote
  void toggleBatchMode() {
    isBatchMode = !isBatchMode;
    if (!isBatchMode) {
      batchScannedRfids.clear();
    }
    _notifyListeners();
  }

  /// Limpiar lote de RFIDs
  void clearBatch() {
    batchScannedRfids.clear();
    _notifyListeners();
  }

  /// Remover RFID del lote
  void removeFromBatch(String rfidCode) {
    batchScannedRfids.remove(rfidCode);
    _notifyListeners();
  }

  /// Asignar RFID a componente existente
  Future<bool> assignRfidToComponent(
      String rfidCode, String componenteId) async {
    try {
      print(
          'RfidScannerProvider: Asignando RFID $rfidCode a componente $componenteId...');

      final response = await supabaseLU
          .from('componente')
          .update({'rfid': rfidCode})
          .eq('id', componenteId)
          .select();

      if (response.isNotEmpty) {
        print('RfidScannerProvider: RFID asignado exitosamente');
        return true;
      }
      return false;
    } catch (e) {
      print('RfidScannerProvider: Error asignando RFID: $e');
      return false;
    }
  }

  /// Reasignar RFID a otro componente
  Future<bool> reassignRfid(String rfidCode, String newComponenteId) async {
    try {
      print('RfidScannerProvider: Reasignando RFID $rfidCode...');

      // Primero remover el RFID del componente actual
      await supabaseLU
          .from('componente')
          .update({'rfid': null}).eq('rfid', rfidCode);

      // Luego asignarlo al nuevo componente
      final response = await supabaseLU
          .from('componente')
          .update({'rfid': rfidCode})
          .eq('id', newComponenteId)
          .select();

      if (response.isNotEmpty) {
        print('RfidScannerProvider: RFID reasignado exitosamente');
        return true;
      }
      return false;
    } catch (e) {
      print('RfidScannerProvider: Error reasignando RFID: $e');
      return false;
    }
  }

  /// Configurar modo del escáner
  void setScannerMode(bool hidMode) {
    isHidMode = hidMode;
    _notifyListeners();
    print(
        'RfidScannerProvider: Modo cambiado a ${hidMode ? 'HID' : 'Bluetooth Serial'}');
  }

  /// Actualizar nivel de batería
  void updateBatteryLevel(int level) {
    batteryLevel = level;
    _notifyListeners();
  }
}

/// Resultado del escaneo de RFID
class RfidScanResult {
  final RfidScanStatus status;
  final String? rfidCode;
  final Componente? componente;
  final String? errorMessage;

  RfidScanResult._(
      this.status, this.rfidCode, this.componente, this.errorMessage);

  factory RfidScanResult.assigned(Componente componente) {
    return RfidScanResult._(
        RfidScanStatus.assigned, componente.rfid, componente, null);
  }

  factory RfidScanResult.unassigned(String rfidCode) {
    return RfidScanResult._(RfidScanStatus.unassigned, rfidCode, null, null);
  }

  factory RfidScanResult.error(String errorMessage) {
    return RfidScanResult._(RfidScanStatus.error, null, null, errorMessage);
  }
}

enum RfidScanStatus {
  assigned, // RFID ya está asignado a un componente
  unassigned, // RFID no está asignado
  error // Error en el escaneo
}
