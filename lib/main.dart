import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';
import 'src/core/supabase_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // For release builds you can switch to build-time configs/flavors.
  await dotenv.load(fileName: '.env', isOptional: true);
  await bootstrapSupabase();

  runApp(const ProviderScope(child: App()));
}

