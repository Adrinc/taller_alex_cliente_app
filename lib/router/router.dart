import 'package:nethive_neo/functions/no_transition_route.dart';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:nethive_neo/pages/empresa_negocios/empresa_negocios_page.dart';

import 'package:nethive_neo/pages/pages.dart';

import 'package:nethive_neo/services/navigation_service.dart';

/// The route configuration.
final GoRouter router = GoRouter(
  debugLogDiagnostics: true,
  navigatorKey: NavigationService.navigatorKey,
  initialLocation: '/',
  redirect: (BuildContext context, GoRouterState state) {
    final bool loggedIn = currentUser != null;
    final bool isLoggingIn = state.matchedLocation.contains('/login');

    // If user is not logged in and not in the login page
    if (!loggedIn && !isLoggingIn) return '/login';

    //if user is logged in and in the login page
    if (loggedIn && isLoggingIn) {
      if (currentUser!.role.roleId == 14 || currentUser!.role.roleId == 13) {
        return '/book_page_main';
      } else {
        return '/';
      }
    }

    return null;
  },
  errorBuilder: (context, state) => const PageNotFoundPage(),
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'root',
      builder: (BuildContext context, GoRouterState state) {
        if (currentUser!.role.roleId == 14 || currentUser!.role.roleId == 13) {
          return Container(
              color: Colors.amber,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: const Center(child: Text('Book Page Main')));
        } else {
          return const EmpresaNegociosPage();
        }
      },
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginPage();
      },
    ),
  ],
);
