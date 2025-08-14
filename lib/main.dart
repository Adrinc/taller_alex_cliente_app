import 'package:flutter/material.dart';
import 'package:nethive_neo/providers/theme_config_provider.dart';
import 'package:provider/provider.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:nethive_neo/helpers/constants.dart';
import 'package:nethive_neo/helpers/globals.dart';
import 'package:nethive_neo/providers/providers.dart';
import 'package:nethive_neo/pages/login_page/login_page.dart';
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

  runApp(const NethiveMobileApp());
}

class NethiveMobileApp extends StatelessWidget {
  const NethiveMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserState()),
        ChangeNotifierProvider(create: (_) => EmpresasNegociosProvider()),
        ChangeNotifierProvider(create: (_) => ComponentesProvider()),
        ChangeNotifierProvider(create: (_) => ThemeConfigProvider()),
      ],
      child: MaterialApp(
        title: 'NETHIVE Mobile',
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
        home: const LoginPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
