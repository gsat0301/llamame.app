import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'provider_models.dart';
import 'provider_repository.dart';

final myProviderDetailsProvider = FutureProvider<ProviderDetails?>((ref) async {
  final repo = ref.watch(providerRepositoryProvider);
  if (repo == null) throw StateError('Supabase not configured');
  return repo.fetchMyProviderDetails();
});

final myServiceCategoryIdsProvider = FutureProvider<Set<int>>((ref) async {
  final repo = ref.watch(providerRepositoryProvider);
  if (repo == null) throw StateError('Supabase not configured');
  return repo.fetchMyServiceCategoryIds();
});

final galleryProvider = FutureProvider.family<List<ProviderGalleryImage>, String>((ref, providerId) async {
  final repo = ref.watch(providerRepositoryProvider);
  if (repo == null) throw StateError('Supabase not configured');
  return repo.fetchGallery(providerId);
});

final ratingsProvider = FutureProvider.family<List<ProviderRating>, String>((ref, providerId) async {
  final repo = ref.watch(providerRepositoryProvider);
  if (repo == null) throw StateError('Supabase not configured');
  return repo.fetchRatings(providerId);
});
