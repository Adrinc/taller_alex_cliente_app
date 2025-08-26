import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/models/nethive/componente_model.dart';
import 'package:nethive_neo/models/nethive/conexion_componente_model.dart';
import 'package:nethive_neo/models/nethive/conexion_alimentacion_model.dart';
import 'package:nethive_neo/models/nethive/vista_conexiones_con_cables_y_rfid_model.dart';

class ConexionesProvider extends ChangeNotifier {
  // Estado
  bool _isLoading = false;
  String? _error;
  String? _negocioId;

  // Listas de datos
  List<VistaConexionesConCablesYRfid> _conexionesDatos = [];
  List<ConexionAlimentacion> _conexionesEnergia = [];
  List<Componente> _componentesDisponibles = [];
  List<Componente> _cablesDisponibles = [];

  // Filtros
  String _filtroTipo = 'todos'; // todos, datos, energia
  String _filtroEstado = 'activas'; // todas, activas, inactivas
  String _filtroTecnico = 'todos'; // todos, mis_conexiones
  String _busqueda = '';

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get negocioId => _negocioId;
  String get filtroTipo => _filtroTipo;
  String get filtroEstado => _filtroEstado;
  String get filtroTecnico => _filtroTecnico;
  String get busqueda => _busqueda;

  List<VistaConexionesConCablesYRfid> get conexionesDatos => _conexionesDatos;
  List<ConexionAlimentacion> get conexionesEnergia => _conexionesEnergia;
  List<Componente> get componentesDisponibles => _componentesDisponibles;
  List<Componente> get cablesDisponibles => _cablesDisponibles;

  // Conexiones filtradas
  List<dynamic> get conexionesFiltradas {
    List<dynamic> todas = [];

    if (_filtroTipo == 'todos' || _filtroTipo == 'datos') {
      todas.addAll(_conexionesDatos);
    }
    if (_filtroTipo == 'todos' || _filtroTipo == 'energia') {
      todas.addAll(_conexionesEnergia);
    }

    if (_busqueda.isNotEmpty) {
      todas = todas.where((conexion) {
        if (conexion is VistaConexionesConCablesYRfid) {
          return conexion.componenteOrigen
                  .toLowerCase()
                  .contains(_busqueda.toLowerCase()) ||
              conexion.componenteDestino
                  .toLowerCase()
                  .contains(_busqueda.toLowerCase()) ||
              (conexion.descripcion
                      ?.toLowerCase()
                      .contains(_busqueda.toLowerCase()) ??
                  false);
        } else if (conexion is ConexionAlimentacion) {
          return conexion.descripcion
                  ?.toLowerCase()
                  .contains(_busqueda.toLowerCase()) ??
              false;
        }
        return false;
      }).toList();
    }

    if (_filtroEstado == 'activas') {
      todas = todas.where((conexion) {
        if (conexion is VistaConexionesConCablesYRfid) {
          return conexion.activo;
        } else if (conexion is ConexionAlimentacion) {
          return conexion.activo;
        }
        return false;
      }).toList();
    } else if (_filtroEstado == 'inactivas') {
      todas = todas.where((conexion) {
        if (conexion is VistaConexionesConCablesYRfid) {
          return !conexion.activo;
        } else if (conexion is ConexionAlimentacion) {
          return !conexion.activo;
        }
        return false;
      }).toList();
    }

    return todas;
  }

  // Estadísticas
  int get totalConexiones =>
      _conexionesDatos.length + _conexionesEnergia.length;
  int get conexionesActivasDatos =>
      _conexionesDatos.where((c) => c.activo).length;
  int get conexionesActivasEnergia =>
      _conexionesEnergia.where((c) => c.activo).length;
  int get cablesEnUso => _cablesDisponibles
      .where((c) =>
          _conexionesDatos.any((con) => con.cableId == c.id) ||
          _conexionesEnergia.any((con) => con.cableId == c.id))
      .length;

  // Métodos principales
  Future<void> loadData(String negocioId) async {
    _negocioId = negocioId;
    await Future.wait([
      _loadConexionesDatos(),
      _loadConexionesEnergia(),
      _loadComponentes(),
      _loadCables(),
    ]);
  }

  Future<void> _loadConexionesDatos() async {
    try {
      print('ConexionesProvider: Cargando conexiones de datos...');

      final response = await supabaseLU
          .from('vista_conexiones_con_cables_y_rfid')
          .select('*')
          .order('conexion_id');

      _conexionesDatos = response
          .map<VistaConexionesConCablesYRfid>(
              (json) => VistaConexionesConCablesYRfid.fromMap(json))
          .toList();

      print(
          'ConexionesProvider: ${_conexionesDatos.length} conexiones de datos cargadas');
    } catch (e) {
      _error = 'Error cargando conexiones de datos: $e';
      print('ConexionesProvider: $_error');
    }
  }

  Future<void> _loadConexionesEnergia() async {
    try {
      print('ConexionesProvider: Cargando conexiones de energía...');

      final response = await supabaseLU
          .from('conexion_alimentacion')
          .select('*')
          .order('id');

      _conexionesEnergia = response
          .map<ConexionAlimentacion>(
              (json) => ConexionAlimentacion.fromMap(json))
          .toList();

      print(
          'ConexionesProvider: ${_conexionesEnergia.length} conexiones de energía cargadas');
    } catch (e) {
      _error = 'Error cargando conexiones de energía: $e';
      print('ConexionesProvider: $_error');
    }
  }

  Future<void> _loadComponentes() async {
    try {
      if (_negocioId == null) return;

      final response = await supabaseLU
          .from('componente')
          .select('*, categoria_componente(*)')
          .eq('negocio_id', _negocioId!)
          .eq('activo', true)
          .order('nombre');

      _componentesDisponibles =
          response.map<Componente>((json) => Componente.fromMap(json)).toList();

      print(
          'ConexionesProvider: ${_componentesDisponibles.length} componentes cargados');
    } catch (e) {
      print('ConexionesProvider: Error cargando componentes: $e');
    }
  }

  Future<void> _loadCables() async {
    try {
      if (_negocioId == null) return;

      final response = await supabaseLU
          .from('componente')
          .select('*, categoria_componente(*)')
          .eq('negocio_id', _negocioId!)
          .eq('categoria_id', 1) // Categoria 1 = Cable
          .eq('activo', true)
          .order('nombre');

      _cablesDisponibles =
          response.map<Componente>((json) => Componente.fromMap(json)).toList();

      print('ConexionesProvider: ${_cablesDisponibles.length} cables cargados');
    } catch (e) {
      print('ConexionesProvider: Error cargando cables: $e');
    }
  }

  // Crear conexión de datos
  Future<bool> crearConexionDatos({
    required String origenId,
    required String destinoId,
    String? cableId,
    String? descripcion,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final currentUserId = supabaseLU.auth.currentUser?.id;
      if (currentUserId == null) {
        _error = 'Usuario no autenticado';
        return false;
      }

      final conexionData = {
        'componente_origen_id': origenId,
        'componente_destino_id': destinoId,
        'cable_id': cableId,
        'descripcion': descripcion,
        'activo': true,
      };

      await supabaseLU.from('conexion_componente').insert(conexionData);

      await _loadConexionesDatos();
      print('ConexionesProvider: Conexión de datos creada exitosamente');
      return true;
    } catch (e) {
      _error = 'Error creando conexión: $e';
      print('ConexionesProvider: $_error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Crear conexión de energía
  Future<bool> crearConexionEnergia({
    required String origenId,
    required String destinoId,
    String? cableId,
    String? descripcion,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final currentUserId = supabaseLU.auth.currentUser?.id;
      if (currentUserId == null) {
        _error = 'Usuario no autenticado';
        return false;
      }

      final uuid = const Uuid();
      final conexionData = {
        'id': uuid.v4(),
        'origen_id': origenId,
        'destino_id': destinoId,
        'cable_id': cableId,
        'descripcion': descripcion,
        'activo': true,
        'tecnico_id': currentUserId,
      };

      await supabaseLU.from('conexion_alimentacion').insert(conexionData);

      await _loadConexionesEnergia();
      print('ConexionesProvider: Conexión de energía creada exitosamente');
      return true;
    } catch (e) {
      _error = 'Error creando conexión de energía: $e';
      print('ConexionesProvider: $_error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Eliminar conexión
  Future<bool> eliminarConexion(String conexionId, bool esDatos) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (esDatos) {
        await supabaseLU
            .from('conexion_componente')
            .update({'activo': false}).eq('id', conexionId);
        await _loadConexionesDatos();
      } else {
        await supabaseLU
            .from('conexion_alimentacion')
            .update({'activo': false}).eq('id', conexionId);
        await _loadConexionesEnergia();
      }

      return true;
    } catch (e) {
      _error = 'Error eliminando conexión: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Métodos de filtrado
  void setFiltroTipo(String tipo) {
    _filtroTipo = tipo;
    notifyListeners();
  }

  void setFiltroEstado(String estado) {
    _filtroEstado = estado;
    notifyListeners();
  }

  void setFiltroTecnico(String tecnico) {
    _filtroTecnico = tecnico;
    notifyListeners();
  }

  void setBusqueda(String busqueda) {
    _busqueda = busqueda;
    notifyListeners();
  }

  void limpiarFiltros() {
    _filtroTipo = 'todos';
    _filtroEstado = 'activas';
    _filtroTecnico = 'todos';
    _busqueda = '';
    notifyListeners();
  }

  void refresh() {
    if (_negocioId != null) {
      loadData(_negocioId!);
    }
  }
}
