import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'profile_models.dart';
import 'profile_repository.dart';

final myProfileProvider = FutureProvider<Profile>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  if (repo == null) throw StateError('Supabase not configured');
  return repo.fetchMyProfile();
});

final latestProviderRequestProvider = FutureProvider<ProviderRoleRequest?>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  if (repo == null) throw StateError('Supabase not configured');
  return repo.fetchLatestMyProviderRequest();
});

enum AppMode { customer, provider }

final appModeProvider = StateProvider<AppMode>((ref) => AppMode.customer);

