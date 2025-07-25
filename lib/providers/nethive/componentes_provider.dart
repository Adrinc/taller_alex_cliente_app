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

  // Nuevas listas para topología
  List<Distribucion> distribuciones = [];
  List<ConexionComponente> conexiones = [];

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
    super.dispose();
  }

  // Método seguro para notificar listeners
  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  // Métodos para categorías
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

  // Métodos para componentes
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

  // Métodos para subir imágenes
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

  // CRUD Categorías
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

  // CRUD Componentes
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

      // Solo actualizar imagen si se seleccionó una nueva
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
      // Primero obtener la información del componente para obtener la URL de la imagen
      final componenteData = await supabaseLU
          .from('componente')
          .select('imagen_url')
          .eq('id', componenteId)
          .maybeSingle();

      // Guardar la URL de la imagen para eliminarla después
      String? imagenUrl;
      if (componenteData != null && componenteData['imagen_url'] != null) {
        imagenUrl = componenteData['imagen_url'] as String;
      }

      // Eliminar todos los detalles específicos primero
      await _eliminarDetallesComponente(componenteId);

      // Eliminar el componente de la base de datos
      await supabaseLU.from('componente').delete().eq('id', componenteId);

      // Actualizar la lista ANTES de eliminar la imagen
      if (!_isDisposed && negocioSeleccionadoId != null) {
        await getComponentesPorNegocio(negocioSeleccionadoId!);
      }

      // AHORA eliminar la imagen del storage (después de que la UI se haya actualizado)
      if (imagenUrl != null) {
        try {
          await supabaseLU.storage
              .from('nethive')
              .remove(["componentes/$imagenUrl"]);
          print('Imagen eliminada del storage: $imagenUrl');
        } catch (storageError) {
          print(
              'Error al eliminar imagen del storage: ${storageError.toString()}');
          // No retornamos false aquí porque el componente ya fue eliminado exitosamente
        }
      }

      return true;
    } catch (e) {
      print('Error en eliminarComponente: ${e.toString()}');
      return false;
    }
  }

  // Métodos para obtener detalles específicos
  Future<void> getDetallesComponente(
      String componenteId, int categoriaId) async {
    try {
      final categoriaNombre =
          getCategoriaById(categoriaId)?.nombre?.toLowerCase() ?? '';

      if (categoriaNombre.contains('cable')) {
        await _getDetalleCable(componenteId);
      } else if (categoriaNombre.contains('switch')) {
        await _getDetalleSwitch(componenteId);
      } else if (categoriaNombre.contains('patch') ||
          categoriaNombre.contains('panel')) {
        await _getDetallePatchPanel(componenteId);
      } else if (categoriaNombre.contains('rack')) {
        await _getDetalleRack(componenteId);
      } else if (categoriaNombre.contains('organizador')) {
        await _getDetalleOrganizador(componenteId);
      } else if (categoriaNombre.contains('ups')) {
        await _getDetalleUps(componenteId);
      } else if (categoriaNombre.contains('router') ||
          categoriaNombre.contains('firewall')) {
        await _getDetalleRouterFirewall(componenteId);
      } else {
        await _getDetalleEquipoActivo(componenteId);
      }

      showDetallesEspecificos = true;
      _safeNotifyListeners();
    } catch (e) {
      print('Error en getDetallesComponente: ${e.toString()}');
    }
  }

  Future<void> _getDetalleCable(String componenteId) async {
    final res = await supabaseLU
        .from('detalle_cable')
        .select()
        .eq('componente_id', componenteId)
        .maybeSingle();

    if (res != null) {
      detalleCable = DetalleCable.fromMap(res);
    }
  }

  Future<void> _getDetalleSwitch(String componenteId) async {
    final res = await supabaseLU
        .from('detalle_switch')
        .select()
        .eq('componente_id', componenteId)
        .maybeSingle();

    if (res != null) {
      detalleSwitch = DetalleSwitch.fromMap(res);
    }
  }

  Future<void> _getDetallePatchPanel(String componenteId) async {
    final res = await supabaseLU
        .from('detalle_patch_panel')
        .select()
        .eq('componente_id', componenteId)
        .maybeSingle();

    if (res != null) {
      detallePatchPanel = DetallePatchPanel.fromMap(res);
    }
  }

  Future<void> _getDetalleRack(String componenteId) async {
    final res = await supabaseLU
        .from('detalle_rack')
        .select()
        .eq('componente_id', componenteId)
        .maybeSingle();

    if (res != null) {
      detalleRack = DetalleRack.fromMap(res);
    }
  }

  Future<void> _getDetalleOrganizador(String componenteId) async {
    final res = await supabaseLU
        .from('detalle_organizador')
        .select()
        .eq('componente_id', componenteId)
        .maybeSingle();

    if (res != null) {
      detalleOrganizador = DetalleOrganizador.fromMap(res);
    }
  }

  Future<void> _getDetalleUps(String componenteId) async {
    final res = await supabaseLU
        .from('detalle_ups')
        .select()
        .eq('componente_id', componenteId)
        .maybeSingle();

    if (res != null) {
      detalleUps = DetalleUps.fromMap(res);
    }
  }

  Future<void> _getDetalleRouterFirewall(String componenteId) async {
    final res = await supabaseLU
        .from('detalle_router_firewall')
        .select()
        .eq('componente_id', componenteId)
        .maybeSingle();

    if (res != null) {
      detalleRouterFirewall = DetalleRouterFirewall.fromMap(res);
    }
  }

  Future<void> _getDetalleEquipoActivo(String componenteId) async {
    final res = await supabaseLU
        .from('detalle_equipo_activo')
        .select()
        .eq('componente_id', componenteId)
        .maybeSingle();

    if (res != null) {
      detalleEquipoActivo = DetalleEquipoActivo.fromMap(res);
    }
  }

  // Métodos de utilidad
  CategoriaComponente? getCategoriaById(int id) {
    try {
      return categorias.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  void resetFormData() {
    imagenFileName = null;
    imagenToUpload = null;
    categoriaSeleccionadaId = null;
    showDetallesEspecificos = false;

    // Limpiar detalles específicos
    detalleCable = null;
    detalleSwitch = null;
    detallePatchPanel = null;
    detalleRack = null;
    detalleOrganizador = null;
    detalleUps = null;
    detalleRouterFirewall = null;
    detalleEquipoActivo = null;

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

  // Métodos para distribuciones (MDF/IDF)
  Future<void> getDistribucionesPorNegocio(String negocioId) async {
    try {
      final res = await supabaseLU
          .from('distribucion')
          .select()
          .eq('negocio_id', negocioId)
          .order('tipo', ascending: false); // MDF primero, luego IDF

      distribuciones = (res as List<dynamic>)
          .map((distribucion) => Distribucion.fromMap(distribucion))
          .toList();

      print('Distribuciones cargadas: ${distribuciones.length}');
      for (var dist in distribuciones) {
        print('- ${dist.tipo}: ${dist.nombre}');
      }
    } catch (e) {
      print('Error en getDistribucionesPorNegocio: ${e.toString()}');
      distribuciones = [];
    }
  }

  // Métodos para conexiones
  Future<void> getConexionesPorNegocio(String negocioId) async {
    try {
      // Usar la vista optimizada si existe, sino usar query manual
      List<dynamic> res;

      try {
        // Intentar usar la vista optimizada
        res = await supabaseLU
            .from('vista_conexiones_por_negocio')
            .select()
            .eq('negocio_id', negocioId);
      } catch (e) {
        print('Vista no disponible, usando query manual...');
        // Fallback: obtener conexiones manualmente
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

  // Método principal para establecer el contexto del negocio desde la navegación
  Future<void> setNegocioSeleccionado(
      String negocioId, String negocioNombre, String empresaId) async {
    try {
      negocioSeleccionadoId = negocioId;
      negocioSeleccionadoNombre = negocioNombre;
      empresaSeleccionadaId = empresaId;

      // Limpiar datos anteriores
      _limpiarDatosAnteriores();

      // Cargar toda la información de topología para este negocio
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
    componentesRows.clear();
    showDetallesEspecificos = false;

    // Limpiar detalles específicos
    detalleCable = null;
    detalleSwitch = null;
    detallePatchPanel = null;
    detalleRack = null;
    detalleOrganizador = null;
    detalleUps = null;
    detalleRouterFirewall = null;
    detalleEquipoActivo = null;
  }

  // Cargar toda la información de topología de forma optimizada
  Future<void> cargarTopologiaCompleta(String negocioId) async {
    isLoadingTopologia = true;
    _safeNotifyListeners();

    try {
      // Cargar datos en paralelo para mejor performance
      await Future.wait([
        getComponentesPorNegocio(negocioId),
        getDistribucionesPorNegocio(negocioId),
        getConexionesPorNegocio(negocioId),
      ]);

      // Validar integridad de la topología
      problemasTopologia = validarTopologia();
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

  // Validar y obtener estadísticas de componentes por categoría
  Map<String, List<Componente>> getComponentesAgrupadosPorCategoria() {
    Map<String, List<Componente>> grupos = {};

    for (var componente in componentes.where((c) => c.activo)) {
      final categoria = getCategoriaById(componente.categoriaId);
      final nombreCategoria = categoria?.nombre ?? 'Sin categoría';

      if (!grupos.containsKey(nombreCategoria)) {
        grupos[nombreCategoria] = [];
      }
      grupos[nombreCategoria]!.add(componente);
    }

    return grupos;
  }

  // Obtener componentes por tipo específico with better logic
  List<Componente> getComponentesPorTipo(String tipo) {
    return componentes.where((c) {
      if (!c.activo) return false;

      final categoria = getCategoriaById(c.categoriaId);
      final nombreCategoria = categoria?.nombre?.toLowerCase() ?? '';
      final ubicacion = c.ubicacion?.toLowerCase() ?? '';

      switch (tipo.toLowerCase()) {
        case 'mdf':
          return ubicacion.contains('mdf') ||
              nombreCategoria.contains('mdf') ||
              (nombreCategoria.contains('switch') && ubicacion.contains('mdf'));

        case 'idf':
          return ubicacion.contains('idf') ||
              nombreCategoria.contains('idf') ||
              (nombreCategoria.contains('switch') && ubicacion.contains('idf'));

        case 'switch':
          return nombreCategoria.contains('switch');

        case 'router':
          return nombreCategoria.contains('router') ||
              nombreCategoria.contains('firewall');

        case 'servidor':
          return nombreCategoria.contains('servidor') ||
              nombreCategoria.contains('server');

        case 'cable':
          return nombreCategoria.contains('cable');

        case 'patch':
          return nombreCategoria.contains('patch') ||
              nombreCategoria.contains('panel');

        case 'rack':
          return nombreCategoria.contains('rack');

        default:
          return false;
      }
    }).toList();
  }

  // Obtener componentes por ubicación específica
  List<Componente> getComponentesPorUbicacionEspecifica(String ubicacion) {
    return componentes.where((c) {
      if (!c.activo) return false;
      return c.ubicacion?.toLowerCase().contains(ubicacion.toLowerCase()) ??
          false;
    }).toList();
  }

  // Crear conexión automática inteligente
  Future<bool> crearConexionAutomatica(String origenId, String destinoId,
      {String? descripcion}) async {
    try {
      final origen = getComponenteById(origenId);
      final destino = getComponenteById(destinoId);

      if (origen == null || destino == null) return false;

      // Generar descripción automática si no se proporciona
      if (descripcion == null) {
        final origenCategoria = getCategoriaById(origen.categoriaId);
        final destinoCategoria = getCategoriaById(destino.categoriaId);
        descripcion =
            'Conexión automática: ${origenCategoria?.nombre ?? 'Componente'} → ${destinoCategoria?.nombre ?? 'Componente'}';
      }

      return await crearConexion(
        componenteOrigenId: origenId,
        componenteDestinoId: destinoId,
        descripcion: descripcion,
        activo: true,
      );
    } catch (e) {
      print('Error en crearConexionAutomatica: ${e.toString()}');
      return false;
    }
  }

  // Crear una nueva conexión entre componentes
  Future<bool> crearConexion({
    required String componenteOrigenId,
    required String componenteDestinoId,
    String? descripcion,
    bool activo = true,
  }) async {
    try {
      final res = await supabaseLU.from('conexion_componente').insert({
        'componente_origen_id': componenteOrigenId,
        'componente_destino_id': componenteDestinoId,
        'descripcion': descripcion,
        'activo': activo,
      }).select();

      if (res.isNotEmpty && negocioSeleccionadoId != null) {
        await getConexionesPorNegocio(negocioSeleccionadoId!);
        return true;
      }
      return false;
    } catch (e) {
      print('Error en crearConexion: ${e.toString()}');
      return false;
    }
  }

  // Eliminar una conexión
  Future<bool> eliminarConexion(String conexionId) async {
    try {
      await supabaseLU
          .from('conexion_componente')
          .delete()
          .eq('id', conexionId);

      if (negocioSeleccionadoId != null) {
        await getConexionesPorNegocio(negocioSeleccionadoId!);
      }
      return true;
    } catch (e) {
      print('Error en eliminarConexion: ${e.toString()}');
      return false;
    }
  }

  // Crear una nueva distribución (MDF/IDF)
  Future<bool> crearDistribucion({
    required String negocioId,
    required String tipo, // 'MDF' o 'IDF'
    required String nombre,
    String? descripcion,
  }) async {
    try {
      final res = await supabaseLU.from('distribucion').insert({
        'negocio_id': negocioId,
        'tipo': tipo,
        'nombre': nombre,
        'descripcion': descripcion,
      }).select();

      if (res.isNotEmpty) {
        await getDistribucionesPorNegocio(negocioId);
        return true;
      }
      return false;
    } catch (e) {
      print('Error en crearDistribucion: ${e.toString()}');
      return false;
    }
  }

  // Obtener componentes por distribución
  List<Componente> getComponentesPorDistribucion(String distribucionNombre) {
    return componentes
        .where((c) =>
            c.ubicacion
                ?.toLowerCase()
                .contains(distribucionNombre.toLowerCase()) ??
            false)
        .toList();
  }

  // Obtener MDF del negocio
  Distribucion? getMDF() {
    try {
      return distribuciones.firstWhere((d) => d.tipo == 'MDF');
    } catch (e) {
      return null;
    }
  }

  // Obtener todos los IDF del negocio
  List<Distribucion> getIDFs() {
    return distribuciones.where((d) => d.tipo == 'IDF').toList();
  }

  // Obtener conexiones de un componente específico
  List<ConexionComponente> getConexionesDeComponente(String componenteId) {
    return conexiones
        .where((c) =>
            c.componenteOrigenId == componenteId ||
            c.componenteDestinoId == componenteId)
        .toList();
  }

  // Obtener componente por ID
  Componente? getComponenteById(String componenteId) {
    try {
      return componentes.firstWhere((c) => c.id == componenteId);
    } catch (e) {
      return null;
    }
  }

  // Validar integridad de topología mejorado
  List<String> validarTopologia() {
    List<String> problemas = [];

    if (componentes.isEmpty) {
      problemas.add('No se encontraron componentes para este negocio');
      return problemas;
    }

    // Verificar distribuciones
    final mdfCount = distribuciones.where((d) => d.tipo == 'MDF').length;
    final idfCount = distribuciones.where((d) => d.tipo == 'IDF').length;

    if (mdfCount == 0) {
      problemas.add('No se encontró ningún MDF configurado');
    } else if (mdfCount > 1) {
      problemas.add(
          'Se encontraron múltiples MDF ($mdfCount). Se recomienda solo uno por negocio');
    }

    if (idfCount == 0) {
      problemas.add('No se encontraron IDFs configurados');
    }

    // Verificar componentes principales
    final switchesMDF = getComponentesPorTipo('mdf')
        .where((c) =>
            getCategoriaById(c.categoriaId)
                ?.nombre
                ?.toLowerCase()
                .contains('switch') ??
            false)
        .toList();

    if (switchesMDF.isEmpty) {
      problemas.add('No se encontró switch principal en MDF');
    }

    // Verificar componentes sin ubicación
    final sinUbicacion = componentes
        .where((c) =>
            c.activo && (c.ubicacion == null || c.ubicacion!.trim().isEmpty))
        .length;
    if (sinUbicacion > 0) {
      problemas.add('$sinUbicacion componentes activos sin ubicación definida');
    }

    // Verificar conexiones
    final componentesActivos = componentes.where((c) => c.activo).length;
    final conexionesActivas = conexiones.where((c) => c.activo).length;

    if (componentesActivos > 1 && conexionesActivas == 0) {
      problemas.add('No se encontraron conexiones entre componentes');
    }

    // Verificar componentes críticos aislados
    final componentesCriticos = [
      ...switchesMDF,
      ...getComponentesPorTipo('router')
    ];
    for (var componente in componentesCriticos) {
      final conexionesComponente = getConexionesDeComponente(componente.id);
      if (conexionesComponente.isEmpty) {
        final categoria = getCategoriaById(componente.categoriaId);
        problemas.add(
            'Componente crítico sin conexiones: ${componente.nombre} (${categoria?.nombre})');
      }
    }

    return problemas;
  }

  // Obtener resumen de topología para dashboard
  Map<String, dynamic> getResumenTopologia() {
    final stats = getEstadisticasConectividad();
    final componentesPorCategoria = getComponentesAgrupadosPorCategoria();

    return {
      'estadisticas': stats,
      'categorias': componentesPorCategoria.map((key, value) => MapEntry(key, {
            'total': value.length,
            'activos': value.where((c) => c.activo).length,
            'enUso': value.where((c) => c.enUso).length,
          })),
      'distribuciones': {
        'mdf': distribuciones.where((d) => d.tipo == 'MDF').length,
        'idf': distribuciones.where((d) => d.tipo == 'IDF').length,
      },
      'problemas': problemasTopologia.length,
      'salud': problemasTopologia.isEmpty
          ? 'Excelente'
          : problemasTopologia.length <= 2
              ? 'Buena'
              : problemasTopologia.length <= 5
                  ? 'Regular'
                  : 'Crítica',
    };
  }

  // Obtener sugerencias de mejora
  List<String> getSugerenciasMejora() {
    List<String> sugerencias = [];

    final stats = getEstadisticasConectividad();
    final componentesPorTipo = getComponentesAgrupadosPorCategoria();

    // Sugerencias basadas en uso
    if (stats['porcentajeUso']! < 70) {
      sugerencias.add(
          'Considere optimizar el uso de componentes (${stats['porcentajeUso']}% en uso)');
    }

    // Sugerencias de redundancia
    final switchesPrincipales = getComponentesPorTipo('mdf');
    if (switchesPrincipales.length == 1) {
      sugerencias
          .add('Considere agregar redundancia en el switch principal del MDF');
    }

    // Sugerencias de documentación
    final sinDescripcion = componentes
        .where((c) =>
            c.activo &&
            (c.descripcion == null || c.descripcion!.trim().isEmpty))
        .length;
    if (sinDescripcion > 0) {
      sugerencias.add('Documente $sinDescripcion componentes sin descripción');
    }

    // Sugerencias de organización
    final componentesSinCategoria =
        componentesPorTipo['Sin categoría']?.length ?? 0;
    if (componentesSinCategoria > 0) {
      sugerencias
          .add('Categorice $componentesSinCategoria componentes sin categoría');
    }

    return sugerencias;
  }

  // Obtener estadísticas de conectividad
  Map<String, double> getEstadisticasConectividad() {
    final totalComponentes = componentes.length;
    final componentesActivos = componentes.where((c) => c.activo).length;
    final componentesEnUso = componentes.where((c) => c.enUso).length;
    final conexionesActivas = conexiones.where((c) => c.activo).length;

    return {
      'totalComponentes': totalComponentes.toDouble(),
      'componentesActivos': componentesActivos.toDouble(),
      'componentesEnUso': componentesEnUso.toDouble(),
      'conexionesActivas': conexionesActivas.toDouble(),
      'porcentajeActivos': totalComponentes > 0
          ? (componentesActivos / totalComponentes) * 100
          : 0,
      'porcentajeUso': componentesActivos > 0
          ? (componentesEnUso / componentesActivos) * 100
          : 0,
      'densidadConexiones':
          componentesActivos > 0 ? (conexionesActivas / componentesActivos) : 0,
    };
  }

  Future<void> _eliminarDetallesComponente(String componenteId) async {
    // Eliminar de todas las tablas de detalles
    await supabaseLU
        .from('detalle_cable')
        .delete()
        .eq('componente_id', componenteId);
    await supabaseLU
        .from('detalle_switch')
        .delete()
        .eq('componente_id', componenteId);
    await supabaseLU
        .from('detalle_patch_panel')
        .delete()
        .eq('componente_id', componenteId);
    await supabaseLU
        .from('detalle_rack')
        .delete()
        .eq('componente_id', componenteId);
    await supabaseLU
        .from('detalle_organizador')
        .delete()
        .eq('componente_id', componenteId);
    await supabaseLU
        .from('detalle_ups')
        .delete()
        .eq('componente_id', componenteId);
    await supabaseLU
        .from('detalle_router_firewall')
        .delete()
        .eq('componente_id', componenteId);
    await supabaseLU
        .from('detalle_equipo_activo')
        .delete()
        .eq('componente_id', componenteId);
  }
}
