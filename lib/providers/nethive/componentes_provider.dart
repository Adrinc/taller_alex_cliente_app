import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/models/nethive/categoria_componente_model.dart';
import 'package:nethive_neo/models/nethive/componente_model.dart';
import 'package:nethive_neo/models/nethive/distribucion_model.dart';
import 'package:nethive_neo/models/nethive/conexion_componente_model.dart';
import 'package:nethive_neo/models/nethive/topologia_completa_model.dart';
import 'package:nethive_neo/models/nethive/rol_logico_componente_model.dart';
import 'package:nethive_neo/models/nethive/tipo_distribucion_model.dart';
import 'package:nethive_neo/models/nethive/vista_conexiones_por_cables_model.dart';
import 'package:nethive_neo/models/nethive/vista_topologia_por_negocio_model.dart';

class ComponentesProvider extends ChangeNotifier {
  // Controladores de búsqueda
  final busquedaComponenteController = TextEditingController();
  final busquedaCategoriaController = TextEditingController();

  // Listas principales
  List<CategoriaComponente> categorias = [];
  List<RolLogicoComponente> rolesLogicos = [];
  List<TipoDistribucion> tiposDistribucion = [];
  List<Componente> componentes = [];

  // Nueva estructura de topología optimizada
  TopologiaCompleta? topologiaCompleta;
  List<ComponenteTopologia> componentesTopologia = [];
  List<ConexionDatos> conexionesDatos = [];
  List<ConexionEnergia> conexionesEnergia = [];

  // Listas para retrocompatibilidad
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
  bool isLoadingRacks = false;
  List<String> problemasTopologia = [];

  // Variable para controlar si el provider está activo
  bool _isDisposed = false;

  ComponentesProvider() {
    getCategorias();
    getRolesLogicos();
    getTiposDistribucion();
  }

  @override
  void dispose() {
    _isDisposed = true;
    busquedaComponenteController.dispose();
    busquedaCategoriaController.dispose();
    super.dispose();
  }

  void _notifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  // CATEGORÍAS
  Future<void> getCategorias() async {
    try {
      print('ComponentesProvider: Obteniendo categorías...');
      
      final response = await supabaseLU
          .from('categoria_componente')
          .select('*')
          .order('nombre');

      if (response.isNotEmpty) {
        categorias = response
            .map<CategoriaComponente>((json) => CategoriaComponente.fromJson(json))
            .toList();
        _notifyListeners();
        print('ComponentesProvider: ${categorias.length} categorías obtenidas');
      }
    } catch (e) {
      print('ComponentesProvider: Error obteniendo categorías: $e');
    }
  }

  // ROLES LÓGICOS
  Future<void> getRolesLogicos() async {
    try {
      print('ComponentesProvider: Obteniendo roles lógicos...');
      
      final response = await supabaseLU
          .from('rol_logico_componente')
          .select('*')
          .order('nombre');

      if (response.isNotEmpty) {
        rolesLogicos = response
            .map<RolLogicoComponente>((json) => RolLogicoComponente.fromMap(json))
            .toList();
        _notifyListeners();
        print('ComponentesProvider: ${rolesLogicos.length} roles lógicos obtenidos');
      }
    } catch (e) {
      print('ComponentesProvider: Error obteniendo roles lógicos: $e');
    }
  }

  // TIPOS DISTRIBUCIÓN
  Future<void> getTiposDistribucion() async {
    try {
      print('ComponentesProvider: Obteniendo tipos de distribución...');
      
      final response = await supabaseLU
          .from('tipo_distribucion')
          .select('*')
          .order('nombre');

      if (response.isNotEmpty) {
        tiposDistribucion = response
            .map<TipoDistribucion>((json) => TipoDistribucion.fromMap(json))
            .toList();
        _notifyListeners();
        print('ComponentesProvider: ${tiposDistribucion.length} tipos de distribución obtenidos');
      }
    } catch (e) {
      print('ComponentesProvider: Error obteniendo tipos de distribución: $e');
    }
  }

  // COMPONENTES
  Future<void> getComponentes({String? negocioId}) async {
    if (negocioId == null) return;
    
    try {
      print('ComponentesProvider: Obteniendo componentes para negocio $negocioId...');
      
      final response = await supabaseLU
          .from('componente')
          .select('''
            *,
            categoria_componente!inner(*),
            distribucion(*)
          ''')
          .eq('negocio_id', negocioId)
          .order('nombre');

      if (response.isNotEmpty) {
        componentes = response
            .map<Componente>((json) => Componente.fromJson(json))
            .toList();
        _notifyListeners();
        print('ComponentesProvider: ${componentes.length} componentes obtenidos');
      } else {
        componentes = [];
        _notifyListeners();
      }
    } catch (e) {
      print('ComponentesProvider: Error obteniendo componentes: $e');
      componentes = [];
      _notifyListeners();
    }
  }

  // BUSCAR COMPONENTES
  void buscarComponentes(String query) {
    // Implementar lógica de búsqueda local o por API
    _notifyListeners();
  }

  // CREAR COMPONENTE
  Future<bool> createComponente(Map<String, dynamic> componenteData) async {
    try {
      print('ComponentesProvider: Creando componente...');
      
      final response = await supabaseLU
          .from('componente')
          .insert(componenteData)
          .select();

      if (response.isNotEmpty) {
        // Actualizar lista local
        await getComponentes(negocioId: negocioSeleccionadoId);
        print('ComponentesProvider: Componente creado exitosamente');
        return true;
      }
      return false;
    } catch (e) {
      print('ComponentesProvider: Error creando componente: $e');
      return false;
    }
  }

  // ACTUALIZAR COMPONENTE
  Future<bool> updateComponente(String componenteId, Map<String, dynamic> componenteData) async {
    try {
      print('ComponentesProvider: Actualizando componente $componenteId...');
      
      final response = await supabaseLU
          .from('componente')
          .update(componenteData)
          .eq('id', componenteId)
          .select();

      if (response.isNotEmpty) {
        // Actualizar lista local
        await getComponentes(negocioId: negocioSeleccionadoId);
        print('ComponentesProvider: Componente actualizado exitosamente');
        return true;
      }
      return false;
    } catch (e) {
      print('ComponentesProvider: Error actualizando componente: $e');
      return false;
    }
  }

  // ELIMINAR COMPONENTE
  Future<bool> deleteComponente(String componenteId) async {
    try {
      print('ComponentesProvider: Eliminando componente $componenteId...');
      
      await supabaseLU
          .from('componente')
          .delete()
          .eq('id', componenteId);

      // Actualizar lista local
      await getComponentes(negocioId: negocioSeleccionadoId);
      print('ComponentesProvider: Componente eliminado exitosamente');
      return true;
    } catch (e) {
      print('ComponentesProvider: Error eliminando componente: $e');
      return false;
    }
  }

  // GESTIÓN DE IMÁGENES
  Future<void> pickImage() async {
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
      print('ComponentesProvider: Error seleccionando imagen: $e');
    }
  }

  Future<String?> uploadImage(String componenteId) async {
    if (imagenToUpload == null || imagenFileName == null) return null;

    try {
      final fileName = '${componenteId}_${DateTime.now().millisecondsSinceEpoch}_$imagenFileName';
      
      await supabaseLU.storage
          .from('componentes')
          .uploadBinary(fileName, imagenToUpload!);

      final url = supabaseLU.storage
          .from('componentes')
          .getPublicUrl(fileName);

      return url;
    } catch (e) {
      print('ComponentesProvider: Error subiendo imagen: $e');
      return null;
    }
  }

  // LIMPIAR FORMULARIO
  void clearForm() {
    imagenFileName = null;
    imagenToUpload = null;
    categoriaSeleccionadaId = null;
    showDetallesEspecificos = false;
    _notifyListeners();
  }

  // SETTERS
  void setNegocioSeleccionado(String? negocioId, String? negocioNombre) {
    negocioSeleccionadoId = negocioId;
    negocioSeleccionadoNombre = negocioNombre;
    if (negocioId != null) {
      getComponentes(negocioId: negocioId);
    }
    _notifyListeners();
  }

  void setEmpresaSeleccionada(String? empresaId) {
    empresaSeleccionadaId = empresaId;
    _notifyListeners();
  }

  void setCategoriaSeleccionada(int? categoriaId) {
    categoriaSeleccionadaId = categoriaId;
    showDetallesEspecificos = categoriaId != null;
    _notifyListeners();
  }
}
