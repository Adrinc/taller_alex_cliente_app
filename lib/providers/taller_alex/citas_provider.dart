import 'package:flutter/foundation.dart';

class CitasProvider extends ChangeNotifier {
  // Referencia al provider de notificaciones (se inyectará)
  Function(Map<String, dynamic>)? _onCitaCreada;
  final List<Map<String, dynamic>> _citas = [];
  int _nextId = 1;

  List<Map<String, dynamic>> get citas => List.unmodifiable(_citas);

  // Configurar callback para notificaciones
  void configurarNotificaciones(Function(Map<String, dynamic>) callback) {
    _onCitaCreada = callback;
  }

  void agregarCita({
    required Map<String, dynamic> vehiculo,
    required Map<String, dynamic> sucursal,
    required List<Map<String, dynamic>> servicios,
    required DateTime fecha,
    required String hora,
    String? notas,
    String? cupon,
  }) {
    final subtotal = calcularTotalCita(servicios);
    final tiempoTotal = calcularTiempoTotal(servicios);

    final nuevaCita = {
      'id': _nextId++,
      'vehiculo': vehiculo,
      'sucursal': sucursal,
      'servicios': servicios,
      'fecha': fecha,
      'hora': hora,
      'notas': notas ?? '',
      'cupon': cupon ?? '',
      'subtotal': subtotal,
      'tiempoEstimado': tiempoTotal,
      'estado': 'Programada',
      'fechaCreacion': DateTime.now(),
      'numeroOrden':
          'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
    };

    _citas.add(nuevaCita);

    // Generar notificación automática de cita creada
    _onCitaCreada?.call(nuevaCita);

    notifyListeners();
  }

  void actualizarEstadoCita(int citaId, String nuevoEstado) {
    final index = _citas.indexWhere((cita) => cita['id'] == citaId);
    if (index != -1) {
      _citas[index]['estado'] = nuevoEstado;
      notifyListeners();
    }
  }

  void cancelarCita(int citaId) {
    final index = _citas.indexWhere((cita) => cita['id'] == citaId);
    if (index != -1) {
      _citas[index]['estado'] = 'Cancelada';
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> getCitasActivas() {
    return _citas
        .where((cita) =>
            cita['estado'] != 'Cancelada' && cita['estado'] != 'Completada')
        .toList();
  }

  List<Map<String, dynamic>> getHistorialCitas() {
    return _citas
        .where((cita) =>
            cita['estado'] == 'Cancelada' || cita['estado'] == 'Completada')
        .toList();
  }

  double calcularTotalCita(List<Map<String, dynamic>> servicios) {
    return servicios.fold(
        0.0, (total, servicio) => total + (servicio['price'] ?? 0.0));
  }

  int calcularTiempoTotal(List<Map<String, dynamic>> servicios) {
    return servicios.fold(
        0, (total, servicio) => total + ((servicio['duration'] as int?) ?? 0));
  }
}
