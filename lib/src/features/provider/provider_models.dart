class ProviderDetails {
  ProviderDetails({
    required this.profileId,
    this.headline,
    this.bio,
    this.yearsExperience,
    this.averageRating,
    this.jobsCompleted,
  });

  final String profileId;
  final String? headline;
  final String? bio;
  final int? yearsExperience;
  final double? averageRating;
  final int? jobsCompleted;

  factory ProviderDetails.fromMap(Map<String, dynamic> map) {
    return ProviderDetails(
      profileId: map['profile_id'] as String,
      headline: map['headline'] as String?,
      bio: map['bio'] as String?,
      yearsExperience: map['years_experience'] as int?,
      averageRating: (map['average_rating'] as num?)?.toDouble(),
      jobsCompleted: map['jobs_completed'] as int?,
    );
  }
}

class ProviderGalleryImage {
  ProviderGalleryImage({
    required this.id,
    required this.providerId,
    required this.imageUrl,
    required this.position,
    required this.createdAt,
  });

  final String id;
  final String providerId;
  final String imageUrl;
  final int position;
  final DateTime createdAt;

  factory ProviderGalleryImage.fromMap(Map<String, dynamic> map) {
    return ProviderGalleryImage(
      id: map['id'] as String,
      providerId: map['provider_id'] as String,
      imageUrl: map['image_url'] as String,
      position: map['position'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class ProviderRating {
  ProviderRating({
    required this.id,
    required this.providerId,
    required this.customerId,
    required this.stars,
    required this.createdAt,
  });

  final String id;
  final String providerId;
  final String customerId;
  final int stars;
  final DateTime createdAt;

  factory ProviderRating.fromMap(Map<String, dynamic> map) {
    return ProviderRating(
      id: map['id'] as String,
      providerId: map['provider_id'] as String,
      customerId: map['customer_id'] as String,
      stars: map['stars'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
