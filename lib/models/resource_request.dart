enum RequestStatus {
  pending,
  accepted,
  completed;

  String get label {
    switch (this) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.accepted:
        return 'Accepted';
      case RequestStatus.completed:
        return 'Completed';
    }
  }
}

class ResourceRequest {
  final String id;
  final String resourceType; // 'Equipment', 'Worker', 'Seeds', 'Tools', 'Irrigation', 'Other'
  final String title;
  final String description;
  final String requiredDate;
  final String duration;
  final String location;
  final RequestStatus status;
  final DateTime timestamp;

  const ResourceRequest({
    required this.id,
    required this.resourceType,
    required this.title,
    required this.description,
    required this.requiredDate,
    required this.duration,
    required this.location,
    this.status = RequestStatus.pending,
    required this.timestamp,
  });

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  ResourceRequest copyWith({
    String? id,
    String? resourceType,
    String? title,
    String? description,
    String? requiredDate,
    String? duration,
    String? location,
    RequestStatus? status,
    DateTime? timestamp,
  }) {
    return ResourceRequest(
      id: id ?? this.id,
      resourceType: resourceType ?? this.resourceType,
      title: title ?? this.title,
      description: description ?? this.description,
      requiredDate: requiredDate ?? this.requiredDate,
      duration: duration ?? this.duration,
      location: location ?? this.location,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
