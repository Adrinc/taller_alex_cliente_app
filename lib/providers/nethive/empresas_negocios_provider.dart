import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/models/nethive/empresa_model.dart';
import 'package:nethive_neo/models/nethive/negocio_model.dart';

class EmpresasNegociosProvider extends ChangeNotifier {
  // State managers para las grillas
  PlutoGridStateManager? empresasStateManager;
  PlutoGridStateManager? negociosStateManager;

  // Controladores de búsqueda
  final busquedaEmpresaController = TextEditingController();
  final busquedaNegocioController = TextEditingController();

  // Listas de datos
  List<Empresa> empresas = [];
  List<Negocio> negocios = [];
  List<PlutoRow> empresasRows = [];
  List<PlutoRow> negociosRows = [];

  // Variables para formularios
  String? logoFileName;
  String? imagenFileName;
  Uint8List? logoToUpload;
  Uint8List? imagenToUpload;

  // Variables de selección
  String? empresaSeleccionadaId;
  Empresa? empresaSeleccionada;

  EmpresasNegociosProvider() {
    getEmpresas();
  }

  // Métodos para empresas
  Future<void> getEmpresas([String? busqueda]) async {
    try {
      var query = supabaseLU.from('empresa').select();

      if (busqueda != null && busqueda.isNotEmpty) {
        query = query.or(
            'nombre.ilike.%$busqueda%,rfc.ilike.%$busqueda%,email.ilike.%$busqueda%');
      }

      final res = await query.order('fecha_creacion', ascending: false);

      empresas = (res as List<dynamic>)
          .map((empresa) => Empresa.fromMap(empresa))
          .toList();

      _buildEmpresasRows();
      notifyListeners();
    } catch (e) {
      print('Error en getEmpresas: ${e.toString()}');
    }
  }

  void _buildEmpresasRows() {
    empresasRows.clear();

    for (Empresa empresa in empresas) {
      empresasRows.add(PlutoRow(cells: {
        'id': PlutoCell(value: empresa.id),
        'nombre': PlutoCell(value: empresa.nombre),
        'rfc': PlutoCell(value: empresa.rfc),
        'direccion': PlutoCell(value: empresa.direccion),
        'telefono': PlutoCell(value: empresa.telefono),
        'email': PlutoCell(value: empresa.email),
        'fecha_creacion':
            PlutoCell(value: empresa.fechaCreacion.toString().split(' ')[0]),
        'logo_url': PlutoCell(
          value: empresa.logoUrl != null
              ? "${supabaseLU.supabaseUrl}/storage/v1/object/public/nethive/logos/${empresa.logoUrl}?${DateTime.now().millisecondsSinceEpoch}"
              : '',
        ),
        'imagen_url': PlutoCell(
          value: empresa.imagenUrl != null
              ? "${supabaseLU.supabaseUrl}/storage/v1/object/public/nethive/imagenes/${empresa.imagenUrl}?${DateTime.now().millisecondsSinceEpoch}"
              : '',
        ),
        'editar': PlutoCell(value: empresa.id),
        'eliminar': PlutoCell(value: empresa.id),
        'ver_negocios': PlutoCell(value: empresa.id),
      }));
    }
  }

  Future<void> getNegociosPorEmpresa(String empresaId) async {
    try {
      final res = await supabaseLU
          .from('negocio')
          .select()
          .eq('empresa_id', empresaId)
          .order('fecha_creacion', ascending: false);

      negocios = (res as List<dynamic>)
          .map((negocio) => Negocio.fromMap(negocio))
          .toList();

      _buildNegociosRows();
      notifyListeners();
    } catch (e) {
      print('Error en getNegociosPorEmpresa: ${e.toString()}');
    }
  }

  void _buildNegociosRows() {
    negociosRows.clear();

    for (Negocio negocio in negocios) {
      negociosRows.add(PlutoRow(cells: {
        'id': PlutoCell(value: negocio.id),
        'empresa_id': PlutoCell(value: negocio.empresaId),
        'nombre': PlutoCell(value: negocio.nombre),
        'direccion': PlutoCell(value: negocio.direccion),
        'direccion_completa': PlutoCell(
            value: negocio.direccion), // Nuevo campo para la segunda columna
        'latitud': PlutoCell(value: negocio.latitud.toString()),
        'longitud': PlutoCell(value: negocio.longitud.toString()),
        'tipo_local': PlutoCell(value: negocio.tipoLocal),
        'fecha_creacion':
            PlutoCell(value: negocio.fechaCreacion.toString().split(' ')[0]),
        'logo_url': PlutoCell(
          value: negocio.logoUrl != null
              ? "${supabaseLU.supabaseUrl}/storage/v1/object/public/nethive/logos/${negocio.logoUrl}?${DateTime.now().millisecondsSinceEpoch}"
              : '',
        ),
        'imagen_url': PlutoCell(
          value: negocio.imagenUrl != null
              ? "${supabaseLU.supabaseUrl}/storage/v1/object/public/nethive/imagenes/${negocio.imagenUrl}?${DateTime.now().millisecondsSinceEpoch}"
              : '',
        ),
        'acceder_infraestructura': PlutoCell(value: negocio.id),
        'editar': PlutoCell(value: negocio.id),
        'eliminar': PlutoCell(value: negocio.id),
        'ver_componentes': PlutoCell(value: negocio.id),
      }));
    }
  }

  // Métodos para subir archivos
  Future<void> selectLogo() async {
    logoFileName = null;
    logoToUpload = null;

    FilePickerResult? picker = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],
    );

    if (picker != null) {
      var now = DateTime.now();
      var formatter = DateFormat('yyyyMMddHHmmss');
      var timestamp = formatter.format(now);

      logoFileName = 'logo-$timestamp-${picker.files.single.name}';
      logoToUpload = picker.files.single.bytes;

      // Notificar inmediatamente después de seleccionar
      notifyListeners();
    }
  }

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

      imagenFileName = 'imagen-$timestamp-${picker.files.single.name}';
      imagenToUpload = picker.files.single.bytes;

      // Notificar inmediatamente después de seleccionar
      notifyListeners();
    }
  }

  Future<String?> uploadLogo() async {
    if (logoToUpload != null && logoFileName != null) {
      await supabaseLU.storage.from('nethive/logos').uploadBinary(
            logoFileName!,
            logoToUpload!,
            fileOptions: const FileOptions(
              cacheControl: '3600',
              upsert: false,
            ),
          );
      return logoFileName;
    }
    return null;
  }

  Future<String?> uploadImagen() async {
    if (imagenToUpload != null && imagenFileName != null) {
      await supabaseLU.storage.from('nethive/imagenes').uploadBinary(
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

  // CRUD Empresas
  Future<bool> crearEmpresa({
    required String nombre,
    required String rfc,
    required String direccion,
    required String telefono,
    required String email,
  }) async {
    try {
      final logoUrl = await uploadLogo();
      final imagenUrl = await uploadImagen();

      final res = await supabaseLU.from('empresa').insert({
        'nombre': nombre,
        'rfc': rfc,
        'direccion': direccion,
        'telefono': telefono,
        'email': email,
        'logo_url': logoUrl,
        'imagen_url': imagenUrl,
      }).select();

      if (res.isNotEmpty) {
        await getEmpresas();
        resetFormData();
        return true;
      }
      return false;
    } catch (e) {
      print('Error en crearEmpresa: ${e.toString()}');
      return false;
    }
  }

  Future<bool> crearNegocio({
    required String empresaId,
    required String nombre,
    required String direccion,
    required double latitud,
    required double longitud,
    required String tipoLocal,
  }) async {
    try {
      final logoUrl = await uploadLogo();
      final imagenUrl = await uploadImagen();

      final res = await supabaseLU.from('negocio').insert({
        'empresa_id': empresaId,
        'nombre': nombre,
        'direccion': direccion,
        'latitud': latitud,
        'longitud': longitud,
        'tipo_local': tipoLocal,
        'logo_url': logoUrl,
        'imagen_url': imagenUrl,
      }).select();

      if (res.isNotEmpty) {
        await getNegociosPorEmpresa(empresaId);
        resetFormData();
        return true;
      }
      return false;
    } catch (e) {
      print('Error en crearNegocio: ${e.toString()}');
      return false;
    }
  }

  Future<bool> eliminarEmpresa(String empresaId) async {
    try {
      // Primero eliminar todos los negocios asociados
      await supabaseLU.from('negocio').delete().eq('empresa_id', empresaId);

      // Luego eliminar la empresa
      await supabaseLU.from('empresa').delete().eq('id', empresaId);

      await getEmpresas();
      return true;
    } catch (e) {
      print('Error en eliminarEmpresa: ${e.toString()}');
      return false;
    }
  }

  Future<bool> eliminarNegocio(String negocioId) async {
    try {
      await supabaseLU.from('negocio').delete().eq('id', negocioId);

      if (empresaSeleccionadaId != null) {
        await getNegociosPorEmpresa(empresaSeleccionadaId!);
      }
      return true;
    } catch (e) {
      print('Error en eliminarNegocio: ${e.toString()}');
      return false;
    }
  }

  // Métodos de utilidad
  void setEmpresaSeleccionada(String empresaId) {
    empresaSeleccionadaId = empresaId;
    empresaSeleccionada = empresas.firstWhere((e) => e.id == empresaId);
    getNegociosPorEmpresa(empresaId);
    notifyListeners();
  }

  void resetFormData() {
    logoFileName = null;
    imagenFileName = null;
    logoToUpload = null;
    imagenToUpload = null;
    notifyListeners();
  }

  void buscarEmpresas(String busqueda) {
    getEmpresas(busqueda.isEmpty ? null : busqueda);
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
