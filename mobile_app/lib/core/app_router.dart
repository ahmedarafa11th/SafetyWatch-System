import 'package:flutter/material.dart';

import '../login_screen.dart';
import '../Signup Screen.dart';
import '../Admin Dashboard Page.dart';
import '../employee_dashboard.dart';
import '../Alerts Screen.dart';
import '../Violations Screen.dart';
import '../Attendance Logs Page.dart';
import '../Attendance Logs Page_admin.dart';
import '../Camera Management Page.dart';
import '../Employees Page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(
    RouteSettings settings,
    VoidCallback toggleTheme,
  ) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => LoginScreen(onToggleTheme: toggleTheme),
        );

      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      case '/admin':
        return MaterialPageRoute(
          builder: (_) => const AdminDashboardPage(),
        );

      case '/employee':
        return MaterialPageRoute(
          builder: (_) => const EmployeeDashboard(),
        );

      case '/alerts':
        return MaterialPageRoute(builder: (_) => AlertsScreen());

      case '/violations':
        return MaterialPageRoute(builder: (_) => ViolationsScreen());

      case '/attendance':
        return MaterialPageRoute(
          builder: (_) => const AttendanceLogsPage(),
        );

      case '/attendance-admin':
        return MaterialPageRoute(
          builder: (_) => const AttendancePage(),
        );

      case '/cameras':
        return MaterialPageRoute(
          builder: (_) => const CameraManagementPage(),
        );

      case '/employees':
        return MaterialPageRoute(
          builder: (_) => const EmployeesPage(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text("Page not found"))),
        );
    }
  }
}
