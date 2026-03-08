import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase_client.dart';
import 'directory_models.dart';

class DirectoryRepository {
  DirectoryRepository(this._client);

  final SupabaseClient _client;

  Future<List<ServiceCategory>> fetchCategories() async {
    final res = await _client
        .from('service_categories')
        .select('id,name,icon_key')
        .order('name');
    return (res as List)
        .map((e) => ServiceCategory.fromMap(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<List<ProviderSummary>> fetchProvidersForCategory(
      int categoryId) async {
    final res = await _client
        .from('profiles')
        .select(
          'id,full_name,phone,avatar_url,is_provider,'
          'provider_details(headline,average_rating,jobs_completed),'
          'locations(city,region,country),'
          'provider_services!inner(category_id)',
        )
        .eq('is_provider', true)
        .eq('provider_services.category_id', categoryId)
        .limit(200);

    return (res as List).map((row) {
      final map = row as Map<String, dynamic>;

      final detailsRaw = map['provider_details'];
      final details = detailsRaw is List
          ? detailsRaw.cast<Map<String, dynamic>>().firstOrNull
          : detailsRaw as Map<String, dynamic>?;

      final locationRaw = map['locations'];
      final location = locationRaw is List
          ? locationRaw.cast<Map<String, dynamic>>().firstOrNull
          : locationRaw as Map<String, dynamic>?;

      return ProviderSummary(
        id: map['id'] as String,
        fullName: (map['full_name'] as String?) ?? 'Unnamed',
        phone: map['phone'] as String?,
        avatarUrl: map['avatar_url'] as String?,
        isProvider: (map['is_provider'] as bool?) ?? false,
        headline: details?['headline'] as String?,
        bio: null,
        yearsExperience: null,
        averageRating: (details?['average_rating'] as num?)?.toDouble(),
        jobsCompleted: details?['jobs_completed'] as int?,
        city: location?['city'] as String?,
        region: location?['region'] as String?,
        country: location?['country'] as String?,
      );
    }).toList(growable: false);
  }

  Future<ProviderSummary> fetchProviderById(String providerId) async {
    final res = await _client
        .from('profiles')
        .select(
          'id,full_name,phone,avatar_url,is_provider,'
          'provider_details(headline,average_rating,jobs_completed,bio,years_experience),'
          'locations(city,region,country)',
        )
        .eq('id', providerId)
        .single();

    final map = res;

    final detailsRaw = map['provider_details'];
    final details = detailsRaw is List
        ? detailsRaw.cast<Map<String, dynamic>>().firstOrNull
        : detailsRaw as Map<String, dynamic>?;

    final locationRaw = map['locations'];
    final location = locationRaw is List
        ? locationRaw.cast<Map<String, dynamic>>().firstOrNull
        : locationRaw as Map<String, dynamic>?;

    return ProviderSummary(
      id: map['id'] as String,
      fullName: (map['full_name'] as String?) ?? 'Unnamed',
      phone: map['phone'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      isProvider: (map['is_provider'] as bool?) ?? false,
      headline: details?['headline'] as String?,
      bio: details?['bio'] as String?,
      yearsExperience: details?['years_experience'] as int?,
      averageRating: (details?['average_rating'] as num?)?.toDouble(),
      jobsCompleted: details?['jobs_completed'] as int?,
      city: location?['city'] as String?,
      region: location?['region'] as String?,
      country: location?['country'] as String?,
    );
  }
}

final directoryRepositoryProvider = Provider<DirectoryRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return null;
  return DirectoryRepository(client);
});

extension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
