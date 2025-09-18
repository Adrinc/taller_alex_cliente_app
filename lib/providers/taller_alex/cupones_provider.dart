import 'package:flutter/foundation.dart';

class CuponesProvider extends ChangeNotifier {
  // Cupones disponibles en el wallet del usuario
  final List<Map<String, dynamic>> _misCupones = [
    // Cupón demo que siempre aplica
    {
      'id': 'DEMO2024',
      'codigo': 'DEMO2024',
      'titulo': 'Descuento Demo',
      'descripcion': 'Descuento del 15% en cualquier servicio',
      'descuento': 15,
      'tipo': 'porcentaje', // porcentaje o fijo
      'fechaVencimiento': DateTime.now().add(const Duration(days: 30)),
      'usado': false,
      'aplicaATodos': true, // Este cupón aplica a cualquier servicio
      'fechaAgregado': DateTime.now().subtract(const Duration(days: 2)),
    }
  ];

  // Cupones disponibles en promociones (no agregados al wallet)
  final List<Map<String, dynamic>> _cuponesDisponibles = [
    {
      'id': 'ACEITE20',
      'codigo': 'ACEITE20',
      'titulo': '20% OFF Cambio de Aceite',
      'descripcion': 'Descuento especial en cambio de aceite y filtro',
      'descuento': 20,
      'tipo': 'porcentaje',
      'fechaVencimiento': DateTime.now().add(const Duration(days: 15)),
      'serviciosAplicables': ['Cambio de aceite', 'Cambio de filtro'],
      'terminosCondiciones':
          'Válido por 15 días. No acumulable con otras ofertas.',
    },
    {
      'id': 'FRENOS50',
      'codigo': 'FRENOS50',
      'titulo': '\$50 OFF Frenos',
      'descripcion': 'Descuento fijo en servicios de frenos',
      'descuento': 50,
      'tipo': 'fijo',
      'fechaVencimiento': DateTime.now().add(const Duration(days: 20)),
      'serviciosAplicables': ['Frenos', 'Balatas', 'Discos de freno'],
      'terminosCondiciones': 'Válido en servicios de frenos mayores a \$200.',
    },
    {
      'id': 'MANTENIMIENTO15',
      'codigo': 'MANT15',
      'titulo': '15% OFF Mantenimiento',
      'descripcion': 'Descuento en paquete de mantenimiento completo',
      'descuento': 15,
      'tipo': 'porcentaje',
      'fechaVencimiento': DateTime.now().add(const Duration(days: 25)),
      'serviciosAplicables': ['Mantenimiento preventivo', 'Revisión general'],
      'terminosCondiciones': 'Aplicable a mantenimiento preventivo completo.',
    },
  ];

  List<Map<String, dynamic>> get misCupones => List.unmodifiable(_misCupones);
  List<Map<String, dynamic>> get cuponesDisponibles =>
      List.unmodifiable(_cuponesDisponibles);

  // Obtener cupones disponibles para usar (no usados y no vencidos)
  List<Map<String, dynamic>> get cuponesParaUsar {
    return _misCupones.where((cupon) {
      final noUsado = !cupon['usado'];
      final noVencido = cupon['fechaVencimiento'].isAfter(DateTime.now());
      return noUsado && noVencido;
    }).toList();
  }

  // Obtener cupones que aplican para servicios específicos
  List<Map<String, dynamic>> getCuponesAplicables(
      List<String> serviciosSeleccionados) {
    return cuponesParaUsar.where((cupon) {
      // Si el cupón aplica a todos los servicios
      if (cupon['aplicaATodos'] == true) {
        return true;
      }

      // Si tiene servicios aplicables específicos
      if (cupon['serviciosAplicables'] != null) {
        final serviciosAplicables =
            cupon['serviciosAplicables'] as List<String>;
        return serviciosSeleccionados.any((servicio) => serviciosAplicables.any(
            (aplicable) =>
                servicio.toLowerCase().contains(aplicable.toLowerCase())));
      }

      return false;
    }).toList();
  }

  // Agregar cupón al wallet desde promociones
  void agregarCuponAlWallet(String cuponId) {
    final cuponDisponible = _cuponesDisponibles.firstWhere(
      (cupon) => cupon['id'] == cuponId,
      orElse: () => <String, dynamic>{},
    );

    if (cuponDisponible.isNotEmpty) {
      // Verificar que no esté ya agregado
      final yaExiste = _misCupones.any((cupon) => cupon['id'] == cuponId);

      if (!yaExiste) {
        final nuevoCupon = {
          ...cuponDisponible,
          'usado': false,
          'fechaAgregado': DateTime.now(),
        };

        _misCupones.add(nuevoCupon);
        notifyListeners();
      }
    }
  }

  // Marcar cupón como usado
  void usarCupon(String cuponId) {
    final index = _misCupones.indexWhere((cupon) => cupon['id'] == cuponId);
    if (index != -1) {
      _misCupones[index]['usado'] = true;
      _misCupones[index]['fechaUso'] = DateTime.now();
      notifyListeners();
    }
  }

  // Verificar si un cupón ya está en el wallet
  bool cuponEnWallet(String cuponId) {
    return _misCupones.any((cupon) => cupon['id'] == cuponId);
  }

  // Calcular descuento para un cupón específico
  double calcularDescuento(String cuponId, double subtotal) {
    final cupon = _misCupones.firstWhere(
      (c) => c['id'] == cuponId,
      orElse: () => <String, dynamic>{},
    );

    if (cupon.isEmpty || cupon['usado'] == true) return 0.0;

    if (cupon['tipo'] == 'porcentaje') {
      return subtotal * (cupon['descuento'] / 100);
    } else if (cupon['tipo'] == 'fijo') {
      return cupon['descuento'].toDouble();
    }

    return 0.0;
  }

  // Obtener cupón por código
  Map<String, dynamic>? getCuponPorCodigo(String codigo) {
    try {
      return cuponesParaUsar.firstWhere(
        (cupon) => cupon['codigo'].toLowerCase() == codigo.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}
