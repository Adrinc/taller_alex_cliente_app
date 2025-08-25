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
  String? _negocioId; // AGREGADO: ID del negocio seleccionado
  String? _distribucionId; // AGREGADO: ID de la distribución seleccionada
  CategoriaComponente? _categoriaSeleccionada;
  String _nombre = '';
  String _descripcion = '';
  String _ubicacion = '';
  Map<String, dynamic> _detallesEspecificos = {};

  // Lista de categorías disponibles
  List<CategoriaComponente> _categorias = [];

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingCategorias => _isLoadingCategorias;
  String? get error => _error;
  String? get rfidCode => _rfidCode;
  String? get negocioId => _negocioId;
  String? get distribucionId => _distribucionId;
  CategoriaComponente? get categoriaSeleccionada => _categoriaSeleccionada;
  String get nombre => _nombre;
  String get descripcion => _descripcion;
  String get ubicacion => _ubicacion;
  Map<String, dynamic> get detallesEspecificos => _detallesEspecificos;
  List<CategoriaComponente> get categorias => _categorias;

  // Setters
  void setRfidCode(String? rfid) {
    _rfidCode = rfid;
    notifyListeners();
  }

  void setNegocioId(String? negocioId) {
    _negocioId = negocioId;
    notifyListeners();
  }

  void setDistribucionId(String? distribucionId) {
    _distribucionId = distribucionId;
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

  void setUbicacion(String ubicacion) {
    _ubicacion = ubicacion;
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
    _negocioId = null;
    _distribucionId = null;
    _categoriaSeleccionada = null;
    _nombre = '';
    _descripcion = '';
    _ubicacion = '';
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

    if (_negocioId == null || _negocioId!.trim().isEmpty) {
      return 'Debe seleccionar un negocio';
    }

    if (_categoriaSeleccionada == null) {
      return 'Debe seleccionar una categoría';
    }

    if (_distribucionId == null || _distribucionId!.trim().isEmpty) {
      return 'Debe seleccionar una distribución';
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
          .eq('rfid', _rfidCode!)
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
        'ubicacion': _ubicacion.trim().isEmpty ? null : _ubicacion.trim(),
        'rfid': _rfidCode,
        'negocio_id': _negocioId,
        'categoria_id': _categoriaSeleccionada!.id,
        'distribucion_id': _distribucionId, // AGREGADO: ID de la distribución
        'fecha_registro': DateTime.now().toIso8601String(),
        'fecha_ultimo_escaneo': DateTime.now().toIso8601String(),
        'tecnico_registro_id': currentUser?.id,
        'activo': true,
        'en_uso': false,
      };

      final componenteResponse = await supabaseLU
          .from('componente')
          .insert(componenteData)
          .select('id')
          .single();

      final componenteId = componenteResponse['id'] as String;

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
  Future<void> _crearDetallesEspecificos(String componenteId) async {
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

  Future<void> _crearDetalleCable(String componenteId) async {
    final detalleData = {
      'componente_id': componenteId,
      'tipo_cable': _detallesEspecificos['tipo_cable'],
      'color': _detallesEspecificos['color'],
      'tamaño': _detallesEspecificos['tamaño'] != null
          ? double.tryParse(_detallesEspecificos['tamaño'].toString())
          : null,
      'tipo_conector': _detallesEspecificos['tipo_conector'],
    };

    await supabaseLU.from('detalle_cable').insert(detalleData);
  }

  Future<void> _crearDetalleSwitch(String componenteId) async {
    final detalleData = {
      'componente_id': componenteId,
      'marca': _detallesEspecificos['marca'],
      'modelo': _detallesEspecificos['modelo'],
      'numero_serie': _detallesEspecificos['numero_serie'],
      'administrable': _detallesEspecificos['administrable'] ?? false,
      'poe': _detallesEspecificos['poe'] ?? false,
      'cantidad_puertos': _detallesEspecificos['cantidad_puertos'] != null
          ? int.tryParse(_detallesEspecificos['cantidad_puertos'].toString())
          : null,
      'velocidad_puertos': _detallesEspecificos['velocidad_puertos'],
      'tipo_puertos': _detallesEspecificos['tipo_puertos'],
      'direccion_ip': _detallesEspecificos['direccion_ip'],
      'firmware': _detallesEspecificos['firmware'],
    };

    await supabaseLU.from('detalle_switch').insert(detalleData);
  }

  Future<void> _crearDetallePatchPanel(String componenteId) async {
    final detalleData = {
      'componente_id': componenteId,
      'tipo_conector': _detallesEspecificos['tipo_conector'],
      'numero_puertos': _detallesEspecificos['numero_puertos'] != null
          ? int.tryParse(_detallesEspecificos['numero_puertos'].toString())
          : null,
      'categoria': _detallesEspecificos['categoria'],
      'tipo_montaje': _detallesEspecificos['tipo_montaje'],
      'numeracion_frontal': _detallesEspecificos['numeracion_frontal'] ?? false,
      'panel_ciego': _detallesEspecificos['panel_ciego'] ?? false,
    };

    await supabaseLU.from('detalle_patch_panel').insert(detalleData);
  }

  Future<void> _crearDetalleRack(String componenteId) async {
    final detalleData = {
      'componente_id': componenteId,
      'tipo': _detallesEspecificos['tipo'],
      'altura_u': _detallesEspecificos['altura_u'] != null
          ? int.tryParse(_detallesEspecificos['altura_u'].toString())
          : null,
      'profundidad_cm': _detallesEspecificos['profundidad_cm'] != null
          ? int.tryParse(_detallesEspecificos['profundidad_cm'].toString())
          : null,
      'ancho_cm': _detallesEspecificos['ancho_cm'] != null
          ? int.tryParse(_detallesEspecificos['ancho_cm'].toString())
          : null,
      'ventilacion_integrada':
          _detallesEspecificos['ventilacion_integrada'] ?? false,
      'puertas_con_llave': _detallesEspecificos['puertas_con_llave'] ?? false,
      'ruedas': _detallesEspecificos['ruedas'] ?? false,
      'color': _detallesEspecificos['color'],
    };

    await supabaseLU.from('detalle_rack').insert(detalleData);
  }

  Future<void> _crearDetalleUPS(String componenteId) async {
    final detalleData = {
      'componente_id': componenteId,
      'tipo': _detallesEspecificos['tipo'],
      'marca': _detallesEspecificos['marca'],
      'modelo': _detallesEspecificos['modelo'],
      'voltaje_entrada': _detallesEspecificos['voltaje_entrada'],
      'voltaje_salida': _detallesEspecificos['voltaje_salida'],
      'capacidad_va': _detallesEspecificos['capacidad_va'] != null
          ? int.tryParse(_detallesEspecificos['capacidad_va'].toString())
          : null,
      'autonomia_minutos': _detallesEspecificos['autonomia_minutos'] != null
          ? int.tryParse(_detallesEspecificos['autonomia_minutos'].toString())
          : null,
      'cantidad_tomas': _detallesEspecificos['cantidad_tomas'] != null
          ? int.tryParse(_detallesEspecificos['cantidad_tomas'].toString())
          : null,
      'rackeable': _detallesEspecificos['rackeable'] ?? false,
    };

    await supabaseLU.from('detalle_ups').insert(detalleData);
  }

  // Métodos para configurar campos específicos por categoría
  Map<String, dynamic> getCamposCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'cable':
        return {
          'tipo_cable': {
            'type': 'string',
            'label': 'Tipo de Cable',
            'required': false
          },
          'color': {'type': 'string', 'label': 'Color', 'required': false},
          'tamaño': {
            'type': 'double',
            'label': 'Tamaño (metros)',
            'required': false
          },
          'tipo_conector': {
            'type': 'string',
            'label': 'Tipo de Conector',
            'required': false
          },
        };
      case 'switch':
        return {
          'marca': {'type': 'string', 'label': 'Marca', 'required': false},
          'modelo': {'type': 'string', 'label': 'Modelo', 'required': false},
          'numero_serie': {
            'type': 'string',
            'label': 'Número de Serie',
            'required': false
          },
          'administrable': {
            'type': 'bool',
            'label': 'Administrable',
            'required': false
          },
          'poe': {'type': 'bool', 'label': 'Soporte PoE', 'required': false},
          'cantidad_puertos': {
            'type': 'int',
            'label': 'Cantidad de Puertos',
            'required': false
          },
          'velocidad_puertos': {
            'type': 'string',
            'label': 'Velocidad de Puertos',
            'required': false
          },
          'tipo_puertos': {
            'type': 'string',
            'label': 'Tipo de Puertos',
            'required': false
          },
          'direccion_ip': {
            'type': 'string',
            'label': 'Dirección IP',
            'required': false
          },
          'firmware': {
            'type': 'string',
            'label': 'Firmware',
            'required': false
          },
        };
      case 'patch panel':
        return {
          'tipo_conector': {
            'type': 'string',
            'label': 'Tipo de Conector',
            'required': false
          },
          'numero_puertos': {
            'type': 'int',
            'label': 'Número de Puertos',
            'required': false
          },
          'categoria': {
            'type': 'string',
            'label': 'Categoría',
            'required': false
          },
          'tipo_montaje': {
            'type': 'string',
            'label': 'Tipo de Montaje',
            'required': false
          },
          'numeracion_frontal': {
            'type': 'bool',
            'label': 'Numeración Frontal',
            'required': false
          },
          'panel_ciego': {
            'type': 'bool',
            'label': 'Panel Ciego',
            'required': false
          },
        };
      case 'rack':
        return {
          'tipo': {'type': 'string', 'label': 'Tipo', 'required': false},
          'altura_u': {'type': 'int', 'label': 'Altura (U)', 'required': false},
          'profundidad_cm': {
            'type': 'int',
            'label': 'Profundidad (cm)',
            'required': false
          },
          'ancho_cm': {'type': 'int', 'label': 'Ancho (cm)', 'required': false},
          'ventilacion_integrada': {
            'type': 'bool',
            'label': 'Ventilación Integrada',
            'required': false
          },
          'puertas_con_llave': {
            'type': 'bool',
            'label': 'Puertas con Llave',
            'required': false
          },
          'ruedas': {'type': 'bool', 'label': 'Ruedas', 'required': false},
          'color': {'type': 'string', 'label': 'Color', 'required': false},
        };
      case 'ups':
        return {
          'tipo': {'type': 'string', 'label': 'Tipo', 'required': false},
          'marca': {'type': 'string', 'label': 'Marca', 'required': false},
          'modelo': {'type': 'string', 'label': 'Modelo', 'required': false},
          'voltaje_entrada': {
            'type': 'string',
            'label': 'Voltaje de Entrada',
            'required': false
          },
          'voltaje_salida': {
            'type': 'string',
            'label': 'Voltaje de Salida',
            'required': false
          },
          'capacidad_va': {
            'type': 'int',
            'label': 'Capacidad (VA)',
            'required': false
          },
          'autonomia_minutos': {
            'type': 'int',
            'label': 'Autonomía (minutos)',
            'required': false
          },
          'cantidad_tomas': {
            'type': 'int',
            'label': 'Cantidad de Tomas',
            'required': false
          },
          'rackeable': {
            'type': 'bool',
            'label': 'Rackeable',
            'required': false
          },
        };
      default:
        return {};
    }
  }
}
