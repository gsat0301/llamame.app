import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase_client.dart';
import 'profile_models.dart';

class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;

  Future<Profile> fetchMyProfile() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw const AuthException('No autenticado');

    final res = await _client
        .from('profiles')
        .select('*, locations(*)')
        .eq('id', uid)
        .single();
    return Profile.fromMap(res);
  }

  Future<Profile> updateMyProfile({
    String? fullName,
    String? phone,
    String? avatarUrl,
    String? city,
    String? region,
    String? country,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw const AuthException('No autenticado');

    final payload = <String, dynamic>{
      if (fullName != null) 'full_name': fullName,
      if (phone != null) 'phone': phone,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };

    if (payload.isNotEmpty) {
      await _client.from('profiles').update(payload).eq('id', uid);
    }

    // Upsert location - handle empty strings as nulls for consistency
    final cityVal = city?.trim().isEmpty == true ? null : city?.trim();
    final regionVal = region?.trim().isEmpty == true ? null : region?.trim();
    final countryVal = country?.trim().isEmpty == true ? null : country?.trim();

    await _client.from('locations').upsert({
      'profile_id': uid,
      'city': cityVal,
      'region': regionVal,
      'country': countryVal,
    }, onConflict: 'profile_id');

    return fetchMyProfile();
  }

  Future<ProviderRoleRequest?> fetchLatestMyProviderRequest() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw const AuthException('No autenticado');

    final list = await _client
        .from('provider_role_requests')
        .select()
        .eq('profile_id', uid)
        .order('created_at', ascending: false)
        .limit(1);

    if (list.isNotEmpty) {
      return ProviderRoleRequest.fromMap(list.first);
    }
    return null;
  }

  Future<String> requestProviderRole({required String motivation}) async {
    final res = await _client
        .rpc('request_provider_role', params: {'motivation': motivation});
    return res as String;
  }
}

final profileRepositoryProvider = Provider<ProfileRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) return null;
  return ProfileRepository(client);
});
