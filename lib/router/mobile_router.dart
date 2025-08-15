import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nethive_neo/pages/login_page/login_page.dart';
import 'package:nethive_neo/pages/empresa_selector_page.dart';
import 'package:nethive_neo/pages/negocio_selector_page.dart';
import 'package:nethive_neo/pages/home_tecnico_page.dart';
import 'package:nethive_neo/pages/scanner_page_new.dart' as new_scanner;

class MobileRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      // Autenticación
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // Selección de empresa
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
        routes: [
          // Scanner RFID
          GoRoute(
            path: '/scanner',
            name: 'scanner',
            builder: (context, state) => const new_scanner.ScannerPage(),
          ),

          // Inventario (placeholder)
          GoRoute(
            path: '/inventario',
            name: 'inventario',
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: const Text('Inventario')),
              body: const Center(
                child: Text('Página de Inventario - Próximamente'),
              ),
            ),
          ),

          // Conexiones (placeholder)
          GoRoute(
            path: '/conexiones',
            name: 'conexiones',
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: const Text('Conexiones')),
              body: const Center(
                child: Text('Página de Conexiones - Próximamente'),
              ),
            ),
          ),

          // Formulario de componente (placeholder)
          GoRoute(
            path: '/componente-form',
            name: 'componente-form',
            builder: (context, state) {
              final rfidCode = state.uri.queryParameters['rfidCode'];
              final componenteId = state.uri.queryParameters['componenteId'];

              return Scaffold(
                appBar: AppBar(
                  title: Text(componenteId != null
                      ? 'Editar Componente'
                      : 'Crear Componente'),
                ),
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Formulario de Componente - Próximamente'),
                      if (rfidCode != null) Text('Código RFID: $rfidCode'),
                      if (componenteId != null)
                        Text('ID Componente: $componenteId'),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Página no encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error.toString(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Ir al inicio'),
            ),
          ],
        ),
      ),
    ),
  );
}
