import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../providers/auth_provider.dart';
import 'employee/employee_dashboard.dart';
import 'employee/employee_attendance.dart';
import '../widgets/logo_widget.dart';

class EmployeeShell extends ConsumerStatefulWidget {
  final VoidCallback onToggleTheme;
  const EmployeeShell({super.key, required this.onToggleTheme});

  @override
  ConsumerState<EmployeeShell> createState() => _EmployeeShellState();
}

class _EmployeeShellState extends ConsumerState<EmployeeShell> {
  int _currentIndex = 0;

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, 'login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final userName = authState.user?.name ?? 'Employee';

    final pages = [
      const EmployeeDashboardScreen(),
      const EmployeeAttendanceScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const LogoWidget(size: 24, fontSize: 18),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon:
                Icon(isDark ? Icons.light_mode : Icons.dark_mode, size: 20),
            onPressed: widget.onToggleTheme,
          ),
          PopupMenuButton<String>(
            offset: const Offset(0, 45),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: const [
                    Icon(Icons.logout, size: 18, color: Colors.redAccent),
                    SizedBox(width: 12),
                    Text("Logout", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
            onSelected: (v) {
              if (v == 'logout') _logout();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CircleAvatar(
                radius: 15,
                backgroundColor: AppColors.primary.withAlpha(30),
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'E',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ),
            ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        child: pages[_currentIndex],
      ),
      // M3 NavigationBar (replacing legacy BottomNavigationBar)
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) {
          HapticFeedback.lightImpact();
          setState(() => _currentIndex = i);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Attendance',
          ),
        ],
      ),
    );
  }
}
