import 'package:flutter_test/flutter_test.dart';
import 'package:smart_agri_app/models/sensor_data.dart';
import 'package:smart_agri_app/services/sensor_data_service.dart';

void main() {
  test('SensorData.fromMap parses diverse Firebase data types safely', () {
    final rawFirebaseMap = {
      'soilMoisture': 22, // integer
      'temperature': 35.2, // double
      'humidity': '61', // string
      'light': 450,
      'rain': false,
      'waterLevel': 28.0,
      'battery': 87,
      'deviceStatus': 'online',
      'timestamp': 1727350000000,
    };

    final sensorData = SensorData.fromMap(rawFirebaseMap);

    expect(sensorData.soilMoisture, 22.0);
    expect(sensorData.temperature, 35.2);
    expect(sensorData.humidity, 61.0);
    expect(sensorData.light, 450.0);
    expect(sensorData.rain, false);
    expect(sensorData.waterLevel, 28.0);
    expect(sensorData.battery, 87.0);
    expect(sensorData.deviceStatus, 'online');
    expect(sensorData.isOffline, false);
  });

  test('SensorThresholds and alerts react to live values correctly', () {
    final service = SensorDataService();

    // 1. Dry soil
    service.setDemoScenario(DemoScenario.lowSoilMoisture);
    var activeAlerts = service.getActiveAlerts();
    expect(activeAlerts.any((a) => a.sensorType == 'soilMoisture'), true);

    // 2. High Temperature
    service.setDemoScenario(DemoScenario.highTemperature);
    activeAlerts = service.getActiveAlerts();
    expect(activeAlerts.any((a) => a.sensorType == 'temperature'), true);

    // 3. Low Water
    service.setDemoScenario(DemoScenario.lowWaterLevel);
    activeAlerts = service.getActiveAlerts();
    expect(activeAlerts.any((a) => a.sensorType == 'waterLevel'), true);

    // 4. Device Offline
    service.setDemoScenario(DemoScenario.deviceOffline);
    activeAlerts = service.getActiveAlerts();
    expect(activeAlerts.any((a) => a.sensorType == 'deviceStatus'), true);

    service.stopTimer();
  });
}
