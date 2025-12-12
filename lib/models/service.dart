class Service {
  final String serviceId;
  final String title;
  final String? titleEn;
  final List<String> requiredFields;
  final List<String> categories;
  final String description;
  final String? descriptionEn;
  final String? icon;
  final int? estimatedDays;
  final List<String>? features;

  Service({
    required this.serviceId,
    required this.title,
    this.titleEn,
    required this.requiredFields,
    required this.categories,
    required this.description,
    this.descriptionEn,
    this.icon,
    this.estimatedDays,
    this.features,
  });

  // Get localized title based on language
  String getTitle(String language) {
    if (language == 'en' && titleEn != null) {
      return titleEn!;
    }
    return title;
  }

  // Get localized description based on language
  String getDescription(String language) {
    if (language == 'en' && descriptionEn != null) {
      return descriptionEn!;
    }
    return description;
  }

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      serviceId: json['serviceId'] as String,
      title: json['title'] as String,
      titleEn: json['title_en'] as String?,
      requiredFields: List<String>.from(json['required_fields'] as List),
      categories: List<String>.from(json['categories'] as List),
      description: json['description'] as String,
      descriptionEn: json['description_en'] as String?,
      icon: json['icon'] as String?,
      estimatedDays: json['estimated_days'] as int?,
      features: json['features'] != null ? List<String>.from(json['features'] as List) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'title': title,
      if (titleEn != null) 'title_en': titleEn,
      'required_fields': requiredFields,
      'categories': categories,
      'description': description,
      if (descriptionEn != null) 'description_en': descriptionEn,
      if (icon != null) 'icon': icon,
      if (estimatedDays != null) 'estimated_days': estimatedDays,
      if (features != null) 'features': features,
    };
  }
}
