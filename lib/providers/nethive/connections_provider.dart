import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/nethive/conexion_alimentacion_model.dart';
import '../../models/nethive/conexion_componente_model.dart';
import '../../models/nethive/vista_conexiones_con_cables_model.dart';

enum TipoConexion { alimentacion, componente }

enum FiltroConexiones { todas, completadas, pendientes, inactivas }

class ConnectionsProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<VistaConexionesConCables> _conexiones = [];
  List<ConexionAlimentacion> _conexionesAlimentacion = [];
  List<ConexionComponente> _conexionesComponente = [];

  bool _isLoading = false;
  String? _error;
  String? _currentNegocioId;
  FiltroConexiones _filtroActual = FiltroConexiones.todas;
  String _searchQuery = '';

  // Getters
  List<VistaConexionesConCables> get conexiones => _aplicarFiltros();
  List<ConexionAlimentacion> get conexionesAlimentacion =>
      _conexionesAlimentacion;
  List<ConexionComponente> get conexionesComponente => _conexionesComponente;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentNegocioId => _currentNegocioId;
  FiltroConexiones get filtroActual => _filtroActual;
  String get searchQuery => _searchQuery;

  // Estadísticas de conexiones
  int get totalConexiones => _conexiones.length;
  int get conexionesCompletadas =>
      _conexiones.where((c) => c.rfidCable != null && c.activo).length;
  int get conexionesPendientes =>
      _conexiones.where((c) => c.rfidCable == null && c.activo).length;
  int get conexionesInactivas => _conexiones.where((c) => !c.activo).length;

  // Cargar todas las conexiones para un negocio específico
  Future<void> cargarConexiones(String negocioId) async {
    _isLoading = true;
    _error = null;
    _currentNegocioId = negocioId;
    notifyListeners();

    try {
      // Cargar vista completa de conexiones - sin filtrar por negocio_id aquí
      // porque la vista puede no tener ese campo directamente
      final response = await _supabase
          .from('vista_conexiones_con_cables')
          .select()
          .order('conexion_id', ascending: false);

      // Filtrar las conexiones por negocio después de cargarlas
      // Esto se puede hacer mediante una consulta más específica si la vista lo permite
      _conexiones = (response as List)
          .map((item) => VistaConexionesConCables.fromMap(item))
          .toList();

      // Cargar conexiones de alimentación
      await _cargarConexionesAlimentacion(negocioId);

      // Cargar conexiones de componente
      await _cargarConexionesComponente(negocioId);
    } catch (e) {
      _error = 'Error al cargar conexiones: $e';
      debugPrint('Error en cargarConexiones: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar conexiones de alimentación específicas
  Future<void> _cargarConexionesAlimentacion(String negocioId) async {
    try {
      final response = await _supabase.from('conexion_alimentacion').select('''
            *,
            origen:componentes!conexion_alimentacion_origen_id_fkey(negocio_id),
            destino:componentes!conexion_alimentacion_destino_id_fkey(negocio_id)
          ''').or('origen.negocio_id.eq.$negocioId,destino.negocio_id.eq.$negocioId');

      _conexionesAlimentacion = (response as List)
          .map((item) => ConexionAlimentacion.fromMap(item))
          .toList();
    } catch (e) {
      debugPrint('Error al cargar conexiones de alimentación: $e');
    }
  }

  // Cargar conexiones de componente específicas
  Future<void> _cargarConexionesComponente(String negocioId) async {
    try {
      final response = await _supabase.from('conexion_componente').select('''
            *,
            origen:componentes!conexion_componente_componente_origen_id_fkey(negocio_id),
            destino:componentes!conexion_componente_componente_destino_id_fkey(negocio_id)
          ''').or('origen.negocio_id.eq.$negocioId,destino.negocio_id.eq.$negocioId');

      _conexionesComponente = (response as List)
          .map((item) => ConexionComponente.fromMap(item))
          .toList();
    } catch (e) {
      debugPrint('Error al cargar conexiones de componente: $e');
    }
  }

  // Crear nueva conexión de alimentación
  Future<bool> crearConexionAlimentacion({
    required String origenId,
    required String destinoId,
    String? cableId,
    String? descripcion,
    String? tecnicoId,
  }) async {
    try {
      final nuevaConexion = ConexionAlimentacion(
        id: '', // Se generará automáticamente
        origenId: origenId,
        destinoId: destinoId,
        cableId: cableId,
        descripcion: descripcion,
        activo: true,
        fechaCreacion: DateTime.now(),
        tecnicoId: tecnicoId,
      );

      await _supabase
          .from('conexion_alimentacion')
          .insert(nuevaConexion.toMap());

      // Recargar conexiones
      if (_currentNegocioId != null) {
        await cargarConexiones(_currentNegocioId!);
      }

      return true;
    } catch (e) {
      _error = 'Error al crear conexión de alimentación: $e';
      notifyListeners();
      return false;
    }
  }

  // Crear nueva conexión de componente
  Future<bool> crearConexionComponente({
    required String origenId,
    required String destinoId,
    String? descripcion,
  }) async {
    try {
      final nuevaConexion = ConexionComponente(
        id: '', // Se generará automáticamente
        componenteOrigenId: origenId,
        componenteDestinoId: destinoId,
        descripcion: descripcion,
        activo: true,
      );

      await _supabase.from('conexion_componente').insert(nuevaConexion.toMap());

      // Recargar conexiones
      if (_currentNegocioId != null) {
        await cargarConexiones(_currentNegocioId!);
      }

      return true;
    } catch (e) {
      _error = 'Error al crear conexión de componente: $e';
      notifyListeners();
      return false;
    }
  }

  // Actualizar conexión existente con cable
  Future<bool> actualizarConexionConCable({
    required String conexionId,
    required TipoConexion tipoConexion,
    required String cableId,
    String? descripcion,
  }) async {
    try {
      final tabla = tipoConexion == TipoConexion.alimentacion
          ? 'conexion_alimentacion'
          : 'conexion_componente';

      await _supabase.from(tabla).update({
        'cable_id': cableId,
        if (descripcion != null) 'descripcion': descripcion,
      }).eq('id', conexionId);

      // Recargar conexiones
      if (_currentNegocioId != null) {
        await cargarConexiones(_currentNegocioId!);
      }

      return true;
    } catch (e) {
      _error = 'Error al actualizar conexión: $e';
      notifyListeners();
      return false;
    }
  }

  // Eliminar conexión
  Future<bool> eliminarConexion({
    required String conexionId,
    required TipoConexion tipoConexion,
  }) async {
    try {
      final tabla = tipoConexion == TipoConexion.alimentacion
          ? 'conexion_alimentacion'
          : 'conexion_componente';

      await _supabase
          .from(tabla)
          .update({'activo': false}).eq('id', conexionId);

      // Recargar conexiones
      if (_currentNegocioId != null) {
        await cargarConexiones(_currentNegocioId!);
      }

      return true;
    } catch (e) {
      _error = 'Error al eliminar conexión: $e';
      notifyListeners();
      return false;
    }
  }

  // Aplicar filtros a las conexiones
  List<VistaConexionesConCables> _aplicarFiltros() {
    List<VistaConexionesConCables> conexionesFiltradas =
        List.from(_conexiones);

    // Aplicar filtro por estado
    switch (_filtroActual) {
      case FiltroConexiones.completadas:
        conexionesFiltradas = conexionesFiltradas
            .where((c) => c.rfidCable != null && c.activo)
            .toList();
        break;
      case FiltroConexiones.pendientes:
        conexionesFiltradas = conexionesFiltradas
            .where((c) => c.rfidCable == null && c.activo)
            .toList();
        break;
      case FiltroConexiones.inactivas:
        conexionesFiltradas =
            conexionesFiltradas.where((c) => !c.activo).toList();
        break;
      case FiltroConexiones.todas:
        // No filtrar, mostrar todas
        break;
    }

    // Aplicar búsqueda por texto
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      conexionesFiltradas = conexionesFiltradas.where((conexion) {
        return conexion.componenteOrigen.toLowerCase().contains(query) ||
            conexion.componenteDestino.toLowerCase().contains(query) ||
            (conexion.descripcion?.toLowerCase().contains(query) ?? false) ||
            (conexion.rfidOrigen?.toLowerCase().contains(query) ?? false) ||
            (conexion.rfidDestino?.toLowerCase().contains(query) ?? false) ||
            (conexion.rfidCable?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    return conexionesFiltradas;
  }

  // Cambiar filtro actual
  void cambiarFiltro(FiltroConexiones nuevoFiltro) {
    _filtroActual = nuevoFiltro;
    notifyListeners();
  }

  // Actualizar búsqueda
  void actualizarBusqueda(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Limpiar error
  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  // Buscar conexiones por componente específico
  List<VistaConexionesConCables> obtenerConexionesPorComponente(
      String componenteId) {
    return _conexiones
        .where((conexion) =>
            conexion.origenId == componenteId ||
            conexion.destinoId == componenteId)
        .toList();
  }

  // Verificar si dos componentes están conectados
  bool estanConectados(String componenteId1, String componenteId2) {
    return _conexiones.any((conexion) =>
        (conexion.origenId == componenteId1 &&
            conexion.destinoId == componenteId2) ||
        (conexion.origenId == componenteId2 &&
            conexion.destinoId == componenteId1));
  }

  // Obtener estadísticas detalladas
  Map<String, dynamic> get estadisticasDetalladas {
    return {
      'total': totalConexiones,
      'completadas': conexionesCompletadas,
      'pendientes': conexionesPendientes,
      'inactivas': conexionesInactivas,
      'porcentajeCompletado': totalConexiones > 0
          ? (conexionesCompletadas / totalConexiones * 100).round()
          : 0,
      'alimentacion': _conexionesAlimentacion.length,
      'componente': _conexionesComponente.length,
    };
  }
}
