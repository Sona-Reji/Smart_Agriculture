class FarmWorker {
  final String id;
  final String name;
  final String role; // 'Experienced Farm Hand', 'Harvest Specialist', 'Irrigation Expert'
  final List<String> skills;
  final int experienceYears;
  final String location;
  final double distanceKm;
  final String availability; // 'Available Tomorrow', 'Available Today', 'Available from Monday'
  final String dailyRate; // '₹600 / day'
  final double rating;
  final String phone;
  final String about;
  final String avatarEmoji;

  const FarmWorker({
    required this.id,
    required this.name,
    required this.role,
    required this.skills,
    required this.experienceYears,
    required this.location,
    required this.distanceKm,
    required this.availability,
    required this.dailyRate,
    this.rating = 4.8,
    this.phone = '+91 97654 32109',
    required this.about,
    this.avatarEmoji = '👷',
  });

  String get distanceText => '${distanceKm.toStringAsFixed(1)} km away';
}
