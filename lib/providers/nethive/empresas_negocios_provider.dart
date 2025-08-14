import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/models/nethive/empresa_model.dart';
import 'package:nethive_neo/models/nethive/negocio_model.dart';

class EmpresasNegociosProvider extends ChangeNotifier {
  // Controladores de búsqueda
  final busquedaEmpresaController = TextEditingController();
  final busquedaNegocioController = TextEditingController();

  // Listas de datos
  List<Empresa> empresas = [];
  List<Negocio> negocios = [];

  // Variables para formularios
  String? logoFileName;
  String? imagenFileName;
  Uint8List? logoToUpload;
  Uint8List? imagenToUpload;

  // Variables de selección
  String? empresaSeleccionadaId;
  Empresa? empresaSeleccionada;

  // Variable para controlar si el provider está activo
  bool _isDisposed = false;

  EmpresasNegociosProvider() {
    getEmpresas();
  }

  @override
  void dispose() {
    _isDisposed = true;
    busquedaEmpresaController.dispose();
    busquedaNegocioController.dispose();
    super.dispose();
  }

  void _notifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  // EMPRESAS
  Future<void> getEmpresas() async {
    try {
      print('EmpresasNegociosProvider: Obteniendo empresas...');
      
      final response = await supabaseLU
          .from('empresa')
          .select('*')
          .order('nombre');

      if (response.isNotEmpty) {
        empresas = response
            .map<Empresa>((json) => Empresa.fromMap(json))
            .toList();
        _notifyListeners();
        print('EmpresasNegociosProvider: ${empresas.length} empresas obtenidas');
      }
    } catch (e) {
      print('EmpresasNegociosProvider: Error obteniendo empresas: $e');
    }
  }

  // NEGOCIOS
  Future<void> getNegocios({String? empresaId}) async {
    try {
      print('EmpresasNegociosProvider: Obteniendo negocios...');
      
      final response = empresaId != null
          ? await supabaseLU
              .from('negocio')
              .select('*, empresa(*)')
              .eq('empresa_id', empresaId)
              .order('nombre')
          : await supabaseLU
              .from('negocio')
              .select('*, empresa(*)')
              .order('nombre');

      if (response.isNotEmpty) {
        negocios = response
            .map<Negocio>((json) => Negocio.fromMap(json))
            .toList();
        _notifyListeners();
        print('EmpresasNegociosProvider: ${negocios.length} negocios obtenidos');
      } else {
        negocios = [];
        _notifyListeners();
      }
    } catch (e) {
      print('EmpresasNegociosProvider: Error obteniendo negocios: $e');
      negocios = [];
      _notifyListeners();
    }
  }

  // BUSCAR EMPRESAS
  void buscarEmpresas(String query) {
    // Implementar lógica de búsqueda local
    _notifyListeners();
  }

  // BUSCAR NEGOCIOS
  void buscarNegocios(String query) {
    // Implementar lógica de búsqueda local
    _notifyListeners();
  }

  // CREAR EMPRESA
  Future<bool> createEmpresa(Map<String, dynamic> empresaData) async {
    try {
      print('EmpresasNegociosProvider: Creando empresa...');
      
      final response = await supabaseLU
          .from('empresa')
          .insert(empresaData)
          .select();

      if (response.isNotEmpty) {
        await getEmpresas();
        print('EmpresasNegociosProvider: Empresa creada exitosamente');
        return true;
      }
      return false;
    } catch (e) {
      print('EmpresasNegociosProvider: Error creando empresa: $e');
      return false;
    }
  }

  // CREAR NEGOCIO
  Future<bool> createNegocio(Map<String, dynamic> negocioData) async {
    try {
      print('EmpresasNegociosProvider: Creando negocio...');
      
      final response = await supabaseLU
          .from('negocio')
          .insert(negocioData)
          .select();

      if (response.isNotEmpty) {
        await getNegocios(empresaId: empresaSeleccionadaId);
        print('EmpresasNegociosProvider: Negocio creado exitosamente');
        return true;
      }
      return false;
    } catch (e) {
      print('EmpresasNegociosProvider: Error creando negocio: $e');
      return false;
    }
  }

  // ACTUALIZAR EMPRESA
  Future<bool> updateEmpresa(String empresaId, Map<String, dynamic> empresaData) async {
    try {
      print('EmpresasNegociosProvider: Actualizando empresa $empresaId...');
      
      final response = await supabaseLU
          .from('empresa')
          .update(empresaData)
          .eq('id', empresaId)
          .select();

      if (response.isNotEmpty) {
        await getEmpresas();
        print('EmpresasNegociosProvider: Empresa actualizada exitosamente');
        return true;
      }
      return false;
    } catch (e) {
      print('EmpresasNegociosProvider: Error actualizando empresa: $e');
      return false;
    }
  }

  // ACTUALIZAR NEGOCIO
  Future<bool> updateNegocio(String negocioId, Map<String, dynamic> negocioData) async {
    try {
      print('EmpresasNegociosProvider: Actualizando negocio $negocioId...');
      
      final response = await supabaseLU
          .from('negocio')
          .update(negocioData)
          .eq('id', negocioId)
          .select();

      if (response.isNotEmpty) {
        await getNegocios(empresaId: empresaSeleccionadaId);
        print('EmpresasNegociosProvider: Negocio actualizado exitosamente');
        return true;
      }
      return false;
    } catch (e) {
      print('EmpresasNegociosProvider: Error actualizando negocio: $e');
      return false;
    }
  }

  // GESTIÓN DE IMÁGENES
  Future<void> pickLogo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.bytes != null) {
        logoFileName = result.files.single.name;
        logoToUpload = result.files.single.bytes;
        _notifyListeners();
      }
    } catch (e) {
      print('EmpresasNegociosProvider: Error seleccionando logo: $e');
    }
  }

  Future<void> pickImagen() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.bytes != null) {
        imagenFileName = result.files.single.name;
        imagenToUpload = result.files.single.bytes;
        _notifyListeners();
      }
    } catch (e) {
      print('EmpresasNegociosProvider: Error seleccionando imagen: $e');
    }
  }

  Future<String?> uploadLogo(String empresaId) async {
    if (logoToUpload == null || logoFileName == null) return null;

    try {
      final fileName = 'logo_${empresaId}_${DateTime.now().millisecondsSinceEpoch}_$logoFileName';
      
      await supabase.storage
          .from('empresas')
          .uploadBinary(fileName, logoToUpload!);

      final url = supabase.storage
          .from('empresas')
          .getPublicUrl(fileName);

      return url;
    } catch (e) {
      print('EmpresasNegociosProvider: Error subiendo logo: $e');
      return null;
    }
  }

  Future<String?> uploadImagen(String negocioId) async {
    if (imagenToUpload == null || imagenFileName == null) return null;

    try {
      final fileName = 'imagen_${negocioId}_${DateTime.now().millisecondsSinceEpoch}_$imagenFileName';
      
      await supabase.storage
          .from('negocios')
          .uploadBinary(fileName, imagenToUpload!);

      final url = supabase.storage
          .from('negocios')
          .getPublicUrl(fileName);

      return url;
    } catch (e) {
      print('EmpresasNegociosProvider: Error subiendo imagen: $e');
      return null;
    }
  }

  // LIMPIAR FORMULARIOS
  void clearEmpresaForm() {
    logoFileName = null;
    logoToUpload = null;
    _notifyListeners();
  }

  void clearNegocioForm() {
    imagenFileName = null;
    imagenToUpload = null;
    _notifyListeners();
  }

  // SETTERS
  void setEmpresaSeleccionada(String? empresaId) {
    empresaSeleccionadaId = empresaId;
    empresaSeleccionada = empresas.firstWhere(
      (empresa) => empresa.id == empresaId,
      orElse: () => Empresa(
        id: '',
        nombre: '',
        rfc: '',
        direccion: '',
        telefono: '',
        email: '',
        fechaCreacion: DateTime.now(),
      ),
    );
    
    if (empresaId != null) {
      getNegocios(empresaId: empresaId);
    }
    _notifyListeners();
  }
}
