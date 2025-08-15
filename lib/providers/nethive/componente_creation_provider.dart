import 'package:flutter/foundation.dart';
import 'package:nethive_neo/models/nethive/categoria_componente_model.dart';
import 'package:nethive_neo/helpers/globals.dart';

class ComponenteCreationProvider extends ChangeNotifier {
  // Estado del proceso de creación
  bool _isLoading = false;
  bool _isLoadingCategorias = false;
  String? _error;

  // Datos del formulario
  String? _rfidCode;
  CategoriaComponente? _categoriaSeleccionada;
  String _nombre = '';
  String _descripcion = '';
  Map<String, dynamic> _detallesEspecificos = {};

  // Lista de categorías disponibles
  List<CategoriaComponente> _categorias = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingCategorias => _isLoadingCategorias;
  String? get error => _error;
  String? get rfidCode => _rfidCode;
  CategoriaComponente? get categoriaSeleccionada => _categoriaSeleccionada;
  String get nombre => _nombre;
  String get descripcion => _descripcion;
  Map<String, dynamic> get detallesEspecificos => _detallesEspecificos;
  List<CategoriaComponente> get categorias => _categorias;

  // Setters
  void setRfidCode(String? rfid) {
    _rfidCode = rfid;
    notifyListeners();
  }

  void setCategoriaSeleccionada(CategoriaComponente? categoria) {
    _categoriaSeleccionada = categoria;
    _detallesEspecificos.clear(); // Limpiar detalles al cambiar categoría
    notifyListeners();
  }

  void setNombre(String nombre) {
    _nombre = nombre;
    notifyListeners();
  }

  void setDescripcion(String descripcion) {
    _descripcion = descripcion;
    notifyListeners();
  }

  void setDetalleEspecifico(String key, dynamic value) {
    _detallesEspecificos[key] = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _error = null;
    _rfidCode = null;
    _categoriaSeleccionada = null;
    _nombre = '';
    _descripcion = '';
    _detallesEspecificos.clear();
    notifyListeners();
  }

  // Cargar categorías de componentes desde Supabase
  Future<void> cargarCategorias() async {
    try {
      _isLoadingCategorias = true;
      _error = null;
      notifyListeners();

      final response = await supabaseLU
          .from('categoria_componente')
          .select('*')
          .order('nombre');

      _categorias = (response as List)
          .map((cat) => CategoriaComponente.fromMap(cat))
          .toList();

      _isLoadingCategorias = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar categorías: $e';
      _isLoadingCategorias = false;
      notifyListeners();
    }
  }

  // Validar datos del formulario
  String? validarFormulario() {
    if (_rfidCode == null || _rfidCode!.trim().isEmpty) {
      return 'El código RFID es obligatorio';
    }

    if (_categoriaSeleccionada == null) {
      return 'Debe seleccionar una categoría';
    }

    if (_nombre.trim().isEmpty) {
      return 'El nombre del componente es obligatorio';
    }

    return null; // Sin errores
  }

  // Crear componente en Supabase
  Future<bool> crearComponente() async {
    final errorValidacion = validarFormulario();
    if (errorValidacion != null) {
      _error = errorValidacion;
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Verificar que el RFID no esté ya asignado
      final existingComponent = await supabaseLU
          .from('componente')
          .select('id')
          .eq('codigo_rfid', _rfidCode!)
          .maybeSingle();

      if (existingComponent != null) {
        _error = 'Este código RFID ya está asignado a otro componente';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Crear el componente principal
      final componenteData = {
        'nombre': _nombre.trim(),
        'descripcion': _descripcion.trim().isEmpty ? null : _descripcion.trim(),
        'codigo_rfid': _rfidCode,
        'categoria_componente_fk': _categoriaSeleccionada!.id,
        'fecha_creacion': DateTime.now().toIso8601String(),
        'activo': true,
      };

      final componenteResponse = await supabaseLU
          .from('componente')
          .insert(componenteData)
          .select('id')
          .single();

      final componenteId = componenteResponse['id'];

      // Crear detalles específicos según la categoría
      if (_detallesEspecificos.isNotEmpty) {
        await _crearDetallesEspecificos(componenteId);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al crear el componente: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Crear detalles específicos según la categoría
  Future<void> _crearDetallesEspecificos(int componenteId) async {
    final categoria = _categoriaSeleccionada!.nombre.toLowerCase();

    switch (categoria) {
      case 'cable':
        await _crearDetalleCable(componenteId);
        break;
      case 'switch':
        await _crearDetalleSwitch(componenteId);
        break;
      case 'patch panel':
        await _crearDetallePatchPanel(componenteId);
        break;
      case 'rack':
        await _crearDetalleRack(componenteId);
        break;
      case 'ups':
        await _crearDetalleUPS(componenteId);
        break;
    }
  }

  Future<void> _crearDetalleCable(int componenteId) async {
    final detalleData = {
      'componente_fk': componenteId,
      'longitud': _detallesEspecificos['longitud'],
      'tipo_cable': _detallesEspecificos['tipo_cable'],
      'color': _detallesEspecificos['color'],
      'categoria': _detallesEspecificos['categoria'],
    };

    await supabaseLU.from('detalle_cable').insert(detalleData);
  }

  Future<void> _crearDetalleSwitch(int componenteId) async {
    final detalleData = {
      'componente_fk': componenteId,
      'numero_puertos': _detallesEspecificos['numero_puertos'],
      'velocidad': _detallesEspecificos['velocidad'],
      'tipo_switch': _detallesEspecificos['tipo_switch'],
      'poe_support': _detallesEspecificos['poe_support'] ?? false,
    };

    await supabaseLU.from('detalle_switch').insert(detalleData);
  }

  Future<void> _crearDetallePatchPanel(int componenteId) async {
    final detalleData = {
      'componente_fk': componenteId,
      'numero_puertos': _detallesEspecificos['numero_puertos'],
      'tipo_conector': _detallesEspecificos['tipo_conector'],
      'categoria': _detallesEspecificos['categoria'],
    };

    await supabaseLU.from('detalle_patch_panel').insert(detalleData);
  }

  Future<void> _crearDetalleRack(int componenteId) async {
    final detalleData = {
      'componente_fk': componenteId,
      'unidades_rack': _detallesEspecificos['unidades_rack'],
      'ancho': _detallesEspecificos['ancho'],
      'profundidad': _detallesEspecificos['profundidad'],
      'tipo_rack': _detallesEspecificos['tipo_rack'],
    };

    await supabaseLU.from('detalle_rack').insert(detalleData);
  }

  Future<void> _crearDetalleUPS(int componenteId) async {
    final detalleData = {
      'componente_fk': componenteId,
      'potencia_va': _detallesEspecificos['potencia_va'],
      'potencia_watts': _detallesEspecificos['potencia_watts'],
      'tiempo_respaldo': _detallesEspecificos['tiempo_respaldo'],
      'tipo_ups': _detallesEspecificos['tipo_ups'],
    };

    await supabaseLU.from('detalle_ups').insert(detalleData);
  }

  // Métodos para configurar campos específicos por categoría
  Map<String, dynamic> getCamposCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'cable':
        return {
          'longitud': {
            'type': 'double',
            'label': 'Longitud (metros)',
            'required': false
          },
          'tipo_cable': {
            'type': 'string',
            'label': 'Tipo de Cable',
            'required': false
          },
          'color': {'type': 'string', 'label': 'Color', 'required': false},
          'categoria': {
            'type': 'string',
            'label': 'Categoría (Cat5e, Cat6, etc.)',
            'required': false
          },
        };
      case 'switch':
        return {
          'numero_puertos': {
            'type': 'int',
            'label': 'Número de Puertos',
            'required': false
          },
          'velocidad': {
            'type': 'string',
            'label': 'Velocidad (10/100/1000)',
            'required': false
          },
          'tipo_switch': {
            'type': 'string',
            'label': 'Tipo de Switch',
            'required': false
          },
          'poe_support': {
            'type': 'bool',
            'label': 'Soporte PoE',
            'required': false
          },
        };
      case 'patch panel':
        return {
          'numero_puertos': {
            'type': 'int',
            'label': 'Número de Puertos',
            'required': false
          },
          'tipo_conector': {
            'type': 'string',
            'label': 'Tipo de Conector',
            'required': false
          },
          'categoria': {
            'type': 'string',
            'label': 'Categoría',
            'required': false
          },
        };
      case 'rack':
        return {
          'unidades_rack': {
            'type': 'int',
            'label': 'Unidades de Rack (U)',
            'required': false
          },
          'ancho': {'type': 'double', 'label': 'Ancho (cm)', 'required': false},
          'profundidad': {
            'type': 'double',
            'label': 'Profundidad (cm)',
            'required': false
          },
          'tipo_rack': {
            'type': 'string',
            'label': 'Tipo de Rack',
            'required': false
          },
        };
      case 'ups':
        return {
          'potencia_va': {
            'type': 'int',
            'label': 'Potencia (VA)',
            'required': false
          },
          'potencia_watts': {
            'type': 'int',
            'label': 'Potencia (Watts)',
            'required': false
          },
          'tiempo_respaldo': {
            'type': 'int',
            'label': 'Tiempo de Respaldo (min)',
            'required': false
          },
          'tipo_ups': {
            'type': 'string',
            'label': 'Tipo de UPS',
            'required': false
          },
        };
      default:
        return {};
    }
  }
}
