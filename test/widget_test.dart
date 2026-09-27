import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_agri_app/main.dart';
import 'package:smart_agri_app/services/sensor_data_service.dart';

void main() {
  tearDown(() {
    SensorDataService().stopTimer();
  });

  testWidgets('Smart Agriculture Monitoring App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SmartAgriApp());

    // Verify app builds without crashing and displays initial Home screen elements
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Explore'), findsWidgets);
    expect(find.text('Alerts'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);

    SensorDataService().stopTimer();
  });
}
