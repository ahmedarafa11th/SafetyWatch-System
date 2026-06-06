class Alert {
  final int id;
  final String title;
  final String? description;
  final String severity; // 'critical', 'high', 'medium', 'low'
  final String status; // 'active', 'resolved', 'dismissed'
  final int? confidence;
  final String? cameraName;
  final String? createdAt;

  const Alert({
    required this.id,
    required this.title,
    this.description,
    required this.severity,
    required this.status,
    this.confidence,
    this.cameraName,
    this.createdAt,
  });

  bool get isActive => status == 'active';

  String get severityDisplay =>
      severity[0].toUpperCase() + severity.substring(1);

  String get statusDisplay =>
      status[0].toUpperCase() + status.substring(1);

  String get formattedDate {
    if (createdAt == null) return '—';
    try {
      final dt = DateTime.parse(createdAt!);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return createdAt!;
    }
  }

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Untitled Alert',
      description: json['description'] as String?,
      severity: json['severity'] as String? ?? 'medium',
      status: json['status'] as String? ?? 'active',
      confidence: json['confidence'] as int?,
      cameraName: json['camera'] != null
          ? json['camera']['name'] as String?
          : json['camera_name'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}

class AlertStats {
  final int active;
  final int critical;
  final int unread;
  final int resolvedToday;
  final int avgConfidence;

  const AlertStats({
    this.active = 0,
    this.critical = 0,
    this.unread = 0,
    this.resolvedToday = 0,
    this.avgConfidence = 0,
  });

  factory AlertStats.fromJson(Map<String, dynamic> json) {
    return AlertStats(
      active: json['active'] as int? ?? 0,
      critical: json['critical'] as int? ?? 0,
      unread: json['unread'] as int? ?? 0,
      resolvedToday: json['resolved_today'] as int? ?? 0,
      avgConfidence: json['avg_confidence'] as int? ?? 0,
    );
  }
}
