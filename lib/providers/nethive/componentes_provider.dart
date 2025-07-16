import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/models/nethive/categoria_componente_model.dart';
import 'package:nethive_neo/models/nethive/componente_model.dart';
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

  // Variables para formularios
  String? imagenFileName;
  Uint8List? imagenToUpload;
  String? negocioSeleccionadoId;
  int? categoriaSeleccionadaId;
  bool showDetallesEspecificos = false;

  // Detalles específicos por tipo de componente
  DetalleCable? detalleCable;
  DetalleSwitch? detalleSwitch;
  DetallePatchPanel? detallePatchPanel;
  DetalleRack? detalleRack;
  DetalleOrganizador? detalleOrganizador;
  DetalleUps? detalleUps;
  DetalleRouterFirewall? detalleRouterFirewall;
  DetalleEquipoActivo? detalleEquipoActivo;

  ComponentesProvider() {
    getCategorias();
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
      notifyListeners();
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
      notifyListeners();
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

    notifyListeners();
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

  Future<bool> eliminarComponente(String componenteId) async {
    try {
      // Eliminar todos los detalles específicos primero
      await _eliminarDetallesComponente(componenteId);

      // Luego eliminar el componente
      await supabaseLU.from('componente').delete().eq('id', componenteId);

      if (negocioSeleccionadoId != null) {
        await getComponentesPorNegocio(negocioSeleccionadoId!);
      }
      return true;
    } catch (e) {
      print('Error en eliminarComponente: ${e.toString()}');
      return false;
    }
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
      notifyListeners();
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
  void setNegocioSeleccionado(String negocioId) {
    negocioSeleccionadoId = negocioId;
    getComponentesPorNegocio(negocioId);
    notifyListeners();
  }

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

    notifyListeners();
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
        color: Colors.grey[300],
        child: const Icon(Icons.device_unknown),
      );
    } else if (image is Uint8List) {
      return Image.memory(
        image,
        height: height,
        width: width,
        fit: BoxFit.cover,
      );
    } else if (image is String) {
      return Image.network(
        image,
        height: height,
        width: width,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: height,
            width: width,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image),
          );
        },
      );
    }
    return null;
  }
}
