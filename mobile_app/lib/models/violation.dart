class Violation {
  final int id;
  final String type;
  final String severity; // 'high', 'medium', 'low', 'critical'
  final String status; // 'under_investigation', 'resolved'
  final String? detectedAt;
  final String? cameraName;
  final String? employeeName;

  const Violation({
    required this.id,
    required this.type,
    required this.severity,
    required this.status,
    this.detectedAt,
    this.cameraName,
    this.employeeName,
  });

  String get severityDisplay =>
      severity[0].toUpperCase() + severity.substring(1);

  String get statusDisplay {
    switch (status) {
      case 'under_investigation':
        return 'Under Investigation';
      case 'resolved':
        return 'Resolved';
      default:
        return status;
    }
  }

  String get formattedDate {
    if (detectedAt == null) return '—';
    try {
      final dt = DateTime.parse(detectedAt!);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return detectedAt!;
    }
  }

  factory Violation.fromJson(Map<String, dynamic> json) {
    return Violation(
      id: json['id'] as int,
      type: json['type'] as String? ?? 'Unknown',
      severity: json['severity'] as String? ?? 'medium',
      status: json['status'] as String? ?? 'under_investigation',
      detectedAt: json['detected_at'] as String?,
      cameraName: json['camera'] != null
          ? json['camera']['name'] as String?
          : json['camera_name'] as String?,
      employeeName: json['employee'] != null && json['employee']['user'] != null
          ? json['employee']['user']['name'] as String?
          : json['employee_name'] as String?,
    );
  }
}

class ViolationStats {
  final int total;
  final int highSeverity;
  final int underInvestigation;
  final int resolved;

  const ViolationStats({
    this.total = 0,
    this.highSeverity = 0,
    this.underInvestigation = 0,
    this.resolved = 0,
  });

  factory ViolationStats.fromJson(Map<String, dynamic> json) {
    return ViolationStats(
      total: json['total'] as int? ?? 0,
      highSeverity: json['high_severity'] as int? ?? 0,
      underInvestigation: json['under_investigation'] as int? ?? 0,
      resolved: json['resolved'] as int? ?? 0,
    );
  }
}
