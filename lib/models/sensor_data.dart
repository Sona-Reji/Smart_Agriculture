class SensorData {
  final double soilMoisture;
  final double temperature;
  final double humidity;
  final double light;
  final bool rain;
  final double waterLevel;
  final double battery;
  final String deviceStatus;
  final DateTime timestamp;

  const SensorData({
    required this.soilMoisture,
    required this.temperature,
    required this.humidity,
    required this.light,
    required this.rain,
    required this.waterLevel,
    required this.battery,
    required this.deviceStatus,
    required this.timestamp,
  });

  bool get isOffline => deviceStatus.toLowerCase() == 'offline';

  /// Factory constructor to deserialize Firebase Realtime Database map
  factory SensorData.fromMap(Map<String, dynamic> map) {
    return SensorData(
      soilMoisture: (map['soilMoisture'] as num?)?.toDouble() ?? 0.0,
      temperature: (map['temperature'] as num?)?.toDouble() ?? 0.0,
      humidity: (map['humidity'] as num?)?.toDouble() ?? 0.0,
      light: (map['light'] as num?)?.toDouble() ?? 0.0,
      rain: map['rain'] as bool? ?? false,
      waterLevel: (map['waterLevel'] as num?)?.toDouble() ?? 0.0,
      battery: (map['battery'] as num?)?.toDouble() ?? 0.0,
      deviceStatus: map['deviceStatus'] as String? ?? 'offline',
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] is int
              ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
              : DateTime.parse(map['timestamp'].toString()))
          : DateTime.now(),
    );
  }

  /// Serialize model to Map for Firebase Realtime Database
  Map<String, dynamic> toMap() {
    return {
      'soilMoisture': soilMoisture,
      'temperature': temperature,
      'humidity': humidity,
      'light': light,
      'rain': rain,
      'waterLevel': waterLevel,
      'battery': battery,
      'deviceStatus': deviceStatus,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  SensorData copyWith({
    double? soilMoisture,
    double? temperature,
    double? humidity,
    double? light,
    bool? rain,
    double? waterLevel,
    double? battery,
    String? deviceStatus,
    DateTime? timestamp,
  }) {
    return SensorData(
      soilMoisture: soilMoisture ?? this.soilMoisture,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      light: light ?? this.light,
      rain: rain ?? this.rain,
      waterLevel: waterLevel ?? this.waterLevel,
      battery: battery ?? this.battery,
      deviceStatus: deviceStatus ?? this.deviceStatus,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
