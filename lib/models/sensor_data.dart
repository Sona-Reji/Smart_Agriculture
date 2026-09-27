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

  /// Factory constructor to deserialize Firebase Realtime Database map safely
  factory SensorData.fromMap(Map<dynamic, dynamic> map) {
    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    bool parseBool(dynamic val) {
      if (val == null) return false;
      if (val is bool) return val;
      if (val is num) return val != 0;
      if (val is String) {
        final s = val.toLowerCase().trim();
        return s == 'true' || s == '1' || s == 'yes';
      }
      return false;
    }

    DateTime parseTimestamp(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is int) {
        // Handle both epoch seconds (10 digits) and milliseconds (13 digits)
        final ms = val < 10000000000 ? val * 1000 : val;
        return DateTime.fromMillisecondsSinceEpoch(ms);
      }
      try {
        return DateTime.parse(val.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    return SensorData(
      soilMoisture: parseDouble(map['soilMoisture']),
      temperature: parseDouble(map['temperature']),
      humidity: parseDouble(map['humidity']),
      light: parseDouble(map['light']),
      rain: parseBool(map['rain']),
      waterLevel: parseDouble(map['waterLevel']),
      battery: parseDouble(map['battery']),
      deviceStatus: map['deviceStatus']?.toString() ?? 'online',
      timestamp: parseTimestamp(map['timestamp']),
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
