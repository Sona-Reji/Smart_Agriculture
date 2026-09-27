enum ResourceCategory {
  equipment,
  farmWorkers,
  seedsSaplings,
  toolsSupplies,
  irrigation,
  farmingInputs;

  String get label {
    switch (this) {
      case ResourceCategory.equipment:
        return 'Equipment';
      case ResourceCategory.farmWorkers:
        return 'Farm Workers';
      case ResourceCategory.seedsSaplings:
        return 'Seeds & Saplings';
      case ResourceCategory.toolsSupplies:
        return 'Tools & Supplies';
      case ResourceCategory.irrigation:
        return 'Irrigation';
      case ResourceCategory.farmingInputs:
        return 'Farming Inputs';
    }
  }

  String get emoji {
    switch (this) {
      case ResourceCategory.equipment:
        return '🚜';
      case ResourceCategory.farmWorkers:
        return '👷';
      case ResourceCategory.seedsSaplings:
        return '🌱';
      case ResourceCategory.toolsSupplies:
        return '🧰';
      case ResourceCategory.irrigation:
        return '💧';
      case ResourceCategory.farmingInputs:
        return '🧪';
    }
  }
}

class Resource {
  final String id;
  final String title;
  final ResourceCategory category;
  final String providerName;
  final String providerPhone;
  final String location;
  final double distanceKm;
  final String availabilityText;
  final String priceText;
  final String description;
  final bool isAvailable;
  final bool isSaved;
  final String iconEmoji;
  final Map<String, String> specifications;
  final DateTime createdAt;

  const Resource({
    required this.id,
    required this.title,
    required this.category,
    required this.providerName,
    this.providerPhone = '+91 98220 12345',
    required this.location,
    required this.distanceKm,
    required this.availabilityText,
    required this.priceText,
    required this.description,
    this.isAvailable = true,
    this.isSaved = false,
    this.iconEmoji = '📦',
    this.specifications = const {},
    required this.createdAt,
  });

  String get distanceText => '${distanceKm.toStringAsFixed(1)} km away';

  Resource copyWith({
    String? id,
    String? title,
    ResourceCategory? category,
    String? providerName,
    String? providerPhone,
    String? location,
    double? distanceKm,
    String? availabilityText,
    String? priceText,
    String? description,
    bool? isAvailable,
    bool? isSaved,
    String? iconEmoji,
    Map<String, String>? specifications,
    DateTime? createdAt,
  }) {
    return Resource(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      providerName: providerName ?? this.providerName,
      providerPhone: providerPhone ?? this.providerPhone,
      location: location ?? this.location,
      distanceKm: distanceKm ?? this.distanceKm,
      availabilityText: availabilityText ?? this.availabilityText,
      priceText: priceText ?? this.priceText,
      description: description ?? this.description,
      isAvailable: isAvailable ?? this.isAvailable,
      isSaved: isSaved ?? this.isSaved,
      iconEmoji: iconEmoji ?? this.iconEmoji,
      specifications: specifications ?? this.specifications,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
