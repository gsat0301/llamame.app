import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ads/ad_models.dart';
import 'admin_models.dart';
import 'admin_repository.dart';

final providerRequestsProvider =
    FutureProvider<List<AdminProviderRequest>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  if (repo == null) throw StateError('Supabase not configured');
  return repo.fetchProviderRequests();
});

final allRatingsProvider = FutureProvider<List<AdminRating>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  if (repo == null) throw StateError('Supabase not configured');
  return repo.fetchAllRatings();
});

final allAdsProvider = FutureProvider<List<Ad>>((ref) async {
  final repo = ref.watch(adminRepositoryProvider);
  if (repo == null) throw StateError('Supabase not configured');
  return repo.fetchAllAds();
});
