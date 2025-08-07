import 'package:flutter/material.dart';

class InventarioUtils {
  static IconData getCategoryIcon(String categoryName) {
    // Normalizar el nombre de la categoría para mejor matching
    final normalizedName = categoryName.toLowerCase().trim();

    // Mapa de categorías a íconos basado en las categorías
    if (normalizedName.contains('cable')) {
      return Icons.cable;
    } else if (normalizedName.contains('switch')) {
      return Icons.hub;
    } else if (normalizedName.contains('patch') ||
        normalizedName.contains('panel')) {
      return Icons.view_module;
    } else if (normalizedName.contains('rack')) {
      return Icons.storage;
    } else if (normalizedName.contains('ups') ||
        normalizedName.contains('power')) {
      return Icons.battery_charging_full;
    } else if (normalizedName.contains('router') ||
        normalizedName.contains('firewall')) {
      return Icons.router;
    } else if (normalizedName.contains('server') ||
        normalizedName.contains('servidor')) {
      return Icons.dns;
    } else if (normalizedName.contains('access') ||
        normalizedName.contains('wifi')) {
      return Icons.wifi;
    } else if (normalizedName.contains('pc') ||
        normalizedName.contains('computer')) {
      return Icons.computer;
    } else if (normalizedName.contains('phone') ||
        normalizedName.contains('teléfono')) {
      return Icons.phone;
    } else if (normalizedName.contains('printer') ||
        normalizedName.contains('impresora')) {
      return Icons.print;
    } else if (normalizedName.contains('security') ||
        normalizedName.contains('seguridad')) {
      return Icons.security;
    } else if (normalizedName.contains('monitor') ||
        normalizedName.contains('pantalla')) {
      return Icons.monitor;
    } else if (normalizedName.contains('keyboard') ||
        normalizedName.contains('teclado')) {
      return Icons.keyboard;
    } else if (normalizedName.contains('mouse') ||
        normalizedName.contains('ratón')) {
      return Icons.mouse;
    } else {
      // Icono por defecto para categorías no reconocidas
      return Icons.devices_other;
    }
  }
}
