import 'package:flutter/material.dart';
import 'package:nethive_neo/providers/theme_config_provider.dart';
import 'package:provider/provider.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nethive_neo/helpers/constants.dart';
import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/providers/taller_alex/citas_provider.dart';
import 'package:nethive_neo/providers/taller_alex/usuario_provider.dart';
import 'package:nethive_neo/providers/taller_alex/vehiculos_provider.dart';
import 'package:nethive_neo/providers/taller_alex/cupones_provider.dart';
import 'package:nethive_neo/providers/taller_alex/ordenes_provider.dart';
import 'package:nethive_neo/router/app_router.dart';
import 'package:nethive_neo/theme/theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización directa sin supabase_flutter
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: anonKey,
    realtimeClientOptions: const RealtimeClientOptions(
      eventsPerSecond: 2,
    ),
  );
  supabaseLU = SupabaseClient(supabaseUrl, anonKey, schema: 'taller_alex');
  await initGlobals();

  runApp(const TallerAlexApp());
}

class TallerAlexApp extends StatelessWidget {
  const TallerAlexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserState()),
        ChangeNotifierProvider(create: (_) => ThemeConfigProvider()),
        ChangeNotifierProvider(create: (_) => CitasProvider()),
        ChangeNotifierProvider(create: (_) => UsuarioProvider()),
        ChangeNotifierProvider(create: (_) => VehiculosProvider()),
        ChangeNotifierProvider(create: (_) => CuponesProvider()),
        ChangeNotifierProvider(create: (_) => OrdenesProvider()),
      ],
      child: MaterialApp.router(
        title: 'Taller Alex Cliente',
        routerConfig: AppRouter.router,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: TallerAlexColors.primaryFuchsia,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Poppins',
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'),
        ],
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
