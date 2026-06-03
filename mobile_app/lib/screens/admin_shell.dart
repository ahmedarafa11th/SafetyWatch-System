import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import 'admin/admin_dashboard.dart';
import 'admin/employees_page.dart';
import 'admin/admin_attendance.dart';
import 'admin/violations_screen.dart';
import 'admin/alerts_screen.dart';
import 'admin/camera_management.dart';

class AdminShell extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const AdminShell({super.key, required this.onToggleTheme});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _currentIndex = 0;

  final List<String> _titles = [
    'Dashboard',
    'Employees',
    'Attendance',
    'Violations',
    'Alerts',
    'Cameras',
  ];

  final List<IconData> _icons = [
    Icons.dashboard,
    Icons.people,
    Icons.calendar_today,
    Icons.gavel,
    Icons.warning_amber,
    Icons.videocam,
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pages = [
      const AdminDashboardScreen(),
      const EmployeesPageScreen(),
      const AdminAttendanceScreen(),
      const ViolationsScreenPage(),
      const AlertsScreenPage(),
      const CameraManagementScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("SafetyWatch"),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
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
                child: Text("Welcome, Admin User", style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'logout', child: Text("Logout")),
            ],
            onSelected: (v) {
              if (v == 'logout') Navigator.pushReplacementNamed(context, '/');
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
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.visibility,
                      size: 32,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                    const SizedBox(height: 12),
                    const Text("SafetyWatch", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("Admin Panel", style: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      fontSize: 13,
                    )),
                  ],
                ),
              ),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // Nav items
              ...List.generate(_titles.length, (i) => ListTile(
                leading: Icon(
                  _icons[i],
                  color: _currentIndex == i ? AppColors.primary : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  size: 22,
                ),
                title: Text(
                  _titles[i],
                  style: TextStyle(
                    fontWeight: _currentIndex == i ? FontWeight.w600 : FontWeight.normal,
                    color: _currentIndex == i ? AppColors.primary : null,
                  ),
                ),
                selected: _currentIndex == i,
                selectedTileColor: AppColors.primary.withAlpha(15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                onTap: () {
                  setState(() => _currentIndex = i);
                  Navigator.pop(context);
                },
              )),

              const Spacer(),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error, size: 22),
                title: const Text("Logout", style: TextStyle(color: AppColors.error)),
                onTap: () => Navigator.pushReplacementNamed(context, '/'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      body: IndexedStack(index: _currentIndex, children: pages),
    );
  }
}
