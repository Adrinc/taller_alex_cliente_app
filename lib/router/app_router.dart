import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nethive_neo/pages/welcome_page.dart';
import 'package:nethive_neo/pages/login_page/login_page.dart';
import 'package:nethive_neo/pages/empresa_selector_page.dart';
import 'package:nethive_neo/pages/negocio_selector_page.dart';
import 'package:nethive_neo/pages/home_tecnico_page.dart';
import 'package:nethive_neo/pages/scanner_page_new.dart' as new_scanner;
import 'package:nethive_neo/pages/inventario_page.dart';
import 'package:nethive_neo/pages/crear_componente_page.dart';
import 'package:nethive_neo/pages/componente_selector_page.dart';
import 'package:nethive_neo/helpers/globals.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = supabase.auth.currentUser != null;
      final currentPath = state.matchedLocation;

      // Permitir acceso a welcome y login sin restricciones
      if (currentPath == '/' || currentPath == '/login') {
        return null;
      }

      // Si no está logueado y trata de acceder a páginas protegidas, va a login
      if (!isLoggedIn) {
        return '/login';
      }

      return null;
    },
    routes: [
      // Página de bienvenida inicial
      GoRoute(
        path: '/',
        name: 'welcome',
        builder: (context, state) => const WelcomePage(),
      ),

      // Autenticación
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // Selección de empresa (primera pantalla después del login)
      GoRoute(
        path: '/empresa-selector',
        name: 'empresa-selector',
        builder: (context, state) => const EmpresaSelectorPage(),
      ),

      // Selección de negocio/sucursal
      GoRoute(
        path: '/negocio-selector',
        name: 'negocio-selector',
        builder: (context, state) {
          final empresaId = state.uri.queryParameters['empresaId']!;
          return NegocioSelectorPage(empresaId: empresaId);
        },
      ),

      // Home principal del técnico
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) {
          final negocioId = state.uri.queryParameters['negocioId'];
          return HomeTecnicoPage(negocioId: negocioId);
        },
      ),

      // Scanner RFID
      GoRoute(
        path: '/scanner',
        name: 'scanner',
        builder: (context, state) => const new_scanner.ScannerPage(),
      ),

      // Inventario
      GoRoute(
        path: '/inventario',
        name: 'inventario',
        builder: (context, state) => const InventarioPage(),
      ),

      // Conexiones
      GoRoute(
        path: '/conexiones',
        name: 'conexiones',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Página de Conexiones\n(En desarrollo)'),
          ),
        ),
      ),

      // Componente Form (para agregar/editar componentes)
      GoRoute(
        path: '/componente/crear',
        name: 'componente-crear',
        builder: (context, state) {
          final rfidCode = state.uri.queryParameters['rfid'];
          return CrearComponentePage(rfidCode: rfidCode);
        },
      ),

      GoRoute(
        path: '/componente/selector',
        name: 'componente-selector',
        builder: (context, state) {
          final rfidCode = state.uri.queryParameters['rfid'];
          final negocioId = state.uri.queryParameters['negocioId'];
          return ComponenteSelectorPage(
            rfidCode: rfidCode,
            negocioId: negocioId,
          );
        },
      ),

      GoRoute(
        path: '/componente-form',
        name: 'componente-form',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Formulario de Componente\n(En desarrollo)'),
          ),
        ),
      ),
    ],
  );
}
