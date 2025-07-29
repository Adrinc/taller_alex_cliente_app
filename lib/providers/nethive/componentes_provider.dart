import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/models/nethive/categoria_componente_model.dart';
import 'package:nethive_neo/models/nethive/componente_model.dart';
import 'package:nethive_neo/models/nethive/distribucion_model.dart';
import 'package:nethive_neo/models/nethive/conexion_componente_model.dart';
import 'package:nethive_neo/models/nethive/detalle_cable_model.dart';
import 'package:nethive_neo/models/nethive/detalle_switch_model.dart';
import 'package:nethive_neo/models/nethive/detalle_patch_panel_model.dart';
import 'package:nethive_neo/models/nethive/detalle_rack_model.dart';
import 'package:nethive_neo/models/nethive/detalle_organizador_model.dart';
import 'package:nethive_neo/models/nethive/detalle_ups_model.dart';
import 'package:nethive_neo/models/nethive/detalle_router_firewall_model.dart';
import 'package:nethive_neo/models/nethive/detalle_equipo_activo_model.dart';
import 'package:nethive_neo/models/nethive/vista_conexiones_por_cables_model.dart';
import 'package:nethive_neo/models/nethive/vista_topologia_por_negocio_model.dart';

class ComponentesProvider extends ChangeNotifier {
  // State managers
  PlutoGridStateManager? componentesStateManager;
  PlutoGridStateManager? categoriasStateManager;

  // Controladores de búsqueda
  final busquedaComponenteController = TextEditingController();
  final busquedaCategoriaController = TextEditingController();

  // Listas principales
  List<CategoriaComponente> categorias = [];
  List<Componente> componentes = [];
  List<PlutoRow> componentesRows = [];
  List<PlutoRow> categoriasRows = [];

  // Listas para topología optimizada
  List<Distribucion> distribuciones = [];
  List<ConexionComponente> conexiones = [];
  List<VistaConexionesPorCables> conexionesConCables = [];
  List<VistaTopologiaPorNegocio> topologiaOptimizada = [];

  // Variables para formularios
  String? imagenFileName;
  Uint8List? imagenToUpload;
  String? negocioSeleccionadoId;
  String? negocioSeleccionadoNombre;
  String? empresaSeleccionadaId;
  int? categoriaSeleccionadaId;
  bool showDetallesEspecificos = false;

  // Variables para gestión de topología
  bool isLoadingTopologia = false;
  List<String> problemasTopologia = [];

  // Detalles específicos por tipo de componente
  DetalleCable? detalleCable;
  DetalleSwitch? detalleSwitch;
  DetallePatchPanel? detallePatchPanel;
  DetalleRack? detalleRack;
  DetalleOrganizador? detalleOrganizador;
  DetalleUps? detalleUps;
  DetalleRouterFirewall? detalleRouterFirewall;
  DetalleEquipoActivo? detalleEquipoActivo;

  // Variable para controlar si el provider está activo
  bool _isDisposed = false;

  ComponentesProvider() {
    getCategorias();
  }

  @override
  void dispose() {
    _isDisposed = true;
    busquedaComponenteController.dispose();
    busquedaCategoriaController.dispose();
    super.dispose();
  }

  // Método seguro para notificar listeners
  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  // MÉTODOS PARA CATEGORÍAS
  Future<void> getCategorias([String? busqueda]) async {
    try {
      var query = supabaseLU.from('categoria_componente').select();

      if (busqueda != null && busqueda.isNotEmpty) {
        query = query.ilike('nombre', '%$busqueda%');
      }

      final res = await query.order('nombre', ascending: true);

      categorias = (res as List<dynamic>)
          .map((categoria) => CategoriaComponente.fromMap(categoria))
          .toList();

      _buildCategoriasRows();
      _safeNotifyListeners();
    } catch (e) {
      print('Error en getCategorias: ${e.toString()}');
    }
  }

  void _buildCategoriasRows() {
    categoriasRows.clear();

    for (CategoriaComponente categoria in categorias) {
      categoriasRows.add(PlutoRow(cells: {
        'id': PlutoCell(value: categoria.id),
        'nombre': PlutoCell(value: categoria.nombre),
        'editar': PlutoCell(value: categoria.id),
        'eliminar': PlutoCell(value: categoria.id),
      }));
    }
  }

  Future<bool> crearCategoria(String nombre) async {
    try {
      final res = await supabaseLU.from('categoria_componente').insert({
        'nombre': nombre,
      }).select();

      if (res.isNotEmpty) {
        await getCategorias();
        return true;
      }
      return false;
    } catch (e) {
      print('Error en crearCategoria: ${e.toString()}');
      return false;
    }
  }

  Future<bool> actualizarCategoria(int id, String nombre) async {
    try {
      final res = await supabaseLU
          .from('categoria_componente')
          .update({'nombre': nombre})
          .eq('id', id)
          .select();

      if (res.isNotEmpty) {
        await getCategorias();
        return true;
      }
      return false;
    } catch (e) {
      print('Error en actualizarCategoria: ${e.toString()}');
      return false;
    }
  }

  Future<bool> eliminarCategoria(int id) async {
    try {
      await supabaseLU.from('categoria_componente').delete().eq('id', id);
      await getCategorias();
      return true;
    } catch (e) {
      print('Error en eliminarCategoria: ${e.toString()}');
      return false;
    }
  }

  // MÉTODOS PARA COMPONENTES
  Future<void> getComponentesPorNegocio(String negocioId,
      [String? busqueda]) async {
    try {
      var query = supabaseLU.from('componente').select('''
            *,
            categoria_componente!inner(id, nombre)
          ''').eq('negocio_id', negocioId);

      if (busqueda != null && busqueda.isNotEmpty) {
        query = query.or(
            'nombre.ilike.%$busqueda%,descripcion.ilike.%$busqueda%,ubicacion.ilike.%$busqueda%');
      }

      final res = await query.order('fecha_registro', ascending: false);

      componentes = (res as List<dynamic>)
          .map((componente) => Componente.fromMap(componente))
          .toList();

      _buildComponentesRows();
      _safeNotifyListeners();
    } catch (e) {
      print('Error en getComponentesPorNegocio: ${e.toString()}');
    }
  }

  void _buildComponentesRows() {
    componentesRows.clear();

    for (Componente componente in componentes) {
      componentesRows.add(PlutoRow(cells: {
        'id': PlutoCell(value: componente.id),
        'negocio_id': PlutoCell(value: componente.negocioId),
        'categoria_id': PlutoCell(value: componente.categoriaId),
        'categoria_nombre': PlutoCell(
            value: getCategoriaById(componente.categoriaId)?.nombre ??
                'Sin categoría'),
        'nombre': PlutoCell(value: componente.nombre),
        'descripcion': PlutoCell(value: componente.descripcion ?? ''),
        'en_uso': PlutoCell(value: componente.enUso ? 'Sí' : 'No'),
        'activo': PlutoCell(value: componente.activo ? 'Sí' : 'No'),
        'ubicacion': PlutoCell(value: componente.ubicacion ?? ''),
        'fecha_registro':
            PlutoCell(value: componente.fechaRegistro.toString().split(' ')[0]),
        'imagen_url': PlutoCell(
          value: componente.imagenUrl != null
              ? "${supabaseLU.supabaseUrl}/storage/v1/object/public/nethive/componentes/${componente.imagenUrl}?${DateTime.now().millisecondsSinceEpoch}"
              : '',
        ),
        'editar': PlutoCell(value: componente.id),
        'eliminar': PlutoCell(value: componente.id),
        'ver_detalles': PlutoCell(value: componente.id),
      }));
    }
  }

  Future<bool> crearComponente({
    required String negocioId,
    required int categoriaId,
    required String nombre,
    String? descripcion,
    required bool enUso,
    required bool activo,
    String? ubicacion,
  }) async {
    try {
      final imagenUrl = await uploadImagen();

      final res = await supabaseLU.from('componente').insert({
        'negocio_id': negocioId,
        'categoria_id': categoriaId,
        'nombre': nombre,
        'descripcion': descripcion,
        'en_uso': enUso,
        'activo': activo,
        'ubicacion': ubicacion,
        'imagen_url': imagenUrl,
      }).select();

      if (res.isNotEmpty) {
        await getComponentesPorNegocio(negocioId);
        resetFormData();
        return true;
      }
      return false;
    } catch (e) {
      print('Error en crearComponente: ${e.toString()}');
      return false;
    }
  }

  Future<bool> actualizarComponente({
    required String componenteId,
    required String negocioId,
    required int categoriaId,
    required String nombre,
    String? descripcion,
    required bool enUso,
    required bool activo,
    String? ubicacion,
    bool actualizarImagen = false,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'categoria_id': categoriaId,
        'nombre': nombre,
        'descripcion': descripcion,
        'en_uso': enUso,
        'activo': activo,
        'ubicacion': ubicacion,
      };

      if (actualizarImagen) {
        final imagenUrl = await uploadImagen();
        if (imagenUrl != null) {
          updateData['imagen_url'] = imagenUrl;
        }
      }

      final res = await supabaseLU
          .from('componente')
          .update(updateData)
          .eq('id', componenteId)
          .select();

      if (res.isNotEmpty) {
        await getComponentesPorNegocio(negocioId);
        resetFormData();
        return true;
      }
      return false;
    } catch (e) {
      print('Error en actualizarComponente: ${e.toString()}');
      return false;
    }
  }

  Future<bool> eliminarComponente(String componenteId) async {
    try {
      final componenteData = await supabaseLU
          .from('componente')
          .select('imagen_url')
          .eq('id', componenteId)
          .maybeSingle();

      String? imagenUrl;
      if (componenteData != null && componenteData['imagen_url'] != null) {
        imagenUrl = componenteData['imagen_url'] as String;
      }

      await _eliminarDetallesComponente(componenteId);
      await supabaseLU.from('componente').delete().eq('id', componenteId);

      if (!_isDisposed && negocioSeleccionadoId != null) {
        await getComponentesPorNegocio(negocioSeleccionadoId!);
      }

      if (imagenUrl != null) {
        try {
          await supabaseLU.storage
              .from('nethive')
              .remove(["componentes/$imagenUrl"]);
        } catch (storageError) {
          print(
              'Error al eliminar imagen del storage: ${storageError.toString()}');
        }
      }

      return true;
    } catch (e) {
      print('Error en eliminarComponente: ${e.toString()}');
      return false;
    }
  }

  Future<void> _eliminarDetallesComponente(String componenteId) async {
    try {
      await Future.wait([
        supabaseLU
            .from('detalle_cable')
            .delete()
            .eq('componente_id', componenteId),
        supabaseLU
            .from('detalle_switch')
            .delete()
            .eq('componente_id', componenteId),
        supabaseLU
            .from('detalle_patch_panel')
            .delete()
            .eq('componente_id', componenteId),
        supabaseLU
            .from('detalle_rack')
            .delete()
            .eq('componente_id', componenteId),
        supabaseLU
            .from('detalle_organizador')
            .delete()
            .eq('componente_id', componenteId),
        supabaseLU
            .from('detalle_ups')
            .delete()
            .eq('componente_id', componenteId),
        supabaseLU
            .from('detalle_router_firewall')
            .delete()
            .eq('componente_id', componenteId),
        supabaseLU
            .from('detalle_equipo_activo')
            .delete()
            .eq('componente_id', componenteId),
        supabaseLU.from('conexion_componente').delete().or(
            'componente_origen_id.eq.$componenteId,componente_destino_id.eq.$componenteId'),
      ]);
    } catch (e) {
      print('Error al eliminar detalles del componente: ${e.toString()}');
    }
  }

  // MÉTODOS PARA IMÁGENES
  Future<void> selectImagen() async {
    imagenFileName = null;
    imagenToUpload = null;

    FilePickerResult? picker = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],
    );

    if (picker != null) {
      var now = DateTime.now();
      var formatter = DateFormat('yyyyMMddHHmmss');
      var timestamp = formatter.format(now);

      imagenFileName = 'componente-$timestamp-${picker.files.single.name}';
      imagenToUpload = picker.files.single.bytes;
    }

    _safeNotifyListeners();
  }

  Future<String?> uploadImagen() async {
    if (imagenToUpload != null && imagenFileName != null) {
      await supabaseLU.storage.from('nethive/componentes').uploadBinary(
            imagenFileName!,
            imagenToUpload!,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );
      return imagenFileName;
    }
    return null;
  }

  // MÉTODOS PARA DISTRIBUCIONES
  Future<void> getDistribucionesPorNegocio(String negocioId) async {
    try {
      final res = await supabaseLU
          .from('distribucion')
          .select()
          .eq('negocio_id', negocioId)
          .order('tipo', ascending: false);

      distribuciones = (res as List<dynamic>)
          .map((distribucion) => Distribucion.fromMap(distribucion))
          .toList();

      print('Distribuciones cargadas: ${distribuciones.length}');
    } catch (e) {
      print('Error en getDistribucionesPorNegocio: ${e.toString()}');
      distribuciones = [];
    }
  }

  // MÉTODOS PARA CONEXIONES
  Future<void> getConexionesPorNegocio(String negocioId) async {
    try {
      List<dynamic> res;

      try {
        res = await supabaseLU
            .from('vista_conexiones_por_negocio')
            .select()
            .eq('negocio_id', negocioId);
      } catch (e) {
        final componentesDelNegocio = await supabaseLU
            .from('componente')
            .select('id')
            .eq('negocio_id', negocioId);

        if (componentesDelNegocio.isEmpty) {
          conexiones = [];
          return;
        }

        final componenteIds =
            componentesDelNegocio.map((comp) => comp['id'] as String).toList();

        res = await supabaseLU
            .from('conexion_componente')
            .select()
            .or('componente_origen_id.in.(${componenteIds.join(',')}),componente_destino_id.in.(${componenteIds.join(',')})')
            .eq('activo', true);
      }

      conexiones = (res as List<dynamic>)
          .map((conexion) => ConexionComponente.fromMap(conexion))
          .toList();

      print('Conexiones cargadas: ${conexiones.length}');
    } catch (e) {
      print('Error en getConexionesPorNegocio: ${e.toString()}');
      conexiones = [];
    }
  }

  // MÉTODOS PARA TOPOLOGÍA OPTIMIZADA
  Future<void> getConexionesConCablesPorNegocio(String negocioId) async {
    try {
      final res = await supabaseLU
          .from('vista_conexiones_con_cables')
          .select()
          .eq('activo', true);

      conexionesConCables = (res as List<dynamic>)
          .map((conexion) => VistaConexionesPorCables.fromMap(conexion))
          .toList();

      print('Conexiones con cables cargadas: ${conexionesConCables.length}');
    } catch (e) {
      print('Error en getConexionesConCablesPorNegocio: ${e.toString()}');
      await _getConexionesConCablesManual(negocioId);
    }
  }

  Future<void> _getConexionesConCablesManual(String negocioId) async {
    try {
      final componentesDelNegocio = await supabaseLU
          .from('componente')
          .select('id')
          .eq('negocio_id', negocioId);

      if (componentesDelNegocio.isEmpty) {
        conexionesConCables = [];
        return;
      }

      final componenteIds =
          componentesDelNegocio.map((comp) => comp['id'] as String).toList();

      final conexionesRes = await supabaseLU
          .from('conexion_componente')
          .select(''''
            *,
            componente_origen:componente!componente_origen_id(id, nombre),
            componente_destino:componente!componente_destino_id(id, nombre),
            cable:componente!cable_id(id, nombre),
            detalle_cable!cable_id(*)
          ''')
          .or('componente_origen_id.in.(${componenteIds.join(',')}),componente_destino_id.in.(${componenteIds.join(',')})')
          .eq('activo', true);

      conexionesConCables = (conexionesRes as List<dynamic>).map((conexion) {
        final origenData =
            conexion['componente_origen'] as Map<String, dynamic>?;
        final destinoData =
            conexion['componente_destino'] as Map<String, dynamic>?;
        final cableData = conexion['cable'] as Map<String, dynamic>?;
        final detalleCableData =
            conexion['detalle_cable'] as Map<String, dynamic>?;

        return VistaConexionesPorCables(
          conexionId: conexion['id'],
          descripcion: conexion['descripcion'],
          activo: conexion['activo'] ?? false,
          origenId: origenData?['id'] ?? '',
          componenteOrigen: origenData?['nombre'] ?? '',
          destinoId: destinoData?['id'] ?? '',
          componenteDestino: destinoData?['nombre'] ?? '',
          cableId: cableData?['id'],
          cableUsado: cableData?['nombre'],
          tipoCable: detalleCableData?['tipo_cable'],
          color: detalleCableData?['color'],
          tamano: detalleCableData?['tamaño']?.toDouble(),
          tipoConector: detalleCableData?['tipo_conector'],
        );
      }).toList();

      print('Conexiones con cables (manual): ${conexionesConCables.length}');
    } catch (e) {
      print('Error en _getConexionesConCablesManual: ${e.toString()}');
      conexionesConCables = [];
    }
  }

  Future<void> getTopologiaOptimizadaPorNegocio(String negocioId) async {
    try {
      final res = await supabaseLU
          .from('vista_topologia_por_negocio')
          .select()
          .eq('negocio_id', negocioId)
          .eq('activo', true)
          .order('fecha_registro', ascending: false);

      topologiaOptimizada = (res as List<dynamic>)
          .map((item) => VistaTopologiaPorNegocio.fromMap(item))
          .toList();

      print(
          'Topología optimizada cargada: ${topologiaOptimizada.length} componentes');
    } catch (e) {
      print('Error en getTopologiaOptimizadaPorNegocio: ${e.toString()}');
      await _getTopologiaOptimizadaManual(negocioId);
    }
  }

  Future<void> _getTopologiaOptimizadaManual(String negocioId) async {
    try {
      final res = await supabaseLU
          .from('componente')
          .select('''
            *,
            categoria_componente!inner(id, nombre),
            distribucion(id, tipo, nombre),
            negocio!inner(id, nombre)
          ''')
          .eq('negocio_id', negocioId)
          .eq('activo', true)
          .order('fecha_registro', ascending: false);

      topologiaOptimizada = (res as List<dynamic>).map((item) {
        // Manejar datos de negocio
        final negocioData = item['negocio'];
        final String negocioIdRes = negocioData is Map<String, dynamic>
            ? negocioData['id']?.toString() ?? negocioId
            : negocioId;
        final String nombreNegocio = negocioData is Map<String, dynamic>
            ? negocioData['nombre']?.toString() ?? 'Sin nombre'
            : 'Sin nombre';

        // Manejar datos de categoría
        final categoriaData = item['categoria_componente'];
        final String nombreCategoria = categoriaData is Map<String, dynamic>
            ? categoriaData['nombre']?.toString() ?? 'Sin categoría'
            : 'Sin categoría';

        // Manejar datos de distribución (puede ser null)
        final distribucionData = item['distribucion'];
        String? distribucionId;
        String? tipoDistribucion;
        String? distribucionNombre;

        if (distribucionData is Map<String, dynamic>) {
          distribucionId = distribucionData['id']?.toString();
          tipoDistribucion = distribucionData['tipo']?.toString();
          distribucionNombre = distribucionData['nombre']?.toString();
        }

        return VistaTopologiaPorNegocio(
          negocioId: negocioIdRes,
          nombreNegocio: nombreNegocio,
          distribucionId: distribucionId,
          tipoDistribucion: tipoDistribucion,
          distribucionNombre: distribucionNombre,
          componenteId: item['id']?.toString() ?? '',
          componenteNombre: item['nombre']?.toString() ?? '',
          descripcion: item['descripcion']?.toString(),
          categoriaComponente: nombreCategoria,
          enUso: item['en_uso'] == true,
          activo: item['activo'] == true,
          ubicacion: item['ubicacion']?.toString(),
          imagenUrl: item['imagen_url']?.toString(),
          fechaRegistro:
              DateTime.tryParse(item['fecha_registro']?.toString() ?? '') ??
                  DateTime.now(),
        );
      }).toList();

      print(
          'Topología optimizada (manual): ${topologiaOptimizada.length} componentes');

      // Debug: Mostrar las categorías encontradas
      final categoriasEncontradas = topologiaOptimizada
          .map((c) => c.categoriaComponente)
          .toSet()
          .toList();
      print('Categorías encontradas: $categoriasEncontradas');
    } catch (e) {
      print('Error en _getTopologiaOptimizadaManual: ${e.toString()}');
      topologiaOptimizada = [];
    }
  }

  Future<void> cargarTopologiaCompletaOptimizada(String negocioId) async {
    isLoadingTopologia = true;
    _safeNotifyListeners();

    try {
      await Future.wait([
        getTopologiaOptimizadaPorNegocio(negocioId),
        getConexionesConCablesPorNegocio(negocioId),
        getDistribucionesPorNegocio(negocioId),
      ]);

      _sincronizarConListasPrincipales();
      problemasTopologia = validarTopologiaOptimizada();
      print('Topología completa cargada exitosamente');
    } catch (e) {
      print('Error en cargarTopologiaCompletaOptimizada: ${e.toString()}');
      problemasTopologia = [
        'Error al cargar datos de topología optimizada: ${e.toString()}'
      ];
      await cargarTopologiaCompleta(negocioId);
    } finally {
      isLoadingTopologia = false;
      _safeNotifyListeners();
    }
  }

  void _sincronizarConListasPrincipales() {
    if (topologiaOptimizada.isNotEmpty) {
      componentes = topologiaOptimizada.map((topo) {
        return Componente(
          id: topo.componenteId,
          negocioId: topo.negocioId,
          categoriaId: _getCategoriaIdPorNombre(topo.categoriaComponente),
          nombre: topo.componenteNombre,
          descripcion: topo.descripcion,
          ubicacion: topo.ubicacion,
          imagenUrl: topo.imagenUrl,
          enUso: topo.enUso,
          activo: topo.activo,
          fechaRegistro: topo.fechaRegistro,
          distribucionId: topo.distribucionId,
        );
      }).toList();

      _buildComponentesRows();
    }

    if (conexionesConCables.isNotEmpty) {
      conexiones = conexionesConCables.map((conexionCable) {
        return ConexionComponente(
          id: conexionCable.conexionId,
          componenteOrigenId: conexionCable.origenId,
          componenteDestinoId: conexionCable.destinoId,
          descripcion: conexionCable.descripcion,
          activo: conexionCable.activo,
        );
      }).toList();
    }
  }

  // MÉTODOS DE GESTIÓN DE TOPOLOGÍA
  Future<void> setNegocioSeleccionado(
      String negocioId, String negocioNombre, String empresaId) async {
    try {
      negocioSeleccionadoId = negocioId;
      negocioSeleccionadoNombre = negocioNombre;
      empresaSeleccionadaId = empresaId;

      _limpiarDatosAnteriores();
      await cargarTopologiaCompleta(negocioId);
      _safeNotifyListeners();
    } catch (e) {
      print('Error en setNegocioSeleccionado: ${e.toString()}');
    }
  }

  void _limpiarDatosAnteriores() {
    componentes.clear();
    distribuciones.clear();
    conexiones.clear();
    conexionesConCables.clear();
    topologiaOptimizada.clear();
    componentesRows.clear();
    showDetallesEspecificos = false;

    detalleCable = null;
    detalleSwitch = null;
    detallePatchPanel = null;
    detalleRack = null;
    detalleOrganizador = null;
    detalleUps = null;
    detalleRouterFirewall = null;
    detalleEquipoActivo = null;
  }

  Future<void> cargarTopologiaCompleta(String negocioId) async {
    isLoadingTopologia = true;
    _safeNotifyListeners();

    try {
      await Future.wait([
        getComponentesPorNegocio(negocioId),
        getDistribucionesPorNegocio(negocioId),
        getConexionesPorNegocio(negocioId),
      ]);

      problemasTopologia = validarTopologia();
      print(
          'Topología cargada - Componentes: ${componentes.length}, Distribuciones: ${distribuciones.length}, Conexiones: ${conexiones.length}');
    } catch (e) {
      print('Error en cargarTopologiaCompleta: ${e.toString()}');
      problemasTopologia = [
        'Error al cargar datos de topología: ${e.toString()}'
      ];
    } finally {
      isLoadingTopologia = false;
      _safeNotifyListeners();
    }
  }

  // MÉTODOS DE UTILIDAD
  CategoriaComponente? getCategoriaById(int categoriaId) {
    try {
      return categorias.firstWhere((c) => c.id == categoriaId);
    } catch (e) {
      return null;
    }
  }

  Componente? getComponenteById(String componenteId) {
    try {
      return componentes.firstWhere((c) => c.id == componenteId);
    } catch (e) {
      return null;
    }
  }

  List<Componente> getComponentesPorTipo(String tipo) {
    return componentes.where((c) {
      if (!c.activo) return false;

      final categoria = getCategoriaById(c.categoriaId);
      final nombreCategoria = categoria?.nombre.toLowerCase() ?? '';

      switch (tipo.toLowerCase()) {
        case 'mdf':
          return c.ubicacion?.toLowerCase().contains('mdf') == true ||
              nombreCategoria.contains('mdf') ||
              c.descripcion?.toLowerCase().contains('mdf') == true;
        case 'idf':
          return c.ubicacion?.toLowerCase().contains('idf') == true ||
              nombreCategoria.contains('idf') ||
              c.descripcion?.toLowerCase().contains('idf') == true;
        case 'switch':
          return nombreCategoria.contains('switch');
        case 'router':
          return nombreCategoria.contains('router') ||
              nombreCategoria.contains('firewall');
        case 'servidor':
        case 'server':
          return nombreCategoria.contains('servidor') ||
              nombreCategoria.contains('server');
        default:
          return false;
      }
    }).toList();
  }

  List<String> validarTopologia() {
    List<String> problemas = [];

    if (componentes.isEmpty) {
      problemas.add('No se encontraron componentes para este negocio');
      return problemas;
    }

    final mdfComponents = getComponentesPorTipo('mdf');
    final idfComponents = getComponentesPorTipo('idf');

    if (mdfComponents.isEmpty) {
      problemas
          .add('No se encontraron componentes MDF (distribución principal)');
    }

    if (idfComponents.isEmpty) {
      problemas.add(
          'No se encontraron componentes IDF (distribuciones intermedias)');
    }

    final sinUbicacion = componentes
        .where((c) =>
            c.activo && (c.ubicacion == null || c.ubicacion!.trim().isEmpty))
        .length;
    if (sinUbicacion > 0) {
      problemas.add('$sinUbicacion componentes activos sin ubicación definida');
    }

    final componentesActivos = componentes.where((c) => c.activo).length;
    final conexionesActivas = conexiones.where((c) => c.activo).length;

    if (componentesActivos > 1 && conexionesActivas == 0) {
      problemas.add('No se encontraron conexiones entre componentes');
    }

    return problemas;
  }

  List<String> validarTopologiaOptimizada() {
    List<String> problemas = [];

    if (topologiaOptimizada.isEmpty) {
      problemas.add('No se encontraron componentes para este negocio');
      return problemas;
    }

    final mdfComponents = topologiaOptimizada.where((c) => c.esMDF).toList();
    final idfComponents = topologiaOptimizada.where((c) => c.esIDF).toList();

    if (mdfComponents.isEmpty) {
      problemas.add('No se encontraron componentes configurados como MDF');
    }

    if (idfComponents.isEmpty) {
      problemas.add('No se encontraron componentes configurados como IDF');
    }

    final sinUbicacion = topologiaOptimizada
        .where((c) => c.ubicacion == null || c.ubicacion!.trim().isEmpty)
        .length;

    if (sinUbicacion > 0) {
      problemas.add('$sinUbicacion componentes sin ubicación definida');
    }

    if (conexionesConCables.isEmpty && topologiaOptimizada.length > 1) {
      problemas.add('No se encontraron conexiones entre componentes');
    }

    return problemas;
  }

  // MÉTODOS PARA VISTAS OPTIMIZADAS
  List<VistaTopologiaPorNegocio> getComponentesMDFOptimizados() {
    return topologiaOptimizada.where((c) => c.esMDF).toList()
      ..sort((a, b) => a.prioridadTopologia.compareTo(b.prioridadTopologia));
  }

  List<VistaTopologiaPorNegocio> getComponentesIDFOptimizados() {
    return topologiaOptimizada.where((c) => c.esIDF).toList()
      ..sort((a, b) => a.prioridadTopologia.compareTo(b.prioridadTopologia));
  }

  List<VistaTopologiaPorNegocio> getComponentesPorTipoOptimizado(String tipo) {
    return topologiaOptimizada
        .where((c) => c.tipoComponentePrincipal == tipo)
        .toList()
      ..sort((a, b) => a.prioridadTopologia.compareTo(b.prioridadTopologia));
  }

  int _getCategoriaIdPorNombre(String nombreCategoria) {
    try {
      final categoria = categorias.firstWhere(
        (c) => c.nombre.toLowerCase() == nombreCategoria.toLowerCase(),
      );
      return categoria.id;
    } catch (e) {
      return 1;
    }
  }

  // MÉTODOS DE UTILIDAD PARA FORMULARIOS
  void resetFormData() {
    imagenFileName = null;
    imagenToUpload = null;
    categoriaSeleccionadaId = null;
    _safeNotifyListeners();
  }

  void buscarComponentes(String busqueda) {
    if (negocioSeleccionadoId != null) {
      getComponentesPorNegocio(
          negocioSeleccionadoId!, busqueda.isEmpty ? null : busqueda);
    }
  }

  void buscarCategorias(String busqueda) {
    getCategorias(busqueda.isEmpty ? null : busqueda);
  }

  Widget? getImageWidget(dynamic image,
      {double height = 100, double width = 100}) {
    if (image == null || image.toString().isEmpty) {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
        ),
        child: Image.asset(
          'assets/images/placeholder_no_image.jpg',
          height: height,
          width: width,
          fit: BoxFit.cover,
        ),
      );
    } else if (image is Uint8List) {
      return Image.memory(
        image,
        height: height,
        width: width,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/placeholder_no_image.jpg',
            height: height,
            width: width,
            fit: BoxFit.cover,
          );
        },
      );
    } else if (image is String) {
      return Image.network(
        image,
        height: height,
        width: width,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            'assets/images/placeholder_no_image.jpg',
            height: height,
            width: width,
            fit: BoxFit.cover,
          );
        },
      );
    }
    return Image.asset(
      'assets/images/placeholder_no_image.jpg',
      height: height,
      width: width,
      fit: BoxFit.cover,
    );
  }
}
