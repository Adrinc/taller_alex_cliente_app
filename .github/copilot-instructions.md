# Copilot Instructions for nethive_neo Flutter Project

## Arquitectura General
- Proyecto Flutter con estructura estándar: `lib/` contiene la lógica principal, dividida en subcarpetas como `functions/`, `helpers/`, `models/`, `pages/`, `providers/`, `router/`, `services/`, `theme/`, `widgets/`.
- El archivo de entrada es `lib/main.dart`.
- Los assets (imágenes, fuentes) están en `assets/` y se referencian en `pubspec.yaml`.
- El proyecto soporta Android, iOS, Web, Windows, Linux y macOS (ver carpetas raíz).

## Flujos de Desarrollo
- **Compilación y ejecución:**
  - Usar comandos estándar de Flutter:
    - `flutter pub get` para instalar dependencias.
    - `flutter run` para ejecutar la app.
    - `flutter build <platform>` para generar builds (ej: `flutter build apk`).
- **Pruebas:**
  - Los tests están en `test/`.
  - Ejecutar con `flutter test`.
- **Gestión de dependencias:**
  - Todas las dependencias se gestionan en `pubspec.yaml`.
  - Actualizar con `flutter pub upgrade`.

## Patrones de Provider y Estado
- **Registro de Providers:**
  - Todos los providers se registran en `main.dart` dentro de `MultiProvider`.
  - Los providers se importan desde `lib/providers/providers.dart` que actúa como archivo de barril.
  - SIEMPRE agregar nuevos providers tanto en `providers.dart` como en el `MultiProvider` de `main.dart`.

```dart
// En main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => UserState()),
    ChangeNotifierProvider(create: (_) => EmpresasNegociosProvider()),
    // ... otros providers
  ],
```

- **Uso de Supabase:**
  - **CRÍTICO:** Usar `supabaseLU` de `lib/helpers/globals.dart` para operaciones de base de datos.
  - `supabaseLU` es el cliente configurado con el schema 'nethive', NO usar `supabase` estándar.
  - Patrón típico en providers: `import 'package:nethive_neo/helpers/globals.dart';`

```dart
// CORRECTO - Usar supabaseLU para queries
final response = await supabaseLU.from('tabla').select('*');

// INCORRECTO - NO usar el cliente estándar
final response = await supabase.from('tabla').select('*');
```

## Convenciones y Patrones
- **Nomenclatura:**
  - Clases y widgets usan PascalCase.
  - Archivos y carpetas en minúsculas y snake_case.
- **Organización de código:**
  - `models/`: Definición de modelos de datos, exportados desde `models/models.dart`.
  - `providers/`: Lógica de estado, organizados en subcarpetas (`nethive/` para lógica específica).
  - `services/`: Integraciones externas y lógica de negocio.
  - `widgets/`: Componentes reutilizables.
  - `pages/`: Pantallas principales de la app.
  - `router/`: Configuración de rutas con GoRouter, incluye redirect logic para autenticación.

## Navegación y Router
- **GoRouter Configuration:**
  - Router centralizado en `lib/router/app_router.dart`.
  - Implementa redirect logic para proteger rutas basado en autenticación.
  - Usa `supabase.auth.currentUser` para verificar estado de sesión.

```dart
// Patrón de redirección en router
redirect: (context, state) {
  final isLoggedIn = supabase.auth.currentUser != null;
  if (!isLoggedIn && currentPath != '/login') {
    return '/login';
  }
  return null;
},
```

## Integraciones y Variables Globales
- **Globals Helper (`lib/helpers/globals.dart`):**
  - Contiene variables globales críticas: `supabaseLU`, `currentUser`, `prefs`, `storage`.
  - `supabaseLU` se inicializa en `main.dart` con schema 'nethive'.
  - `initGlobals()` se llama en `main.dart` para configurar SharedPreferences y usuario actual.

```dart
// Patrón típico de uso en providers
import 'package:nethive_neo/helpers/globals.dart';

// Usar supabaseLU para todas las operaciones de DB
final response = await supabaseLU.from('empresa').select('*');
```

## Archivos Clave
- `lib/main.dart`: Punto de entrada, inicialización de Supabase y registro de providers.
- `lib/helpers/globals.dart`: Variables globales críticas, especialmente `supabaseLU`.
- `lib/providers/providers.dart`: Archivo de barril para importar todos los providers.
- `lib/models/models.dart`: Archivo de barril para importar todos los modelos.
- `lib/router/app_router.dart`: Configuración de navegación con GoRouter.
- `pubspec.yaml`: Dependencias y configuración de assets.

---

**IMPORTANTE:** Siempre usa `supabaseLU` de `globals.dart` para operaciones de base de datos, nunca el cliente `supabase` estándar. Registra nuevos providers en tanto `providers.dart` como en `main.dart`.