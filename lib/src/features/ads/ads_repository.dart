import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/supabase_client.dart';
import 'ad_models.dart';

class AdsRepository {
  AdsRepository(this._client);

  final SupabaseClient _client;

  Future<Ad?> fetchActiveAd({required AdType type, int? categoryId}) async {
    final typeStr = Ad.typeToString(type);

    // Targeting approach (MVP):
    // 1) Prefer exact category match
    // 2) Fallback to generic ads (target_category_id is null)
    final base = _client
        .from('ads')
        .select('id,type,image_url,redirect_url,target_category_id,is_active')
        .eq('type', typeStr);

    List<dynamic> rows = [];
    if (categoryId != null) {
      rows = await base.eq('target_category_id', categoryId).limit(5);
    }
    if (rows.isEmpty) {
      rows = await base.isFilter('target_category_id', null).limit(5);
    }
    if (rows.isEmpty) return null;

    // Pick first (could randomize later).
    return Ad.fromMap(rows.first as Map<String, dynamic>);
  }

  Future<void> recordImpression(
      {required String adId, bool clicked = false}) async {
    await _client.rpc('record_ad_impression',
        params: {'p_ad_id': adId, 'p_clicked': clicked});
  }

  String resolveImageUrl(Ad ad) {
    final raw = ad.imageUrl.trim();
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
  // Treat as Storage path in bucket `ads`
    return _client.storage.from('ads').getPublicUrl(raw);
  }

  /// Handles an ad click: records a clicked impression and opens the redirect URL in a new web tab.
  Future<void> handleAdClick(Ad ad) async {
    if (ad.redirectUrl == null || ad.redirectUrl!.trim().isEmpty) return;

    // Record click
    recordImpression(adId: ad.id, clicked: true).ignore();

    final uri = Uri.tryParse(ad.redirectUrl!);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

extension on Future<void> {
  void ignore() {}
}

final adsRepositoryProvider = Provider<AdsRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return null;
  return AdsRepository(client);
});
