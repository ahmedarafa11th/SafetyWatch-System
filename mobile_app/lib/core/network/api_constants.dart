class ApiConstants {
  static const String baseUrl = 'https://api.safetywatch.example.com'; // TODO: Update with real baseUrl

  // Auth
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String logout = '/api/auth/logout';
  static const String me = '/api/auth/me';

  // Admin
  static const String adminDashboard = '/api/admin/dashboard';
  
  // Employees
  static const String employees = '/api/admin/employees'; // GET, POST
  static String employeeDetails(String id) => '/api/admin/employees/$id'; // GET, PUT, DELETE

  // Attendance
  static const String attendance = '/api/admin/attendance'; // GET, POST
  static const String attendanceStats = '/api/admin/attendance/stats';

  // Violations
  static const String violations = '/api/admin/violations';
  static String resolveViolation(String id) => '/api/admin/violations/$id/resolve';
  static String dismissViolation(String id) => '/api/admin/violations/$id/dismiss';
  static String updateViolationStatus(String id) => '/api/admin/violations/$id/status';

  // Alerts
  static const String alerts = '/api/admin/alerts';
  static const String markAllAlertsRead = '/api/admin/alerts/mark-all-read';
  static String resolveAlert(String id) => '/api/admin/alerts/$id/resolve';
  static String dismissAlert(String id) => '/api/admin/alerts/$id/dismiss';

  // Cameras
  static const String cameras = '/api/admin/cameras';
  static String cameraDetails(String id) => '/api/admin/cameras/$id';
  static String toggleCameraStatus(String id) => '/api/admin/cameras/$id/toggle-status';

  // Employee App
  static const String employeeDashboard = '/api/employee/dashboard';
  static const String employeeAttendance = '/api/employee/attendance';

  // AI Webhook
  static const String aiDetection = '/api/ai/detection';
}
