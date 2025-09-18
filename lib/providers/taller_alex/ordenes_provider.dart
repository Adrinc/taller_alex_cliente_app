import 'package:flutter/foundation.dart';

class OrdenesProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _ordenes = [];
  int _nextId = 1;

  List<Map<String, dynamic>> get ordenes => List.unmodifiable(_ordenes);

  // Crear orden a partir de una cita
  int? crearOrdenDesdeCita(Map<String, dynamic> cita) {
    // Verificar si ya existe una orden para esta cita
    final ordenExistente = _ordenes.firstWhere(
      (orden) => orden['citaId'] == cita['id'],
      orElse: () => {},
    );
    if (ordenExistente.isNotEmpty) {
      return ordenExistente['id'] as int; // Retornar ID de orden existente
    }

    final nuevaOrden = {
      'id': _nextId++,
      'citaId': cita['id'],
      'numeroOrden': cita['numeroOrden'],
      'vehiculo': cita['vehiculo'],
      'cliente': {
        'nombre': 'Carlos Rodríguez', // Debería venir del usuario provider
        'telefono': '55 1234 5678',
        'email': 'carlos.rodriguez@email.com',
      },
      'sucursal': cita['sucursal'],
      'servicios': cita['servicios'],
      'fechaCita': cita['fecha'],
      'horaCita': cita['hora'],
      'fechaCreacion': DateTime.now(),
      'estado': 'Recibida',
      'progreso': 0,
      'diagnostico': null,
      'serviciosAdicionales': <Map<String, dynamic>>[],
      'observaciones': cita['notas'] ?? '',
      'tecnicoAsignado': _asignarTecnico(),
      'tiempoEstimado': cita['tiempoEstimado'] ?? 0,
      'subtotal': cita['subtotal'] ?? 0.0,
      'descuento': 0.0,
      'impuestos': (cita['subtotal'] ?? 0.0) * 0.16, // IVA 16%
      'total': (cita['subtotal'] ?? 0.0) * 1.16,
      'cuponAplicado': cita['cupon'],
      'historial': [
        {
          'fecha': DateTime.now(),
          'estado': 'Recibida',
          'descripcion': 'Orden de servicio creada desde cita programada',
          'usuario': 'Sistema',
        }
      ],
    };

    _ordenes.add(nuevaOrden);
    notifyListeners();

    return nuevaOrden['id'] as int; // Retornar ID de la nueva orden
  }

  // Obtener orden por ID de cita
  Map<String, dynamic>? getOrdenPorCitaId(int citaId) {
    try {
      return _ordenes.firstWhere((orden) => orden['citaId'] == citaId);
    } catch (e) {
      return null;
    }
  }

  // Obtener orden por número de orden
  Map<String, dynamic>? getOrdenPorNumero(String numeroOrden) {
    try {
      return _ordenes
          .firstWhere((orden) => orden['numeroOrden'] == numeroOrden);
    } catch (e) {
      return null;
    }
  }

  // Actualizar estado de la orden
  void actualizarEstadoOrden(int ordenId, String nuevoEstado,
      {String? descripcion}) {
    final index = _ordenes.indexWhere((orden) => orden['id'] == ordenId);
    if (index != -1) {
      _ordenes[index]['estado'] = nuevoEstado;
      _ordenes[index]['progreso'] = _calcularProgreso(nuevoEstado);

      // Agregar al historial
      _ordenes[index]['historial'].add({
        'fecha': DateTime.now(),
        'estado': nuevoEstado,
        'descripcion': descripcion ?? 'Estado actualizado a $nuevoEstado',
        'usuario': 'Taller Alex',
      });

      notifyListeners();
    }
  }

  // Agregar diagnóstico
  void agregarDiagnostico(int ordenId, Map<String, dynamic> diagnostico) {
    final index = _ordenes.indexWhere((orden) => orden['id'] == ordenId);
    if (index != -1) {
      _ordenes[index]['diagnostico'] = diagnostico;
      _ordenes[index]['historial'].add({
        'fecha': DateTime.now(),
        'estado': 'Diagnosticado',
        'descripcion': 'Diagnóstico completado: ${diagnostico['resumen']}',
        'usuario': _ordenes[index]['tecnicoAsignado']['nombre'],
      });
      notifyListeners();
    }
  }

  // Agregar servicios adicionales
  void agregarServiciosAdicionales(
      int ordenId, List<Map<String, dynamic>> serviciosAdicionales) {
    final index = _ordenes.indexWhere((orden) => orden['id'] == ordenId);
    if (index != -1) {
      _ordenes[index]['serviciosAdicionales'].addAll(serviciosAdicionales);

      // Recalcular totales
      final nuevoCosto = serviciosAdicionales.fold<double>(
          0.0, (total, servicio) => total + (servicio['price'] ?? 0.0));

      _ordenes[index]['subtotal'] += nuevoCosto;
      _ordenes[index]['impuestos'] = _ordenes[index]['subtotal'] * 0.16;
      _ordenes[index]['total'] = _ordenes[index]['subtotal'] +
          _ordenes[index]['impuestos'] -
          _ordenes[index]['descuento'];

      notifyListeners();
    }
  }

  // Asignar técnico aleatoriamente (demo)
  Map<String, dynamic> _asignarTecnico() {
    final tecnicos = [
      {'id': 1, 'nombre': 'Miguel Hernández', 'especialidad': 'Motor'},
      {'id': 2, 'nombre': 'Ana Martínez', 'especialidad': 'Frenos'},
      {'id': 3, 'nombre': 'Roberto López', 'especialidad': 'Transmisión'},
      {'id': 4, 'nombre': 'Carmen Ruiz', 'especialidad': 'Electricidad'},
    ];

    return tecnicos[(DateTime.now().millisecond % tecnicos.length)];
  }

  // Calcular progreso basado en el estado
  int _calcularProgreso(String estado) {
    switch (estado) {
      case 'Recibida':
        return 10;
      case 'En diagnóstico':
        return 25;
      case 'Diagnosticada':
        return 40;
      case 'Esperando aprobación':
        return 50;
      case 'Aprobada':
        return 60;
      case 'En reparación':
        return 80;
      case 'Completada':
        return 100;
      default:
        return 0;
    }
  }

  // Simular progreso automático para demo
  void simularProgresoOrden(int ordenId) async {
    final estados = [
      'En diagnóstico',
      'Diagnosticada',
      'Esperando aprobación',
      'Aprobada',
      'En reparación',
      'Completada'
    ];

    for (String estado in estados) {
      await Future.delayed(const Duration(seconds: 2));
      actualizarEstadoOrden(ordenId, estado);
    }
  }

  // Obtener órdenes activas
  List<Map<String, dynamic>> getOrdenesActivas() {
    return _ordenes
        .where((orden) =>
            orden['estado'] != 'Completada' && orden['estado'] != 'Cancelada')
        .toList();
  }

  // Obtener historial de órdenes
  List<Map<String, dynamic>> getHistorialOrdenes() {
    return _ordenes
        .where((orden) =>
            orden['estado'] == 'Completada' || orden['estado'] == 'Cancelada')
        .toList();
  }
}
