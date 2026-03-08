class ServiceCategory {
  ServiceCategory({
    required this.id,
    required this.name,
    this.iconKey,
  });

  final int id;
  final String name;
  final String? iconKey;

  factory ServiceCategory.fromMap(Map<String, dynamic> map) {
    return ServiceCategory(
      id: map['id'] as int,
      name: map['name'] as String,
      iconKey: map['icon_key'] as String?,
    );
  }
}

class ProviderSummary {
  ProviderSummary({
    required this.id,
    required this.fullName,
    required this.isProvider,
    this.phone,
    this.avatarUrl,
    this.headline,
    this.bio,
    this.yearsExperience,
    this.averageRating,
    this.jobsCompleted,
    this.city,
    this.region,
    this.country,
  });

  final String id;
  final String fullName;
  final bool isProvider;
  final String? phone;
  final String? avatarUrl;
  final String? headline;
  final String? bio;
  final int? yearsExperience;
  final double? averageRating;
  final int? jobsCompleted;
  final String? city;
  final String? region;
  final String? country;
}

