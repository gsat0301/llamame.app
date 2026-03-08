/// A provider role request with applicant display info for the admin list.
class AdminProviderRequest {
  AdminProviderRequest({
    required this.id,
    required this.profileId,
    required this.status,
    required this.createdAt,
    this.motivation,
    this.resolvedAt,
    this.resolvedBy,
    this.applicantName,
    this.applicantPhone,
    this.resolverName, // Opcional: Para saber quién lo resolvió
  });

  final String id;
  final String profileId;
  final String status;
  final DateTime createdAt;
  final String? motivation;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final String? applicantName;
  final String? applicantPhone;
  final String? resolverName; // Campo extra útil para admin

  bool get isPending => status == 'pending';

  factory AdminProviderRequest.fromMap(Map<String, dynamic> map) {
    // CAMBIO CLAVE: Ahora buscamos los datos bajo el alias 'applicant' 
    // y opcionalmente 'resolver' que definiremos en el query del repositorio.
    final applicantData = map['applicant'] as Map<String, dynamic>?;
    final resolverData = map['resolver'] as Map<String, dynamic>?;

    return AdminProviderRequest(
      id: map['id'] as String,
      profileId: map['profile_id'] as String,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      motivation: map['motivation'] as String?,
      resolvedAt: map['resolved_at'] == null ? null : DateTime.parse(map['resolved_at'] as String),
      resolvedBy: map['resolved_by'] as String?,
      
      // Extraemos de los alias
      applicantName: applicantData?['full_name'] as String?,
      applicantPhone: applicantData?['phone'] as String?,
      resolverName: resolverData?['full_name'] as String?,
    );
  }
}

/// A rating with comment, for admin view only.
class AdminRating {
  AdminRating({
    required this.id,
    required this.providerId,
    required this.customerId,
    required this.stars,
    required this.createdAt,
    this.providerName,
    this.customerName,
    this.comment,
  });

  final String id;
  final String providerId;
  final String customerId;
  final int stars;
  final DateTime createdAt;
  final String? providerName;
  final String? customerName;
  final String? comment;

  factory AdminRating.fromMap(Map<String, dynamic> map) {
    final providerProfile = map['provider'] as Map<String, dynamic>?;
    final customerProfile = map['customer'] as Map<String, dynamic>?;
    return AdminRating(
      id: map['id'] as String,
      providerId: map['provider_id'] as String,
      customerId: map['customer_id'] as String,
      stars: map['stars'] as int,
      comment: map['comment'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      providerName: providerProfile?['full_name'] as String?,
      customerName: customerProfile?['full_name'] as String?,
    );
  }
}
