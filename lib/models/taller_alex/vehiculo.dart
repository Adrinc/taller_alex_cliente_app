import 'package:nethive_neo/models/taller_alex/cliente.dart';

// Modelo Vehiculo - basado en tabla 'vehiculos'
class Vehiculo {
  final String id;
  final String clienteId;
  final String marca;
  final String modelo;
  final int anio;
  final String placa;
  final String? vin;
  final String? color;
  final CombustibleTipo combustible;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehiculo({
    required this.id,
    required this.clienteId,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.placa,
    this.vin,
    this.color,
    required this.combustible,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vehiculo.fromJson(Map<String, dynamic> json) {
    return Vehiculo(
      id: json['id'],
      clienteId: json['cliente_id'],
      marca: json['marca'],
      modelo: json['modelo'],
      anio: json['anio'],
      placa: json['placa'],
      vin: json['vin'],
      color: json['color'],
      combustible: CombustibleTipoExtension.fromString(
          json['combustible'] ?? 'gasolina'),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cliente_id': clienteId,
      'marca': marca,
      'modelo': modelo,
      'anio': anio,
      'placa': placa,
      'vin': vin,
      'color': color,
      'combustible': combustible.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Vehiculo copyWith({
    String? id,
    String? clienteId,
    String? marca,
    String? modelo,
    int? anio,
    String? placa,
    String? vin,
    String? color,
    CombustibleTipo? combustible,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vehiculo(
      id: id ?? this.id,
      clienteId: clienteId ?? this.clienteId,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      anio: anio ?? this.anio,
      placa: placa ?? this.placa,
      vin: vin ?? this.vin,
      color: color ?? this.color,
      combustible: combustible ?? this.combustible,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Getter para mostrar información completa del vehículo
  String get displayName => '$marca $modelo $anio';
  String get fullInfo => '$marca $modelo $anio - $placa';
}
