class ApiConstants {
  // Default base URL — override at app startup via setBaseUrl()
  // For Android emulator: 'http://10.0.2.2:8000'
  // For physical device on same network: 'http://192.168.x.x:8000'
  static String _baseUrl = 'http://192.168.1.4:8000';

  static String get baseUrl => _baseUrl;

  /// Call this at app startup to override the default base URL.
  static void setBaseUrl(String url) {
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  // Auth
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String logout = '/api/auth/logout';
  static const String me = '/api/auth/me';

  // Admin
  static const String adminDashboard = '/api/admin/dashboard';

  // Employees
  static const String employees = '/api/admin/employees'; // GET, POST
  static String employeeDetails(String id) =>
      '/api/admin/employees/$id'; // GET, PUT, DELETE

  // Attendance
  static const String attendance = '/api/admin/attendance'; // GET, POST
  static const String attendanceStats = '/api/admin/attendance/stats';

  // Violations
  static const String violations = '/api/admin/violations';
  static String resolveViolation(String id) =>
      '/api/admin/violations/$id/resolve';
  static String dismissViolation(String id) =>
      '/api/admin/violations/$id/dismiss';
  static String updateViolationStatus(String id) =>
      '/api/admin/violations/$id/status';

  // Alerts
  static const String alerts = '/api/admin/alerts';
  static const String markAllAlertsRead = '/api/admin/alerts/mark-all-read';
  static String resolveAlert(String id) => '/api/admin/alerts/$id/resolve';
  static String dismissAlert(String id) => '/api/admin/alerts/$id/dismiss';

  // Cameras
  static const String cameras = '/api/admin/cameras';
  static String cameraDetails(String id) => '/api/admin/cameras/$id';
  static String toggleCameraStatus(String id) =>
      '/api/admin/cameras/$id/toggle-status';

  // Employee App
  static const String employeeDashboard = '/api/employee/dashboard';
  static const String employeeAttendance = '/api/employee/attendance';

  // AI Webhook
  static const String aiDetection = '/api/ai/detection';
}
