import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:nethive_neo/models/nethive/distribucion_model.dart';
import 'package:nethive_neo/models/nethive/tipo_distribucion_model.dart';
import 'package:nethive_neo/helpers/globals.dart';

class DistribucionesProvider extends ChangeNotifier {
  final List<Distribucion> _distribuciones = [];
  final List<TipoDistribucion> _tiposDistribucion = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Distribucion> get distribuciones => _distribuciones;
  List<TipoDistribucion> get tiposDistribucion => _tiposDistribucion;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Limpiar estado
  void clearState() {
    _distribuciones.clear();
    _tiposDistribucion.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  // Cargar tipos de distribución disponibles
  Future<void> loadTiposDistribucion() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Cargando tipos de distribución...');

      final response = await supabaseLU
          .from('tipo_distribucion')
          .select('*')
          .order('nombre');

      _tiposDistribucion.clear();
      for (final item in response) {
        _tiposDistribucion.add(TipoDistribucion.fromMap(item));
      }

      print('Tipos de distribución cargados: ${_tiposDistribucion.length}');
    } catch (e) {
      _error = 'Error al cargar tipos de distribución: $e';
      print('Error loadTiposDistribucion: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar distribuciones por negocio
  Future<void> loadDistribucionesByNegocio(String negocioId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Cargando distribuciones para negocio: $negocioId');

      final response = await supabaseLU
          .from('distribucion')
          .select('*')
          .eq('negocio_id', negocioId)
          .order('nombre');

      _distribuciones.clear();
      for (final item in response) {
        _distribuciones.add(Distribucion.fromMap(item));
      }

      print('Distribuciones cargadas: ${_distribuciones.length}');
    } catch (e) {
      _error = 'Error al cargar distribuciones: $e';
      print('Error loadDistribucionesByNegocio: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Crear nueva distribución
  Future<bool> createDistribucion({
    required String negocioId,
    required int tipoId,
    required String nombre,
    String? descripcion,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Creando distribución: $nombre (tipoId: $tipoId)');

      final uuid = const Uuid();
      final newDistribucion = Distribucion(
        id: uuid.v4(),
        negocioId: negocioId,
        tipoId: tipoId,
        nombre: nombre,
        descripcion: descripcion,
      );

      print('Negocio ID: $negocioId');
      print('Distribución ID: ${newDistribucion.id}');
      print('Descripción: $descripcion');
      print('tipo_id: $tipoId');

      await supabaseLU.from('distribucion').insert(newDistribucion.toMap());

      // Agregar a la lista local
      _distribuciones.add(newDistribucion);

      print('Distribución creada exitosamente: ${newDistribucion.id}');
      return true;
    } catch (e) {
      _error = 'Error al crear distribución: $e';
      print('Error createDistribucion: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actualizar distribución existente
  Future<bool> updateDistribucion({
    required String id,
    required int tipoId,
    required String nombre,
    String? descripcion,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Actualizando distribución: $id');

      await supabaseLU.from('distribucion').update({
        'tipo_id': tipoId,
        'nombre': nombre,
        'descripcion': descripcion,
      }).eq('id', id);

      // Actualizar en la lista local
      final index = _distribuciones.indexWhere((d) => d.id == id);
      if (index != -1) {
        final distribucionActualizada = Distribucion(
          id: id,
          negocioId: _distribuciones[index].negocioId,
          tipoId: tipoId,
          nombre: nombre,
          descripcion: descripcion,
        );
        _distribuciones[index] = distribucionActualizada;
      }

      print('Distribución actualizada exitosamente');
      return true;
    } catch (e) {
      _error = 'Error al actualizar distribución: $e';
      print('Error updateDistribucion: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Eliminar distribución (solo si no tiene componentes)
  Future<bool> deleteDistribucion(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      print('Verificando si la distribución $id tiene componentes...');

      // Verificar si tiene componentes asignados
      final componentesResponse = await supabaseLU
          .from('componente')
          .select('id')
          .eq('distribucion_id', id);

      if (componentesResponse.length > 0) {
        _error =
            'No se puede eliminar la distribución porque tiene ${componentesResponse.length} componente(s) asignado(s)';
        print(_error);
        return false;
      }

      print('Eliminando distribución: $id');

      await supabaseLU.from('distribucion').delete().eq('id', id);

      // Remover de la lista local
      _distribuciones.removeWhere((d) => d.id == id);

      print('Distribución eliminada exitosamente');
      return true;
    } catch (e) {
      _error = 'Error al eliminar distribución: $e';
      print('Error deleteDistribucion: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener distribución por ID
  Distribucion? getDistribucionById(String id) {
    try {
      return _distribuciones.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  // Verificar si un nombre ya existe en el negocio
  bool nombreExists(String nombre, String negocioId, {String? excludeId}) {
    return _distribuciones.any((d) =>
        d.nombre.toLowerCase() == nombre.toLowerCase() &&
        d.negocioId == negocioId &&
        d.id != excludeId);
  }

  // Obtener count de componentes por distribución
  Future<int> getComponentCountByDistribucion(String distribucionId) async {
    try {
      final result = await supabaseLU
          .from('componente')
          .select('id')
          .eq('distribucion_id', distribucionId);

      return result.length;
    } catch (e) {
      print('Error getComponentCountByDistribucion: $e');
      return 0;
    }
  }

  // Obtener nombre del tipo por ID
  String? getTipoNombre(int tipoId) {
    try {
      final tipo = _tiposDistribucion.firstWhere((t) => t.id == tipoId);
      return tipo.nombre;
    } catch (e) {
      return null;
    }
  }

  // Obtener tipo por ID
  TipoDistribucion? getTipoById(int tipoId) {
    try {
      return _tiposDistribucion.firstWhere((t) => t.id == tipoId);
    } catch (e) {
      return null;
    }
  }
}
