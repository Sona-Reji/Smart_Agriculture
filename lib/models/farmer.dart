import 'dart:math';

enum ConnectionStatus { connect, requested, connected, incoming }

class Farmer {
  final String id;
  final String name;
  final String farmingType; // e.g. 'Vegetable Farmer', 'Organic Farmer', 'Fruit Farmer'
  final List<String> mainCrops;
  final int experienceYears;
  final String location;
  final double distanceKm;
  final String avatarEmoji;
  final ConnectionStatus connectionStatus;
  final String about;
  final List<String> skills;
  final int resourcesSharedCount;
  final int postsCount;
  final String contactPhone;
  final double rating;
  final double? lat;
  final double? lng;

  const Farmer({
    required this.id,
    required this.name,
    required this.farmingType,
    required this.mainCrops,
    required this.experienceYears,
    required this.location,
    required this.distanceKm,
    this.avatarEmoji = '👨‍🌾',
    this.connectionStatus = ConnectionStatus.connect,
    required this.about,
    required this.skills,
    this.resourcesSharedCount = 0,
    this.postsCount = 0,
    this.contactPhone = '+91 98765 43210',
    this.rating = 4.9,
    this.lat,
    this.lng,
  });

  String get distanceText => '${distanceKm.toStringAsFixed(1)} km away';
  String get experienceText => '$experienceYears yrs exp';
  String get cropsSummary => mainCrops.join(' • ');

  static double calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  factory Farmer.fromFirebase(String uid, Map<String, dynamic> userNode, {double? currentLat, double? currentLng}) {
    final profile = (userNode['profile'] as Map?)?.cast<String, dynamic>() ?? {};
    final locNode = (userNode['location'] as Map?)?.cast<String, dynamic>() ?? {};
    
    final lat = (locNode['lat'] as num?)?.toDouble();
    final lng = (locNode['lng'] as num?)?.toDouble();

    double dist = 2.5;
    if (lat != null && lng != null && currentLat != null && currentLng != null) {
      dist = calculateDistanceKm(currentLat, currentLng, lat, lng);
    } else {
      dist = (profile['distanceKm'] as num?)?.toDouble() ?? 3.2;
    }

    final cropsList = (profile['mainCrops'] as List?)?.map((e) => e.toString()).toList() ??
        ['Hybrid Tomato', 'Bell Pepper'];
    final skillsList = (profile['skills'] as List?)?.map((e) => e.toString()).toList() ??
        ['Smart Irrigation', 'Crop Protection'];

    return Farmer(
      id: uid,
      name: profile['name']?.toString() ?? 'Farmer',
      farmingType: profile['farmingType']?.toString() ?? 'Smart Agri Farmer',
      mainCrops: cropsList,
      experienceYears: (profile['experienceYears'] as num?)?.toInt() ?? 5,
      location: profile['location']?.toString() ?? locNode['address']?.toString() ?? 'Kattappana, Kerala',
      distanceKm: dist,
      avatarEmoji: profile['avatarEmoji']?.toString() ?? '👨‍🌾',
      about: profile['about']?.toString() ?? 'Cultivating high yield crops in sector 2.',
      skills: skillsList,
      resourcesSharedCount: (profile['resourcesSharedCount'] as num?)?.toInt() ?? 0,
      postsCount: (profile['postsCount'] as num?)?.toInt() ?? 0,
      contactPhone: profile['contactPhone']?.toString().isNotEmpty == true
          ? profile['contactPhone'].toString()
          : '+91 98765 43210',
      rating: (profile['rating'] as num?)?.toDouble() ?? 4.9,
      lat: lat,
      lng: lng,
    );
  }

  Farmer copyWith({
    String? id,
    String? name,
    String? farmingType,
    List<String>? mainCrops,
    int? experienceYears,
    String? location,
    double? distanceKm,
    String? avatarEmoji,
    ConnectionStatus? connectionStatus,
    String? about,
    List<String>? skills,
    int? resourcesSharedCount,
    int? postsCount,
    String? contactPhone,
    double? rating,
    double? lat,
    double? lng,
  }) {
    return Farmer(
      id: id ?? this.id,
      name: name ?? this.name,
      farmingType: farmingType ?? this.farmingType,
      mainCrops: mainCrops ?? this.mainCrops,
      experienceYears: experienceYears ?? this.experienceYears,
      location: location ?? this.location,
      distanceKm: distanceKm ?? this.distanceKm,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      about: about ?? this.about,
      skills: skills ?? this.skills,
      resourcesSharedCount: resourcesSharedCount ?? this.resourcesSharedCount,
      postsCount: postsCount ?? this.postsCount,
      contactPhone: contactPhone ?? this.contactPhone,
      rating: rating ?? this.rating,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }
}
