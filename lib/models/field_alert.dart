enum AlertSeverity { info, warning, critical }

class FieldAlert {
  final String id;
  final String title;
  final String fieldId;
  final String message;
  final String currentValue;
  final String recommendedAction;
  final DateTime timestamp;
  final AlertSeverity severity;
  final bool isResolved;
  final String sensorType;

  const FieldAlert({
    required this.id,
    required this.title,
    this.fieldId = 'Field 01',
    required this.message,
    required this.currentValue,
    required this.recommendedAction,
    required this.timestamp,
    required this.severity,
    this.isResolved = false,
    required this.sensorType,
  });

  factory FieldAlert.fromMap(Map<String, dynamic> map, String id) {
    return FieldAlert(
      id: id,
      title: map['title'] as String? ?? 'Alert',
      fieldId: map['fieldId'] as String? ?? 'Field 01',
      message: map['message'] as String? ?? '',
      currentValue: map['currentValue'] as String? ?? '',
      recommendedAction: map['recommendedAction'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] is int
              ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
              : DateTime.parse(map['timestamp'].toString()))
          : DateTime.now(),
      severity: _parseSeverity(map['severity'] as String?),
      isResolved: map['isResolved'] as bool? ?? false,
      sensorType: map['sensorType'] as String? ?? 'general',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'fieldId': fieldId,
      'message': message,
      'currentValue': currentValue,
      'recommendedAction': recommendedAction,
      'timestamp': timestamp.toIso8601String(),
      'severity': severity.name,
      'isResolved': isResolved,
      'sensorType': sensorType,
    };
  }

  static AlertSeverity _parseSeverity(String? sev) {
    switch (sev?.toLowerCase()) {
      case 'critical':
        return AlertSeverity.critical;
      case 'warning':
        return AlertSeverity.warning;
      default:
        return AlertSeverity.info;
    }
  }

  String get severityName {
    switch (severity) {
      case AlertSeverity.critical:
        return 'Critical';
      case AlertSeverity.warning:
        return 'Warning';
      case AlertSeverity.info:
        return 'Info';
    }
  }

  FieldAlert copyWith({
    String? id,
    String? title,
    String? fieldId,
    String? message,
    String? currentValue,
    String? recommendedAction,
    DateTime? timestamp,
    AlertSeverity? severity,
    bool? isResolved,
    String? sensorType,
  }) {
    return FieldAlert(
      id: id ?? this.id,
      title: title ?? this.title,
      fieldId: fieldId ?? this.fieldId,
      message: message ?? this.message,
      currentValue: currentValue ?? this.currentValue,
      recommendedAction: recommendedAction ?? this.recommendedAction,
      timestamp: timestamp ?? this.timestamp,
      severity: severity ?? this.severity,
      isResolved: isResolved ?? this.isResolved,
      sensorType: sensorType ?? this.sensorType,
    );
  }
}

