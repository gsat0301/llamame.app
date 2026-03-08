import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'directory_models.dart';
import 'directory_repository.dart';

final categoriesProvider = FutureProvider<List<ServiceCategory>>((ref) async {
  final repo = ref.watch(directoryRepositoryProvider);
  if (repo == null) throw StateError('Supabase not configured');
  return repo.fetchCategories();
});

final providersForCategoryProvider = FutureProvider.family<List<ProviderSummary>, int>((ref, categoryId) async {
  final repo = ref.watch(directoryRepositoryProvider);
  if (repo == null) throw StateError('Supabase not configured');
  return repo.fetchProvidersForCategory(categoryId);
});

final providerByIdProvider = FutureProvider.family<ProviderSummary, String>((ref, providerId) async {
  final repo = ref.watch(directoryRepositoryProvider);
  if (repo == null) throw StateError('Supabase not configured');
  return repo.fetchProviderById(providerId);
});

