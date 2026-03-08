import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase_client.dart';

final authSessionProvider = StreamProvider<Session?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    return const Stream<Session?>.empty();
  }

  final controller = StreamController<Session?>();
  controller.add(client.auth.currentSession);

  final sub = client.auth.onAuthStateChange.listen((event) {
    controller.add(event.session);
  });

  ref.onDispose(() async {
    await sub.cancel();
    await controller.close();
  });

  return controller.stream;
});

final currentUserProvider = Provider<User?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client?.auth.currentUser;
});

