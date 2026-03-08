enum AdType { banner, interstitial, hero, popup }

class Ad {
  Ad({
    required this.id,
    required this.type,
    required this.imageUrl,
    required this.isActive,
    this.redirectUrl,
    this.targetCategoryId,
    this.startDate,
    this.endDate,
  });

  final String id;
  final AdType type;
  final String imageUrl;
  final String? redirectUrl;
  final int? targetCategoryId;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;

  factory Ad.fromMap(Map<String, dynamic> map) {
    final typeStr = map['type'] as String;
    final AdType type;
    switch (typeStr) {
      case 'interstitial':
        type = AdType.interstitial;
        break;
      case 'hero':
        type = AdType.hero;
        break;
      case 'popup':
        type = AdType.popup;
        break;
      default:
        type = AdType.banner;
    }
    return Ad(
      id: map['id'] as String,
      type: type,
      imageUrl: map['image_url'] as String,
      redirectUrl: map['redirect_url'] as String?,
      targetCategoryId: map['target_category_id'] as int?,
      isActive: (map['is_active'] as bool?) ?? true,
      startDate: map['start_date'] == null
          ? null
          : DateTime.tryParse(map['start_date'] as String),
      endDate: map['end_date'] == null
          ? null
          : DateTime.tryParse(map['end_date'] as String),
    );
  }

  /// Convert AdType to DB string.
  static String typeToString(AdType t) {
    switch (t) {
      case AdType.banner:
        return 'banner';
      case AdType.interstitial:
        return 'interstitial';
      case AdType.hero:
        return 'hero';
      case AdType.popup:
        return 'popup';
    }
  }
}
