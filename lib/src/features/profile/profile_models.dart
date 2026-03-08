class Profile {
  Profile({
    required this.id,
    required this.isProvider,
    required this.isCustomer,
    required this.isAdmin,
    this.fullName,
    this.phone,
    this.avatarUrl,
    this.city,
    this.region,
    this.country,
  });

  final String id;
  final String? fullName;
  final String? phone;
  final String? avatarUrl;
  final String? city;
  final String? region;
  final String? country;
  final bool isProvider;
  final bool isCustomer;
  final bool isAdmin;

  factory Profile.fromMap(Map<String, dynamic> map) {
    // Handle joined locations if present
    final locationRaw = map['locations'];
    final location = locationRaw is List
        ? (locationRaw.isEmpty ? null : locationRaw.first as Map<String, dynamic>?)
        : locationRaw as Map<String, dynamic>?;

    return Profile(
      id: map['id'] as String,
      fullName: map['full_name'] as String?,
      phone: map['phone'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      city: location?['city'] as String?,
      region: location?['region'] as String?,
      country: location?['country'] as String?,
      isProvider: (map['is_provider'] as bool?) ?? false,
      isCustomer: (map['is_customer'] as bool?) ?? true,
      isAdmin: (map['is_admin'] as bool?) ?? false,
    );
  }
}

class ProviderRoleRequest {
  ProviderRoleRequest({
    required this.id,
    required this.profileId,
    required this.status,
    required this.createdAt,
    this.motivation,
    this.resolvedAt,
    this.resolvedBy,
  });

  final String id;
  final String profileId;
  final String status; // pending/approved/rejected
  final DateTime createdAt;
  final String? motivation;
  final DateTime? resolvedAt;
  final String? resolvedBy;

  factory ProviderRoleRequest.fromMap(Map<String, dynamic> map) {
    return ProviderRoleRequest(
      id: map['id'] as String,
      profileId: map['profile_id'] as String,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      motivation: map['motivation'] as String?,
      resolvedAt: map['resolved_at'] == null ? null : DateTime.parse(map['resolved_at'] as String),
      resolvedBy: map['resolved_by'] as String?,
    );
  }
}

