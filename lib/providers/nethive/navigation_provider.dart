import 'package:flutter/material.dart';
import 'package:nethive_neo/models/nethive/negocio_model.dart';
import 'package:nethive_neo/models/nethive/empresa_model.dart';
import 'package:nethive_neo/helpers/globals.dart';

class NavigationProvider extends ChangeNotifier {
  // Estados principales
  String? _negocioSeleccionadoId;
  Negocio? _negocioSeleccionado;
  Empresa? _empresaSeleccionada;
  int _selectedMenuIndex = 0;

  // Getters
  String? get negocioSeleccionadoId => _negocioSeleccionadoId;
  Negocio? get negocioSeleccionado => _negocioSeleccionado;
  Empresa? get empresaSeleccionada => _empresaSeleccionada;
  int get selectedMenuIndex => _selectedMenuIndex;

  // Lista de opciones del sidemenu
  final List<NavigationMenuItem> menuItems = [
    NavigationMenuItem(
      title: 'Dashboard',
      icon: Icons.dashboard,
      route: '/dashboard',
      index: 0,
    ),
    NavigationMenuItem(
      title: 'Inventario',
      icon: Icons.inventory_2,
      route: '/inventario',
      index: 1,
    ),
    NavigationMenuItem(
      title: 'Topología',
      icon: Icons.account_tree,
      route: '/topologia',
      index: 2,
    ),
    NavigationMenuItem(
      title: 'Alertas',
      icon: Icons.warning,
      route: '/alertas',
      index: 3,
    ),
    NavigationMenuItem(
      title: 'Configuración',
      icon: Icons.settings,
      route: '/configuracion',
      index: 4,
    ),
    NavigationMenuItem(
      title: 'Empresas',
      icon: Icons.business,
      route: '/empresas',
      index: 5,
      isSpecial: true, // Para diferenciarlo como opción de regreso
    ),
  ];

  // Métodos para establecer el negocio seleccionado
  Future<void> setNegocioSeleccionado(String negocioId) async {
    try {
      _negocioSeleccionadoId = negocioId;

      // Obtener datos completos del negocio
      final negocioResponse = await supabaseLU.from('negocio').select('''
            *,
            empresa!inner(*)
          ''').eq('id', negocioId).single();

      _negocioSeleccionado = Negocio.fromMap(negocioResponse);
      _empresaSeleccionada = Empresa.fromMap(negocioResponse['empresa']);

      // Reset menu selection when changing business
      _selectedMenuIndex = 0;

      notifyListeners();
    } catch (e) {
      print('Error al establecer negocio seleccionado: $e');
    }
  }

  // Método para cambiar la selección del menú
  void setSelectedMenuIndex(int index) {
    _selectedMenuIndex = index;
    notifyListeners();
  }

  // Método para limpiar la selección (al regresar a empresas)
  void clearSelection() {
    _negocioSeleccionadoId = null;
    _negocioSeleccionado = null;
    _empresaSeleccionada = null;
    _selectedMenuIndex = 0;
    notifyListeners();
  }

  // Método para obtener el item del menú por índice
  NavigationMenuItem getMenuItemByIndex(int index) {
    return menuItems.firstWhere((item) => item.index == index);
  }

  // Método para obtener el item del menú por ruta
  NavigationMenuItem? getMenuItemByRoute(String route) {
    try {
      return menuItems.firstWhere((item) => item.route == route);
    } catch (e) {
      return null;
    }
  }
}

// Modelo para los items del menú
class NavigationMenuItem {
  final String title;
  final IconData icon;
  final String route;
  final int index;
  final bool isSpecial;

  NavigationMenuItem({
    required this.title,
    required this.icon,
    required this.route,
    required this.index,
    this.isSpecial = false,
  });
}
