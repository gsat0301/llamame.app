import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> bootstrapSupabase() async {
  String? url = const String.fromEnvironment('SUPABASE_URL').isEmpty
      ? null
      : const String.fromEnvironment('SUPABASE_URL');

  String? anonKey = const String.fromEnvironment('SUPABASE_ANON_KEY').isEmpty
      ? null
      : const String.fromEnvironment('SUPABASE_ANON_KEY');

  if (url == null || anonKey == null) {
    url = dotenv.env['SUPABASE_URL']?.trim();
    anonKey = dotenv.env['SUPABASE_ANON_KEY']?.trim();
  }

  if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
    // ignore: avoid_print
    print('⚠️ Configuración de Supabase no encontrada.');
    return;
  }

  await Supabase.initialize(url: url, anonKey: anonKey);
}
