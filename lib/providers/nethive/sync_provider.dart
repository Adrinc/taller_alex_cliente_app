import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nethive_neo/helpers/globals.dart';

/// Provider para gestionar sincronización offline y estado de conectividad
class SyncProvider extends ChangeNotifier {
  // Estado de conectividad
  bool isOnline = true;
  bool isSyncing = false;
  DateTime? lastSyncTime;

  // Cola de sincronización
  List<SyncOperation> syncQueue = [];
  List<String> syncErrors = [];

  // Configuración de sincronización
  bool syncOnlyWifi = false;
  bool autoSync = true;
  int maxRetries = 3;

  // Variable para controlar si el provider está activo
  bool _isDisposed = false;

  SyncProvider() {
    loadSyncPreferences();
    checkConnectivity();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _notifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  /// Cargar preferencias de sincronización
  Future<void> loadSyncPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      syncOnlyWifi = prefs.getBool('sync_only_wifi') ?? false;
      autoSync = prefs.getBool('auto_sync') ?? true;
      maxRetries = prefs.getInt('max_retries') ?? 3;

      final lastSyncString = prefs.getString('last_sync_time');
      if (lastSyncString != null) {
        lastSyncTime = DateTime.parse(lastSyncString);
      }

      _notifyListeners();
    } catch (e) {
      print('SyncProvider: Error cargando preferencias: $e');
    }
  }

  /// Guardar preferencias de sincronización
  Future<void> saveSyncPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sync_only_wifi', syncOnlyWifi);
      await prefs.setBool('auto_sync', autoSync);
      await prefs.setInt('max_retries', maxRetries);

      if (lastSyncTime != null) {
        await prefs.setString(
            'last_sync_time', lastSyncTime!.toIso8601String());
      }
    } catch (e) {
      print('SyncProvider: Error guardando preferencias: $e');
    }
  }

  /// Verificar conectividad
  Future<void> checkConnectivity() async {
    try {
      // TODO: Implementar verificación real de conectividad
      // Por ahora simulamos conectividad
      isOnline = true;
      _notifyListeners();
    } catch (e) {
      print('SyncProvider: Error verificando conectividad: $e');
      isOnline = false;
      _notifyListeners();
    }
  }

  /// Agregar operación a la cola de sincronización
  Future<void> addToSyncQueue({
    required SyncOperationType type,
    required String tableName,
    required Map<String, dynamic> data,
    String? recordId,
  }) async {
    try {
      final operation = SyncOperation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: type,
        tableName: tableName,
        data: data,
        recordId: recordId,
        timestamp: DateTime.now(),
        retryCount: 0,
      );

      syncQueue.add(operation);
      _notifyListeners();

      // Guardar cola en almacenamiento local
      await saveSyncQueue();

      // Si está online y auto-sync está activado, intentar sincronizar
      if (isOnline && autoSync) {
        syncAll();
      }

      print(
          'SyncProvider: Operación agregada a cola: ${type.name} en $tableName');
    } catch (e) {
      print('SyncProvider: Error agregando operación a cola: $e');
    }
  }

  /// Sincronizar toda la cola
  Future<void> syncAll() async {
    if (isSyncing || !isOnline || syncQueue.isEmpty) return;

    try {
      isSyncing = true;
      syncErrors.clear();
      _notifyListeners();

      print(
          'SyncProvider: Iniciando sincronización de ${syncQueue.length} operaciones...');

      final operationsToSync = List<SyncOperation>.from(syncQueue);

      for (final operation in operationsToSync) {
        final success = await _syncOperation(operation);

        if (success) {
          syncQueue.remove(operation);
          print('SyncProvider: Operación sincronizada: ${operation.id}');
        } else {
          operation.retryCount++;
          if (operation.retryCount >= maxRetries) {
            syncQueue.remove(operation);
            syncErrors.add(
                'Falló operación ${operation.type.name} después de $maxRetries intentos');
            print(
                'SyncProvider: Operación fallida permanentemente: ${operation.id}');
          }
        }
      }

      lastSyncTime = DateTime.now();
      await saveSyncQueue();
      await saveSyncPreferences();

      print(
          'SyncProvider: Sincronización completada. Cola restante: ${syncQueue.length}');
    } catch (e) {
      print('SyncProvider: Error en sincronización: $e');
      syncErrors.add('Error general de sincronización: $e');
    } finally {
      isSyncing = false;
      _notifyListeners();
    }
  }

  /// Sincronizar una operación específica
  Future<bool> _syncOperation(SyncOperation operation) async {
    try {
      print('SyncProvider: Sincronizando operación ${operation.type.name}...');

      switch (operation.type) {
        case SyncOperationType.create:
          final response = await supabaseLU
              .from(operation.tableName)
              .insert(operation.data)
              .select();
          return response.isNotEmpty;

        case SyncOperationType.update:
          if (operation.recordId == null) return false;
          final response = await supabaseLU
              .from(operation.tableName)
              .update(operation.data)
              .eq('id', operation.recordId!)
              .select();
          return response.isNotEmpty;

        case SyncOperationType.delete:
          if (operation.recordId == null) return false;
          await supabaseLU
              .from(operation.tableName)
              .delete()
              .eq('id', operation.recordId!);
          return true;

        case SyncOperationType.uploadFile:
          return await _syncFileUpload(operation);
      }
    } catch (e) {
      print('SyncProvider: Error sincronizando operación ${operation.id}: $e');
      return false;
    }
  }

  /// Sincronizar subida de archivo
  Future<bool> _syncFileUpload(SyncOperation operation) async {
    try {
      final fileName = operation.data['fileName'] as String?;
      final bucketName = operation.data['bucket'] as String?;
      final fileData = operation.data['fileData'] as Uint8List?;

      if (fileName == null || bucketName == null || fileData == null) {
        return false;
      }

      await supabaseLU.storage
          .from(bucketName)
          .uploadBinary(fileName, fileData);

      return true;
    } catch (e) {
      print('SyncProvider: Error subiendo archivo: $e');
      return false;
    }
  }

  /// Guardar cola de sincronización en almacenamiento local
  Future<void> saveSyncQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = syncQueue.map((op) => op.toJson()).toList();
      await prefs.setString('sync_queue', queueJson.toString());
    } catch (e) {
      print('SyncProvider: Error guardando cola: $e');
    }
  }

  /// Cargar cola de sincronización desde almacenamiento local
  Future<void> loadSyncQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueString = prefs.getString('sync_queue');
      if (queueString != null) {
        // TODO: Implementar deserialización de la cola
        // syncQueue = parseQueueFromString(queueString);
      }
      _notifyListeners();
    } catch (e) {
      print('SyncProvider: Error cargando cola: $e');
    }
  }

  /// Limpiar errores de sincronización
  void clearSyncErrors() {
    syncErrors.clear();
    _notifyListeners();
  }

  /// Limpiar cola de sincronización
  void clearSyncQueue() {
    syncQueue.clear();
    saveSyncQueue();
    _notifyListeners();
  }

  /// Obtener operaciones pendientes por tabla
  List<SyncOperation> getPendingOperations(String tableName) {
    return syncQueue.where((op) => op.tableName == tableName).toList();
  }

  /// Setters para configuración
  void setSyncOnlyWifi(bool value) {
    syncOnlyWifi = value;
    saveSyncPreferences();
    _notifyListeners();
  }

  void setAutoSync(bool value) {
    autoSync = value;
    saveSyncPreferences();
    _notifyListeners();
  }

  void setMaxRetries(int value) {
    maxRetries = value;
    saveSyncPreferences();
    _notifyListeners();
  }

  /// Forzar sincronización manual
  Future<void> forcSync() async {
    await checkConnectivity();
    if (isOnline) {
      await syncAll();
    }
  }
}

/// Operación de sincronización
class SyncOperation {
  final String id;
  final SyncOperationType type;
  final String tableName;
  final Map<String, dynamic> data;
  final String? recordId;
  final DateTime timestamp;
  int retryCount;

  SyncOperation({
    required this.id,
    required this.type,
    required this.tableName,
    required this.data,
    this.recordId,
    required this.timestamp,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'tableName': tableName,
      'data': data,
      'recordId': recordId,
      'timestamp': timestamp.toIso8601String(),
      'retryCount': retryCount,
    };
  }

  factory SyncOperation.fromJson(Map<String, dynamic> json) {
    return SyncOperation(
      id: json['id'],
      type: SyncOperationType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      tableName: json['tableName'],
      data: json['data'],
      recordId: json['recordId'],
      timestamp: DateTime.parse(json['timestamp']),
      retryCount: json['retryCount'] ?? 0,
    );
  }
}

/// Tipos de operaciones de sincronización
enum SyncOperationType {
  create,
  update,
  delete,
  uploadFile,
}
