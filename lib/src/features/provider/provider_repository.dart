import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase_client.dart';
import 'provider_models.dart';

class ProviderRepository {
  ProviderRepository(this._client);

  final SupabaseClient _client;

  String get _uid {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw const AuthException('No autenticado');
    return uid;
  }

  Future<ProviderDetails?> fetchMyProviderDetails() async {
    final uid = _uid;
    final list = await _client
        .from('provider_details')
        .select()
        .eq('profile_id', uid)
        .limit(1);
    if (list.isNotEmpty) {
      return ProviderDetails.fromMap(list.first);
    }
    return null;
  }

  Future<ProviderDetails> upsertMyProviderDetails({
    required String? headline,
    required String? bio,
    required int? yearsExperience,
  }) async {
    final uid = _uid;
    final res = await _client
        .from('provider_details')
        .upsert(
          {
            'profile_id': uid,
            'headline': headline,
            'bio': bio,
            'years_experience': yearsExperience,
          },
          onConflict: 'profile_id',
        )
        .select()
        .single();
    return ProviderDetails.fromMap(res);
  }

  Future<Set<int>> fetchMyServiceCategoryIds() async {
    final uid = _uid;
    final res = await _client
        .from('provider_services')
        .select('category_id')
        .eq('provider_id', uid)
        .limit(500);
    final ids = <int>{};
    for (final row in (res as List)) {
      ids.add(row['category_id'] as int);
    }
    return ids;
  }

  Future<void> replaceMyServices(Set<int> categoryIds) async {
    final uid = _uid;

    // Simple MVP approach: delete all, insert selected.
    await _client.from('provider_services').delete().eq('provider_id', uid);

    if (categoryIds.isEmpty) return;
    final inserts = categoryIds
        .map((id) => {
              'provider_id': uid,
              'category_id': id,
            })
        .toList(growable: false);
    await _client.from('provider_services').insert(inserts);
  }

  // ---------------------------------------------------------------------------
  // Gallery
  // ---------------------------------------------------------------------------

  Future<List<ProviderGalleryImage>> fetchGallery(String providerId) async {
    final res = await _client
        .from('provider_gallery')
        .select()
        .eq('provider_id', providerId)
        .order('position');
    return (res as List)
        .map((e) => ProviderGalleryImage.fromMap(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<void> addGalleryImage({
    required String imageUrl,
    required int position,
  }) async {
    final uid = _uid;
    await _client.from('provider_gallery').upsert(
      {
        'provider_id': uid,
        'image_url': imageUrl,
        'position': position,
      },
      onConflict: 'provider_id,position',
    );
  }

  Future<void> deleteGalleryImage(String imageId) async {
    await _client.from('provider_gallery').delete().eq('id', imageId);
  }

  // ---------------------------------------------------------------------------
  // Ratings
  // ---------------------------------------------------------------------------

  Future<List<ProviderRating>> fetchRatings(String providerId) async {
    final res = await _client
        .from('provider_ratings')
        .select('id, provider_id, customer_id, stars, created_at')
        .eq('provider_id', providerId)
        .order('created_at', ascending: false);
    return (res as List)
        .map((e) => ProviderRating.fromMap(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<void> submitRating({
    required String providerId,
    required int stars,
    String? comment,
  }) async {
    final uid = _uid;
    await _client.from('provider_ratings').upsert(
      {
        'provider_id': providerId,
        'customer_id': uid,
        'stars': stars,
        'comment': comment,
      },
      onConflict: 'provider_id,customer_id',
    );
  }
}

final providerRepositoryProvider = Provider<ProviderRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return null;
  return ProviderRepository(client);
});
