import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/sensor_data.dart';
import '../models/field_alert.dart';

enum DemoScenario {
  normal,
  lowSoilMoisture,
  lowWaterLevel,
  highTemperature,
  rainDetected,
  deviceOffline,
}

enum HistoryTimeframe {
  today,
  hours24,
  days7,
}

class SensorDataService extends ChangeNotifier {
  // Singleton pattern for easy service access
  static final SensorDataService _instance = SensorDataService._internal();
  factory SensorDataService() => _instance;
  SensorDataService._internal() {
    _initTimer();
    _initFirebaseListener();
  }

  final Set<String> _resolvedAlertIds = {};

  DemoScenario _currentScenario = DemoScenario.normal;
  DemoScenario get currentScenario => _currentScenario;

  late SensorData _currentData = _generateCurrentDataForScenario(_currentScenario);
  SensorData get currentData => _currentData;

  DateTime _lastUpdated = DateTime.now();
  DateTime get lastUpdated => _lastUpdated;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Timer? _tickerTimer;
  StreamSubscription<DatabaseEvent>? _firebaseSubscription;

  void _initFirebaseListener() {
    try {
      final ref = FirebaseDatabase.instance.ref('fields/field01/current');
      _firebaseSubscription = ref.onValue.listen((event) {
        if (event.snapshot.exists && event.snapshot.value != null) {
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          _currentData = SensorData.fromMap(data);
          _lastUpdated = DateTime.now();
          notifyListeners();
        }
      }, onError: (e) {
        debugPrint("Firebase sensor listener note: $e");
      });
    } catch (e) {
      debugPrint("Firebase sensor init note: $e");
    }
  }

  void _initTimer() {
    _tickerTimer?.cancel();
    // Periodically tick seconds ago update
    _tickerTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_currentScenario != DemoScenario.deviceOffline) {
        _lastUpdated = DateTime.now();
        notifyListeners();
      }
    });
  }

  void stopTimer() {
    _tickerTimer?.cancel();
    _tickerTimer = null;
  }

  /// Mark an active alert as resolved
  void markAlertResolved(String alertId) {
    _resolvedAlertIds.add(alertId);
    notifyListeners();
  }

  /// Change active demo scenario and trigger instant UI update
  void setDemoScenario(DemoScenario scenario) {
    _currentScenario = scenario;
    _currentData = _generateCurrentDataForScenario(scenario);
    // Un-resolve alerts for the new scenario to trigger fresh alert state
    if (scenario == DemoScenario.lowSoilMoisture) _resolvedAlertIds.remove('alert_sm_01');
    if (scenario == DemoScenario.lowWaterLevel) _resolvedAlertIds.remove('alert_wl_01');
    if (scenario == DemoScenario.highTemperature) _resolvedAlertIds.remove('alert_temp_01');
    if (scenario == DemoScenario.deviceOffline) _resolvedAlertIds.remove('alert_off_01');

    if (scenario != DemoScenario.deviceOffline) {
      _lastUpdated = DateTime.now();
    }
    notifyListeners();
  }


  /// Simulate manual refresh action
  Future<void> refreshData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _isLoading = false;
    _lastUpdated = DateTime.now();
    _currentData = _generateCurrentDataForScenario(_currentScenario);
    notifyListeners();
  }

  /// Generate sensor data based on selected scenario
  SensorData _generateCurrentDataForScenario(DemoScenario scenario) {
    final now = DateTime.now();
    switch (scenario) {
      case DemoScenario.normal:
        return SensorData(
          soilMoisture: 42.0,
          temperature: 29.5,
          humidity: 76.0,
          light: 680.0,
          rain: false,
          waterLevel: 72.0,
          battery: 91.0,
          deviceStatus: 'online',
          timestamp: now,
        );
      case DemoScenario.lowSoilMoisture:
        return SensorData(
          soilMoisture: 18.0,
          temperature: 31.0,
          humidity: 62.0,
          light: 820.0,
          rain: false,
          waterLevel: 72.0,
          battery: 88.0,
          deviceStatus: 'online',
          timestamp: now,
        );
      case DemoScenario.lowWaterLevel:
        return SensorData(
          soilMoisture: 40.0,
          temperature: 28.5,
          humidity: 70.0,
          light: 650.0,
          rain: false,
          waterLevel: 18.0,
          battery: 85.0,
          deviceStatus: 'online',
          timestamp: now,
        );
      case DemoScenario.highTemperature:
        return SensorData(
          soilMoisture: 32.0,
          temperature: 38.5,
          humidity: 45.0,
          light: 950.0,
          rain: false,
          waterLevel: 60.0,
          battery: 90.0,
          deviceStatus: 'online',
          timestamp: now,
        );
      case DemoScenario.rainDetected:
        return SensorData(
          soilMoisture: 78.0,
          temperature: 22.0,
          humidity: 92.0,
          light: 210.0,
          rain: true,
          waterLevel: 85.0,
          battery: 94.0,
          deviceStatus: 'online',
          timestamp: now,
        );
      case DemoScenario.deviceOffline:
        return SensorData(
          soilMoisture: 42.0,
          temperature: 29.5,
          humidity: 76.0,
          light: 680.0,
          rain: false,
          waterLevel: 72.0,
          battery: 91.0,
          deviceStatus: 'offline',
          timestamp: now.subtract(const Duration(minutes: 15)),
        );
    }
  }

  /// Returns list of active & resolved alerts matching current state
  List<FieldAlert> getAlerts() {
    final now = DateTime.now();
    final alerts = <FieldAlert>[];

    // Scenario specific active alerts
    if (_currentScenario == DemoScenario.lowSoilMoisture || _currentData.soilMoisture < 25) {
      alerts.add(
        FieldAlert(
          id: 'alert_sm_01',
          title: 'SOIL MOISTURE LOW',
          fieldId: 'Field 01',
          message: 'Soil moisture dropped to critical levels.',
          currentValue: '${_currentData.soilMoisture.toStringAsFixed(0)}%',
          recommendedAction: 'Check irrigation requirements immediately.',
          timestamp: now.subtract(const Duration(minutes: 2)),
          severity: AlertSeverity.warning,
          sensorType: 'soilMoisture',
        ),
      );
    }

    if (_currentScenario == DemoScenario.lowWaterLevel || _currentData.waterLevel < 30) {
      alerts.add(
        FieldAlert(
          id: 'alert_wl_01',
          title: 'WATER LEVEL LOW',
          fieldId: 'Field 01',
          message: 'Irrigation reservoir water supply is low.',
          currentValue: '${_currentData.waterLevel.toStringAsFixed(0)}%',
          recommendedAction: 'Refill primary water storage tank.',
          timestamp: now.subtract(const Duration(minutes: 10)),
          severity: AlertSeverity.warning,
          sensorType: 'waterLevel',
        ),
      );
    }

    if (_currentScenario == DemoScenario.highTemperature || _currentData.temperature > 35) {
      alerts.add(
        FieldAlert(
          id: 'alert_temp_01',
          title: 'HIGH TEMPERATURE DETECTED',
          fieldId: 'Field 01',
          message: 'Field temperature exceeded safe threshold.',
          currentValue: '${_currentData.temperature.toStringAsFixed(1)}°C',
          recommendedAction: 'Consider activate shade nets or misting systems.',
          timestamp: now.subtract(const Duration(minutes: 25)),
          severity: AlertSeverity.warning,
          sensorType: 'temperature',
        ),
      );
    }

    if (_currentScenario == DemoScenario.deviceOffline || _currentData.isOffline) {
      alerts.add(
        FieldAlert(
          id: 'alert_off_01',
          title: 'DEVICE OFFLINE',
          fieldId: 'Field 01',
          message: 'No sensor data received from ESP32 gateway recently.',
          currentValue: 'Offline',
          recommendedAction: 'Check field gateway power supply and Wi-Fi connection.',
          timestamp: now.subtract(const Duration(minutes: 15)),
          severity: AlertSeverity.critical,
          sensorType: 'deviceStatus',
        ),
      );
    }

    // Historical / Resolved Alerts
    alerts.add(
      FieldAlert(
        id: 'alert_hist_01',
        title: 'TEMPERATURE ELEVATED',
        fieldId: 'Field 01',
        message: 'Midday heat spike registered.',
        currentValue: '34.2°C',
        recommendedAction: 'Monitored automatically.',
        timestamp: now.subtract(const Duration(hours: 5)),
        severity: AlertSeverity.info,
        isResolved: true,
        sensorType: 'temperature',
      ),
    );

    alerts.add(
      FieldAlert(
        id: 'alert_hist_02',
        title: 'RAIN DETECTED',
        fieldId: 'Field 01',
        message: 'Precipitation detected in field sector 1.',
        currentValue: 'Active Rain',
        recommendedAction: 'Automated irrigation paused.',
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        severity: AlertSeverity.info,
        isResolved: true,
        sensorType: 'rain',
      ),
    );

    return alerts.map((a) {
      if (_resolvedAlertIds.contains(a.id)) {
        return a.copyWith(isResolved: true);
      }
      return a;
    }).toList();
  }

  /// Get active alerts list shortcut
  List<FieldAlert> getActiveAlerts() {
    return getAlerts().where((a) => !a.isResolved).toList();
  }

  /// Get resolved alerts list shortcut
  List<FieldAlert> getResolvedAlerts() {
    return getAlerts().where((a) => a.isResolved).toList();
  }

  /// Generate historical data points for fl_chart line graphs
  List<SensorDataPoint> getHistoricalData(String metric, HistoryTimeframe timeframe) {
    final List<SensorDataPoint> points = [];
    int dataCount = 8;
    int stepMinutes = 60;

    switch (timeframe) {
      case HistoryTimeframe.today:
        dataCount = 8;
        stepMinutes = 120; // Every 2 hours
        break;
      case HistoryTimeframe.hours24:
        dataCount = 12;
        stepMinutes = 120; // Every 2 hours
        break;
      case HistoryTimeframe.days7:
        dataCount = 7;
        stepMinutes = 1440; // Every day
        break;
    }

    final now = DateTime.now();

    for (int i = dataCount - 1; i >= 0; i--) {
      final time = now.subtract(Duration(minutes: i * stepMinutes));
      double val = 0.0;

      // Realistic curves based on metric type
      final indexFactor = (dataCount - 1 - i).toDouble();
      if (metric == 'soilMoisture') {
        // Curve dropping slightly then rising after irrigation
        if (timeframe == HistoryTimeframe.days7) {
          val = 45.0 + (i % 3 == 0 ? 15.0 : -i * 3.0);
        } else {
          val = 55.0 - (indexFactor * 2.5);
          if (val < 25) val = 25;
        }
      } else if (metric == 'temperature') {
        // Daily temperature bell curve peaking around midday
        val = 24.0 + (6.0 * (1 - (i - dataCount / 2).abs() / (dataCount / 2)));
      } else if (metric == 'humidity') {
        val = 80.0 - (15.0 * (1 - (i - dataCount / 2).abs() / (dataCount / 2)));
      } else if (metric == 'waterLevel') {
        val = 90.0 - (indexFactor * 2.0);
      }

      points.add(SensorDataPoint(timestamp: time, value: val.clamp(0.0, 100.0)));
    }

    return points;
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    _firebaseSubscription?.cancel();
    super.dispose();
  }
}

class SensorDataPoint {
  final DateTime timestamp;
  final double value;

  SensorDataPoint({required this.timestamp, required this.value});
}
