class AttendanceRecord {
  final int? id;
  final String date;
  final String? checkIn;
  final String? checkOut;
  final String? totalHours;
  final String status; // 'present', 'late', 'absent'
  final String? employeeName; // For admin view

  const AttendanceRecord({
    this.id,
    required this.date,
    this.checkIn,
    this.checkOut,
    this.totalHours,
    required this.status,
    this.employeeName,
  });

  String get checkInFormatted => _formatTime(checkIn);
  String get checkOutFormatted => _formatTime(checkOut);
  String get hoursFormatted => totalHours != null ? '${totalHours}h' : '0h';

  String get statusDisplay =>
      status[0].toUpperCase() + status.substring(1);

  static String _formatTime(String? t) {
    if (t == null || t.isEmpty) return '—';
    try {
      final parts = t.split(':');
      final hr = int.parse(parts[0]);
      final min = parts[1];
      final period = hr < 12 ? 'AM' : 'PM';
      final hour12 = hr % 12 == 0 ? 12 : hr % 12;
      return '$hour12:$min $period';
    } catch (_) {
      return t;
    }
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    // Handle both admin (with nested employee) and employee views
    String? empName;
    if (json['employee'] != null && json['employee']['user'] != null) {
      empName = json['employee']['user']['name'] as String?;
    } else {
      empName = json['employee_name'] as String?;
    }

    return AttendanceRecord(
      id: json['id'] as int?,
      date: json['date'] as String? ?? '',
      checkIn: json['check_in'] as String?,
      checkOut: json['check_out'] as String?,
      totalHours: json['total_hours']?.toString(),
      status: json['status'] as String? ?? 'present',
      employeeName: empName,
    );
  }
}

class AttendanceStats {
  final int daysPresent;
  final int daysLate;
  final int daysAbsent;
  final String totalHours;
  final int attendanceRate;

  const AttendanceStats({
    this.daysPresent = 0,
    this.daysLate = 0,
    this.daysAbsent = 0,
    this.totalHours = '0h',
    this.attendanceRate = 0,
  });

  factory AttendanceStats.fromJson(Map<String, dynamic> json) {
    return AttendanceStats(
      daysPresent: json['days_present'] as int? ?? json['present'] as int? ?? 0,
      daysLate: json['days_late'] as int? ?? json['late'] as int? ?? 0,
      daysAbsent: json['days_absent'] as int? ?? json['absent'] as int? ?? 0,
      totalHours: json['total_hours']?.toString() ?? '0h',
      attendanceRate: (json['attendance_rate'] as num?)?.toInt() ?? 0,
    );
  }
}
