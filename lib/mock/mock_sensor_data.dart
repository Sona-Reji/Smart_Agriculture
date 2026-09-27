import '../models/sensor_data.dart';

class MockSensorData {
  static SensorData getBaselineData() {
    return SensorData(
      soilMoisture: 42.0,
      temperature: 29.5,
      humidity: 76.0,
      light: 680.0,
      rain: false,
      waterLevel: 72.0,
      battery: 91.0,
      deviceStatus: 'online',
      timestamp: DateTime.now(),
    );
  }
}
