import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'employee/employee_dashboard.dart';
import 'employee/employee_attendance.dart';

class EmployeeShell extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const EmployeeShell({super.key, required this.onToggleTheme});

  @override
  State<EmployeeShell> createState() => _EmployeeShellState();
}

class _EmployeeShellState extends State<EmployeeShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pages = [
      const EmployeeDashboardScreen(),
      const EmployeeAttendanceScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Row(
            children: [
              Icon(Icons.visibility, size: 22,
                  color: isDark ? Colors.white : const Color(0xFF1E293B)),
            ],
          ),
        ),
        title: const Text("SafetyWatch"),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, size: 20),
            onPressed: widget.onToggleTheme,
          ),
          PopupMenuButton<String>(
            offset: const Offset(0, 45),
            itemBuilder: (_) => [
              const PopupMenuItem(
                enabled: false,
                child: Text("Welcome, John Employee",
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'logout', child: Text("Logout")),
            ],
            onSelected: (v) {
              if (v == 'logout') {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primary.withAlpha(30),
                    child: const Icon(Icons.person, size: 16, color: AppColors.primary),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_drop_down, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Attendance'),
        ],
      ),
    );
  }
}
