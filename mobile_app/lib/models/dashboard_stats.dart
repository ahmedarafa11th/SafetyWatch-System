class DashboardStats {
  final int totalEmployees;
  final int presentToday;
  final int activeCameras;
  final int activeAlerts;
  final int attendanceRate;

  const DashboardStats({
    this.totalEmployees = 0,
    this.presentToday = 0,
    this.activeCameras = 0,
    this.activeAlerts = 0,
    this.attendanceRate = 0,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalEmployees: _toInt(json['total_employees']),
      presentToday: _toInt(json['present_today']),
      activeCameras: _toInt(json['active_cameras']),
      activeAlerts: _toInt(json['active_alerts']),
      attendanceRate: _toInt(json['attendance_rate']),
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }
}
