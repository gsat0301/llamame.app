import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  // If Supabase.initialize wasn't called (missing env), this throws.
  // We return null to allow the app to render a friendly error.
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
});

