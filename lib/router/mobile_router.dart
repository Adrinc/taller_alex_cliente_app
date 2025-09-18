import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nethive_neo/pages/welcome_page.dart';
import 'package:nethive_neo/pages/login_page/login_page.dart';
import 'package:nethive_neo/pages/taller_alex/dashboard_page.dart';
import 'package:nethive_neo/pages/register_page.dart';
import 'package:nethive_neo/pages/agendar_cita_page.dart';
import 'package:nethive_neo/pages/mis_citas_page.dart';
import 'package:nethive_neo/pages/mis_vehiculos_page.dart';
import 'package:nethive_neo/pages/mis_ordenes_page.dart';
import 'package:nethive_neo/pages/historial_page.dart';
import 'package:nethive_neo/pages/promociones_page.dart';
import 'package:nethive_neo/pages/notificaciones_page.dart';
import 'package:nethive_neo/pages/perfil_page.dart';

import 'package:nethive_neo/helpers/globals.dart';

class MobileRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = supabaseLU.auth.currentUser != null;
      final currentPath = state.matchedLocation;

      // Permitir acceso a welcome y login sin restricciones
      if (currentPath == '/' ||
          currentPath == '/login' ||
          currentPath == '/register') {
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

      // Registro de cliente
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

      // Dashboard principal del cliente
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),

      // Mis Vehículos
      GoRoute(
        path: '/vehiculos',
        name: 'vehiculos',
        builder: (context, state) => const MisVehiculosPage(),
      ),

      // Agendar Cita
      GoRoute(
        path: '/agendar-cita',
        name: 'agendar-cita',
        builder: (context, state) => const AgendarCitaPage(),
      ),

      // Mis Citas
      GoRoute(
        path: '/mis-citas',
        name: 'mis-citas',
        builder: (context, state) => const MisCitasPage(),
      ),

      // Mis Órdenes
      GoRoute(
        path: '/ordenes',
        name: 'ordenes',
        builder: (context, state) => const MisOrdenesPage(),
      ),

      // Historial
      GoRoute(
        path: '/historial',
        name: 'historial',
        builder: (context, state) => const HistorialPage(),
      ),

      // Promociones
      GoRoute(
        path: '/promociones',
        name: 'promociones',
        builder: (context, state) => const PromocionesPage(),
      ),

      // Notificaciones
      GoRoute(
        path: '/notificaciones',
        name: 'notificaciones',
        builder: (context, state) => const NotificacionesPage(),
      ),

      // Perfil
      GoRoute(
        path: '/perfil',
        name: 'perfil',
        builder: (context, state) => const PerfilPage(),
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
