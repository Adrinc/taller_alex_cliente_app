import 'package:flutter/material.dart';
import 'package:nethive_neo/providers/theme_config_provider.dart';
import 'package:provider/provider.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nethive_neo/helpers/constants.dart';
import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/router/app_router.dart';
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
  supabaseLU = SupabaseClient(supabaseUrl, anonKey, schema: 'nethive');
  await initGlobals();

  runApp(const NetHiveApp());
}

class NetHiveApp extends StatelessWidget {
  const NetHiveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserState()),
        ChangeNotifierProvider(create: (_) => EmpresasNegociosProvider()),
        ChangeNotifierProvider(create: (_) => ComponentesProvider()),
        ChangeNotifierProvider(create: (_) => RfidScannerProvider()),
        ChangeNotifierProvider(create: (_) => ConnectionsProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
        ChangeNotifierProvider(create: (_) => ThemeConfigProvider()),
        ChangeNotifierProvider(create: (_) => ComponenteCreationProvider()),
        ChangeNotifierProvider(create: (_) => DistribucionesProvider()),
      ],
      child: MaterialApp.router(
        title: 'NetHive Mobile',
        routerConfig: AppRouter.router,
        theme: ThemeData(
          primarySwatch: Colors.green,
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
