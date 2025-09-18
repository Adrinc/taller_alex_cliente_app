import 'package:flutter/foundation.dart';
import 'dart:typed_data';

class VehiculosProvider extends ChangeNotifier {
  // Datos iniciales de demo - persisten durante la sesión
  List<Map<String, dynamic>> _vehiculos = [
    {
      'id': 1,
      'brand': 'Honda',
      'model': 'Civic',
      'year': 2020,
      'plate': 'ABC-123',
      'color': 'Blanco',
      'vin': '1HGBH41JXMN109186',
      'fuelType': 'Gasolina',
      'imageBytes': null,
      'imagePath': null,
      'services': 8,
      'lastService': '15 Sep 2024',
    },
    {
      'id': 2,
      'brand': 'Toyota',
      'model': 'Corolla',
      'year': 2019,
      'plate': 'XYZ-789',
      'color': 'Azul',
      'vin': '5Y2SL62823Z411565',
      'fuelType': 'Gasolina',
      'imageBytes': null,
      'imagePath': null,
      'services': 12,
      'lastService': '28 Ago 2024',
    },
  ];

  int _nextId = 3; // Comenzamos desde 3 ya que tenemos 2 vehículos por defecto

  List<Map<String, dynamic>> get vehiculos => List.unmodifiable(_vehiculos);

  void agregarVehiculo({
    required String brand,
    required String model,
    required int year,
    required String plate,
    required String color,
    required String vin,
    required String fuelType,
    Uint8List? imageBytes,
    String? imagePath,
  }) {
    final nuevoVehiculo = {
      'id': _nextId++,
      'brand': brand,
      'model': model,
      'year': year,
      'plate': plate,
      'color': color,
      'vin': vin,
      'fuelType': fuelType,
      'imageBytes': imageBytes,
      'imagePath': imagePath,
      'services': 0, // Nuevo vehículo sin servicios
      'lastService': 'Sin servicios',
    };

    _vehiculos.add(nuevoVehiculo);
    notifyListeners();
  }

  void actualizarVehiculo(int id, Map<String, dynamic> datosActualizados) {
    final index = _vehiculos.indexWhere((vehiculo) => vehiculo['id'] == id);
    if (index != -1) {
      // Actualizamos solo los campos proporcionados
      _vehiculos[index] = {..._vehiculos[index], ...datosActualizados};
      notifyListeners();
    }
  }

  void eliminarVehiculo(int id) {
    _vehiculos.removeWhere((vehiculo) => vehiculo['id'] == id);
    notifyListeners();
  }

  Map<String, dynamic>? getVehiculoPorId(int id) {
    try {
      return _vehiculos.firstWhere((vehiculo) => vehiculo['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Método para obtener vehículos formateados para el selector de citas
  List<Map<String, dynamic>> getVehiculosParaCitas() {
    return _vehiculos
        .map((vehiculo) => {
              'id': vehiculo['id'],
              'nombre':
                  '${vehiculo['brand']} ${vehiculo['model']} ${vehiculo['year']}',
              'placa': vehiculo['plate'],
              'datos': vehiculo, // Incluimos todos los datos del vehículo
            })
        .toList();
  }

  int get totalVehiculos => _vehiculos.length;

  bool tieneVehiculos() => _vehiculos.isNotEmpty;
}
