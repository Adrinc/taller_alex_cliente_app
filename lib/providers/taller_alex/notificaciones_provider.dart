import 'package:flutter/foundation.dart';

class NotificacionesProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _notificaciones = [
    // Notificación coherente con ORD-2025-001 de mis_ordenes_page.dart
    {
      'id': 'NOT-001',
      'type': 'aprobacion',
      'category': 'Servicios',
      'title': 'Aprobación requerida - Frenos',
      'message':
          'Se detectó desgaste excesivo en balatas delanteras y discos traseros de tu Honda Civic (ABC-123). Requiere tu aprobación para proceder. Costo estimado: \$2,500',
      'date': DateTime.now().subtract(const Duration(hours: 3)),
      'isRead': false,
      'priority': 'urgente',
      'orderId': 'ORD-2025-001',
      'vehiculo': 'Honda Civic 2020 - ABC-123',
      'tecnico': 'Juan Pérez',
      'actions': ['Ver orden'],
    },
    // Notificaciones de promociones coherentes con promociones_page.dart
    {
      'id': 'NOT-002',
      'type': 'promocion',
      'category': 'Promociones',
      'title': 'Nueva promoción: Cambio de Aceite + Filtros',
      'message':
          '¡2x1 en cambio de aceite! Incluye filtro de aceite y aire gratis. Válida hasta el 31 de diciembre.',
      'date': DateTime.now().subtract(const Duration(hours: 12)),
      'isRead': false,
      'priority': 'media',
      'promoId': 'PROMO-001',
      'descuento': '50% OFF',
      'validoHasta': '31 Dic 2024',
      'actions': ['Ver promoción', 'Agregar a wallet', 'Agendar cita'],
    },
    // Notificación de sistema
    {
      'id': 'NOT-003',
      'type': 'sistema',
      'category': 'Sistema',
      'title': 'Bienvenido a Taller Alex',
      'message':
          'Gracias por elegir Taller Alex. Explora nuestras promociones y agenda tu primera cita.',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'isRead': true,
      'priority': 'baja',
      'actions': ['Ver promociones', 'Agendar cita'],
    },
  ];

  List<Map<String, dynamic>> get notificaciones =>
      List.unmodifiable(_notificaciones);

  // Obtener notificaciones no leídas
  int get notificacionesNoLeidas =>
      _notificaciones.where((notif) => !notif['isRead']).length;

  // Obtener notificaciones por categoría
  List<Map<String, dynamic>> getNotificacionesPorCategoria(String categoria) {
    return _notificaciones
        .where((notif) => notif['category'] == categoria)
        .toList();
  }

  // Obtener notificaciones por tipo
  List<Map<String, dynamic>> getNotificacionesPorTipo(String tipo) {
    return _notificaciones.where((notif) => notif['type'] == tipo).toList();
  }

  // Marcar notificación como leída
  void marcarComoLeida(String notificacionId) {
    final index =
        _notificaciones.indexWhere((notif) => notif['id'] == notificacionId);
    if (index != -1) {
      _notificaciones[index]['isRead'] = true;
      notifyListeners();
    }
  }

  // Marcar todas como leídas
  void marcarTodasComoLeidas() {
    for (var notificacion in _notificaciones) {
      notificacion['isRead'] = true;
    }
    notifyListeners();
  }

  // Agregar notificación de cita creada
  void agregarNotificacionCitaCreada(Map<String, dynamic> cita) {
    final nuevaNotificacion = {
      'id': 'NOT-CITA-${DateTime.now().millisecondsSinceEpoch}',
      'type': 'confirmacion',
      'category': 'Citas',
      'title': 'Cita confirmada exitosamente',
      'message':
          'Tu cita para el ${cita['vehiculo']['marca']} ${cita['vehiculo']['modelo']} ha sido confirmada para el ${_formatearFecha(cita['fecha'])} a las ${cita['hora']} en ${cita['sucursal']['name']}.',
      'date': DateTime.now(),
      'isRead': false,
      'priority': 'alta',
      'citaId': cita['id'],
      'fechaCita': _formatearFecha(cita['fecha']),
      'horaCita': cita['hora'],
      'sucursal': cita['sucursal']['name'],
      'vehiculo':
          '${cita['vehiculo']['marca']} ${cita['vehiculo']['modelo']} ${cita['vehiculo']['anio']} - ${cita['vehiculo']['placa']}',
      'numeroOrden': cita['numeroOrden'],
      'actions': ['Ver cita', 'Reagendar', 'Cancelar'],
    };

    _notificaciones.insert(0, nuevaNotificacion);
    notifyListeners();

    // Programar recordatorio para el día anterior
    _programarRecordatorioCita(cita);
  }

  // Agregar notificación de orden creada
  void agregarNotificacionOrdenCreada(String numeroOrden, String vehiculo) {
    final nuevaNotificacion = {
      'id': 'NOT-ORDEN-${DateTime.now().millisecondsSinceEpoch}',
      'type': 'servicio',
      'category': 'Servicios',
      'title': 'Orden de servicio creada',
      'message':
          'Se ha creado la orden $numeroOrden para tu $vehiculo. En breve iniciará el proceso de diagnóstico.',
      'date': DateTime.now(),
      'isRead': false,
      'priority': 'media',
      'orderId': numeroOrden,
      'vehiculo': vehiculo,
      'actions': ['Ver orden', 'Ver progreso'],
    };

    _notificaciones.insert(0, nuevaNotificacion);
    notifyListeners();
  }

  // Agregar notificación de progreso de orden
  void agregarNotificacionProgreso(
      String numeroOrden, String vehiculo, String estado, String detalle) {
    final nuevaNotificacion = {
      'id': 'NOT-PROG-${DateTime.now().millisecondsSinceEpoch}',
      'type': 'servicio',
      'category': 'Servicios',
      'title': 'Actualización de servicio - $estado',
      'message': '$detalle para tu $vehiculo (Orden: $numeroOrden)',
      'date': DateTime.now(),
      'isRead': false,
      'priority': estado.contains('aprobación') ? 'urgente' : 'media',
      'orderId': numeroOrden,
      'vehiculo': vehiculo,
      'actions': ['Ver orden', 'Ver progreso'],
    };

    _notificaciones.insert(0, nuevaNotificacion);
    notifyListeners();
  }

  // Programar recordatorio de cita (simulado)
  void _programarRecordatorioCita(Map<String, dynamic> cita) {
    // En una app real, esto usaría notificaciones locales programadas
    // Por ahora, solo agregamos el recordatorio si la cita es para mañana o después
    final fechaCita = cita['fecha'] as DateTime;
    final fechaRecordatorio = fechaCita.subtract(const Duration(days: 1));

    if (fechaRecordatorio.isAfter(DateTime.now())) {
      // En una app real, esto usaría notificaciones locales programadas
      // Por demo, simulamos programando el recordatorio para aparecer el día anterior

      // TODO: Implementar notificaciones programadas con flutter_local_notifications
      // Por ahora solo registramos que debe programarse
      debugPrint(
          'Recordatorio programado para: ${_formatearFecha(fechaRecordatorio)}');
    }
  }

  // Eliminar notificación
  void eliminarNotificacion(String notificacionId) {
    _notificaciones.removeWhere((notif) => notif['id'] == notificacionId);
    notifyListeners();
  }

  // Limpiar notificaciones leídas
  void limpiarNotificacionesLeidas() {
    _notificaciones.removeWhere((notif) => notif['isRead']);
    notifyListeners();
  }

  // Obtener categorías disponibles
  List<String> get categorias {
    return _notificaciones
        .map((notif) => notif['category'] as String)
        .toSet()
        .toList()
      ..sort();
  }

  // Formatear fecha
  String _formatearFecha(DateTime fecha) {
    final meses = [
      '',
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return '${fecha.day} ${meses[fecha.month]} ${fecha.year}';
  }

  // Obtener tiempo transcurrido
  String getTiempoTranscurrido(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha);

    if (diferencia.inDays > 0) {
      return 'Hace ${diferencia.inDays} día${diferencia.inDays > 1 ? 's' : ''}';
    } else if (diferencia.inHours > 0) {
      return 'Hace ${diferencia.inHours} hora${diferencia.inHours > 1 ? 's' : ''}';
    } else if (diferencia.inMinutes > 0) {
      return 'Hace ${diferencia.inMinutes} minuto${diferencia.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Ahora mismo';
    }
  }
}
