import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:nethive_neo/helpers/supabase/queries.dart';
import 'package:nethive_neo/models/models.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

final GlobalKey<ScaffoldMessengerState> snackbarKey =
    GlobalKey<ScaffoldMessengerState>();
final supabase = Supabase.instance.client;
const storage = FlutterSecureStorage();

// Usar el cliente directo de Supabase
late SupabaseClient supabaseLU;

late final SharedPreferences prefs;

User? currentUser;

Future<void> initGlobals() async {
  prefs = await SharedPreferences.getInstance();
  currentUser = await SupabaseQueries.getCurrentUserData();

  if (currentUser == null) return;
}
