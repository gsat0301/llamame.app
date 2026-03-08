import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase_client.dart';
import '../ads/ad_models.dart';
import 'admin_models.dart';

class AdminRepository {
  AdminRepository(this._client);

  final SupabaseClient _client;

  /// Fetches all provider role requests (RLS allows only admins).
  /// Joins profiles to get applicant full_name and phone.
  Future<List<AdminProviderRequest>> fetchProviderRequests() async {
    final res = await _client.from('provider_role_requests').select('''
    *,
    applicant:profiles!provider_role_requests_profile_id_fkey (
      full_name,
      phone
    ),
    resolver:profiles!provider_role_requests_resolved_by_fkey (
      full_name
    )
  ''').order('created_at', ascending: false);

    return (res as List)
        .map((e) => AdminProviderRequest.fromMap(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  /// Approve or reject a request. Caller must be admin (enforced by RPC).
  Future<void> resolveProviderRequest(String requestId, bool approve) async {
    await _client.rpc('resolve_provider_request', params: {
      'request_id': requestId,
      'approve': approve,
    });
  }

  /// Fetches all ratings with comments (admin only).
  /// Joins profiles for provider and customer names.
  Future<List<AdminRating>> fetchAllRatings() async {
    final res = await _client
        .from('provider_ratings')
        .select(
          'id, provider_id, customer_id, stars, comment, created_at, '
          'provider:profiles!provider_ratings_provider_id_fkey(full_name), '
          'customer:profiles!provider_ratings_customer_id_fkey(full_name)',
        )
        .order('created_at', ascending: false);

    return (res as List)
        .map((e) => AdminRating.fromMap(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  // ── Ads management ──────────────────────────────────────────────────────

  /// Fetches all ads (admin only — RLS policy allows admin full access).
  Future<List<Ad>> fetchAllAds() async {
    final res = await _client
        .from('ads')
        .select(
            'id, type, image_url, redirect_url, target_category_id, is_active, start_date, end_date')
        .order('created_at', ascending: false);

    return (res as List)
        .map((e) => Ad.fromMap(e as Map<String, dynamic>))
        .toList(growable: false);
  }

  /// Creates a new ad.
  Future<void> createAd({
    required AdType type,
    required String imageUrl,
    String? redirectUrl,
    int? targetCategoryId,
    bool isActive = true,
  }) async {
    await _client.from('ads').insert({
      'type': Ad.typeToString(type),
      'image_url': imageUrl,
      'redirect_url': redirectUrl,
      'target_category_id': targetCategoryId,
      'is_active': isActive,
      // client_id is required by DB — for MVP, we use a default ad client.
      'client_id': await _getOrCreateDefaultAdClient(),
    });
  }

  /// Updates an existing ad.
  Future<void> updateAd({
    required String id,
    AdType? type,
    String? imageUrl,
    String? redirectUrl,
    int? targetCategoryId,
    bool? isActive,
  }) async {
    final updates = <String, dynamic>{};
    if (type != null) updates['type'] = Ad.typeToString(type);
    if (imageUrl != null) updates['image_url'] = imageUrl;
    if (redirectUrl != null) updates['redirect_url'] = redirectUrl;
    if (targetCategoryId != null) {
      updates['target_category_id'] = targetCategoryId;
    }
    if (isActive != null) updates['is_active'] = isActive;

    if (updates.isNotEmpty) {
      await _client.from('ads').update(updates).eq('id', id);
    }
  }

  /// Deletes an ad.
  Future<void> deleteAd(String id) async {
    await _client.from('ads').delete().eq('id', id);
  }

  /// Uploads an ad image to the 'ads' Storage bucket and returns the public URL.
  Future<String> uploadAdImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final path = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await _client.storage.from('ads').uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true),
        );
    return _client.storage.from('ads').getPublicUrl(path);
  }

  /// Gets or creates a default ad client for admin-created ads.
  Future<String> _getOrCreateDefaultAdClient() async {
    final existing = await _client
        .from('ad_clients')
        .select('id')
        .eq('company_name', 'Platform Ads')
        .limit(1);

    if ((existing as List).isNotEmpty) {
      return existing.first['id'] as String;
    }

    final inserted = await _client
        .from('ad_clients')
        .insert({'company_name': 'Platform Ads'})
        .select('id')
        .single();

    return inserted['id'] as String;
  }
}

final adminRepositoryProvider = Provider<AdminRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return null;
  return AdminRepository(client);
});
