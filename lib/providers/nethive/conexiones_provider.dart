import 'package:flutter/material.dart';
import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/models/nethive/componente_model.dart';
import 'package:nethive_neo/models/nethive/conexion_componente_model.dart';

/// Provider para gestionar conexiones entre componentes
class ConexionesProvider extends ChangeNotifier {
  // Listas de conexiones
  List<ConexionComponente> conexionesDatos = [];
  List<ConexionComponente> conexionesEnergia = [];

  // Variables para crear conexión
  Componente? componenteOrigen;
  Componente? componenteDestino;
  Componente? cableSeleccionado;
  String? puertoOrigen;
  String? puertoDestino;
  ConexionType tipoConexion = ConexionType.datos;

  // Variables de búsqueda y filtros
  final busquedaOrigenController = TextEditingController();
  final busquedaDestinoController = TextEditingController();
  final busquedaCableController = TextEditingController();

  String? negocioSeleccionadoId;
  bool _isDisposed = false;

  ConexionesProvider();

  @override
  void dispose() {
    _isDisposed = true;
    busquedaOrigenController.dispose();
    busquedaDestinoController.dispose();
    busquedaCableController.dispose();
    super.dispose();
  }

  void _notifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  /// Obtener conexiones de datos
  Future<void> getConexionesDatos({String? negocioId}) async {
    if (negocioId == null) return;

    try {
      print('ConexionesProvider: Obteniendo conexiones de datos...');

      final response = await supabaseLU
          .from('conexion_componente')
          .select('''
            *,
            componente_origen:componente_origen_id(*),
            componente_destino:componente_destino_id(*),
            cable:cable_id(*)
          ''')
          .eq('tipo_conexion', 'datos')
          .eq('negocio_id', negocioId)
          .order('fecha_creacion', ascending: false);

      if (response.isNotEmpty) {
        conexionesDatos = response
            .map<ConexionComponente>(
                (json) => ConexionComponente.fromJson(json))
            .toList();
        _notifyListeners();
        print(
            'ConexionesProvider: ${conexionesDatos.length} conexiones de datos obtenidas');
      } else {
        conexionesDatos = [];
        _notifyListeners();
      }
    } catch (e) {
      print('ConexionesProvider: Error obteniendo conexiones de datos: $e');
      conexionesDatos = [];
      _notifyListeners();
    }
  }

  /// Obtener conexiones de energía
  Future<void> getConexionesEnergia({String? negocioId}) async {
    if (negocioId == null) return;

    try {
      print('ConexionesProvider: Obteniendo conexiones de energía...');

      final response = await supabaseLU
          .from('conexion_componente')
          .select('''
            *,
            componente_origen:componente_origen_id(*),
            componente_destino:componente_destino_id(*),
            cable:cable_id(*)
          ''')
          .eq('tipo_conexion', 'energia')
          .eq('negocio_id', negocioId)
          .order('fecha_creacion', ascending: false);

      if (response.isNotEmpty) {
        conexionesEnergia = response
            .map<ConexionComponente>(
                (json) => ConexionComponente.fromJson(json))
            .toList();
        _notifyListeners();
        print(
            'ConexionesProvider: ${conexionesEnergia.length} conexiones de energía obtenidas');
      } else {
        conexionesEnergia = [];
        _notifyListeners();
      }
    } catch (e) {
      print('ConexionesProvider: Error obteniendo conexiones de energía: $e');
      conexionesEnergia = [];
      _notifyListeners();
    }
  }

  /// Crear nueva conexión
  Future<bool> createConexion({
    required String componenteOrigenId,
    required String componenteDestinoId,
    String? cableId,
    String? puertoOrigen,
    String? puertoDestino,
    required ConexionType tipo,
    String? descripcion,
  }) async {
    try {
      print('ConexionesProvider: Creando conexión ${tipo.name}...');

      // Validar que los puertos no estén ocupados
      final validacion = await validarPuertos(componenteOrigenId,
          componenteDestinoId, puertoOrigen, puertoDestino, tipo);

      if (!validacion.isValid) {
        print(
            'ConexionesProvider: Error de validación: ${validacion.errorMessage}');
        return false;
      }

      final conexionData = {
        'componente_origen_id': componenteOrigenId,
        'componente_destino_id': componenteDestinoId,
        'cable_id': cableId,
        'puerto_origen': puertoOrigen,
        'puerto_destino': puertoDestino,
        'tipo_conexion': tipo.name,
        'descripcion': descripcion,
        'negocio_id': negocioSeleccionadoId,
        'activo': true,
        'fecha_creacion': DateTime.now().toIso8601String(),
      };

      final response = await supabaseLU
          .from('conexion_componente')
          .insert(conexionData)
          .select();

      if (response.isNotEmpty) {
        // Actualizar listas locales
        if (tipo == ConexionType.datos) {
          await getConexionesDatos(negocioId: negocioSeleccionadoId);
        } else {
          await getConexionesEnergia(negocioId: negocioSeleccionadoId);
        }

        clearForm();
        print('ConexionesProvider: Conexión creada exitosamente');
        return true;
      }
      return false;
    } catch (e) {
      print('ConexionesProvider: Error creando conexión: $e');
      return false;
    }
  }

  /// Validar que los puertos no estén ocupados
  Future<ValidationResult> validarPuertos(
    String componenteOrigenId,
    String componenteDestinoId,
    String? puertoOrigen,
    String? puertoDestino,
    ConexionType tipo,
  ) async {
    try {
      // Validar puerto origen
      if (puertoOrigen != null) {
        final origenOcupado = await supabaseLU
            .from('conexion_componente')
            .select('id')
            .eq('componente_origen_id', componenteOrigenId)
            .eq('puerto_origen', puertoOrigen)
            .eq('tipo_conexion', tipo.name)
            .eq('activo', true)
            .maybeSingle();

        if (origenOcupado != null) {
          return ValidationResult.invalid(
              'Puerto origen $puertoOrigen ya está ocupado');
        }
      }

      // Validar puerto destino
      if (puertoDestino != null) {
        final destinoOcupado = await supabaseLU
            .from('conexion_componente')
            .select('id')
            .eq('componente_destino_id', componenteDestinoId)
            .eq('puerto_destino', puertoDestino)
            .eq('tipo_conexion', tipo.name)
            .eq('activo', true)
            .maybeSingle();

        if (destinoOcupado != null) {
          return ValidationResult.invalid(
              'Puerto destino $puertoDestino ya está ocupado');
        }
      }

      return ValidationResult.valid();
    } catch (e) {
      return ValidationResult.invalid('Error validando puertos: $e');
    }
  }

  /// Eliminar conexión
  Future<bool> deleteConexion(String conexionId, ConexionType tipo) async {
    try {
      print('ConexionesProvider: Eliminando conexión $conexionId...');

      await supabaseLU
          .from('conexion_componente')
          .update({'activo': false}).eq('id', conexionId);

      // Actualizar listas locales
      if (tipo == ConexionType.datos) {
        await getConexionesDatos(negocioId: negocioSeleccionadoId);
      } else {
        await getConexionesEnergia(negocioId: negocioSeleccionadoId);
      }

      print('ConexionesProvider: Conexión eliminada exitosamente');
      return true;
    } catch (e) {
      print('ConexionesProvider: Error eliminando conexión: $e');
      return false;
    }
  }

  /// Buscar componentes para origen/destino
  Future<List<Componente>> buscarComponentes(String query, String tipo) async {
    try {
      final response = await supabaseLU
          .from('componente')
          .select('*, categoria_componente(*)')
          .eq('negocio_id', negocioSeleccionadoId)
          .or('nombre.ilike.%$query%,descripcion.ilike.%$query%')
          .eq('activo', true)
          .limit(20);

      if (response.isNotEmpty) {
        return response
            .map<Componente>((json) => Componente.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print('ConexionesProvider: Error buscando componentes: $e');
      return [];
    }
  }

  /// Obtener puertos disponibles de un componente
  Future<List<String>> getPuertosDisponibles(
      String componenteId, ConexionType tipo) async {
    try {
      // TODO: Implementar lógica para obtener puertos según el tipo de componente
      // Por ahora retornamos puertos genéricos
      return List.generate(24, (index) => 'Puerto ${index + 1}');
    } catch (e) {
      print('ConexionesProvider: Error obteniendo puertos: $e');
      return [];
    }
  }

  /// Limpiar formulario
  void clearForm() {
    componenteOrigen = null;
    componenteDestino = null;
    cableSeleccionado = null;
    puertoOrigen = null;
    puertoDestino = null;
    busquedaOrigenController.clear();
    busquedaDestinoController.clear();
    busquedaCableController.clear();
    _notifyListeners();
  }

  /// Setters
  void setNegocioSeleccionado(String? negocioId) {
    negocioSeleccionadoId = negocioId;
    if (negocioId != null) {
      getConexionesDatos(negocioId: negocioId);
      getConexionesEnergia(negocioId: negocioId);
    }
    _notifyListeners();
  }

  void setTipoConexion(ConexionType tipo) {
    tipoConexion = tipo;
    _notifyListeners();
  }

  void setComponenteOrigen(Componente componente) {
    componenteOrigen = componente;
    puertoOrigen = null; // Reset puerto cuando cambia componente
    _notifyListeners();
  }

  void setComponenteDestino(Componente componente) {
    componenteDestino = componente;
    puertoDestino = null; // Reset puerto cuando cambia componente
    _notifyListeners();
  }

  void setCableSeleccionado(Componente cable) {
    cableSeleccionado = cable;
    _notifyListeners();
  }

  void setPuertoOrigen(String puerto) {
    puertoOrigen = puerto;
    _notifyListeners();
  }

  void setPuertoDestino(String puerto) {
    puertoDestino = puerto;
    _notifyListeners();
  }
}

/// Tipos de conexión
enum ConexionType { datos, energia }

/// Resultado de validación
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  ValidationResult._(this.isValid, this.errorMessage);

  factory ValidationResult.valid() {
    return ValidationResult._(true, null);
  }

  factory ValidationResult.invalid(String message) {
    return ValidationResult._(false, message);
  }
}
