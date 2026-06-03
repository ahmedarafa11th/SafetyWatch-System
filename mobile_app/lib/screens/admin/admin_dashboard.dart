import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Admin Dashboard", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("Overview of your workplace safety system", style: TextStyle(color: secondaryText, fontSize: 14)),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(child: StatCard(value: "145", label: "Total Employees", icon: Icons.people, color: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(value: "128", label: "Present Today", icon: Icons.check_circle_outline, color: AppColors.success)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: StatCard(value: "12", label: "Active Cameras", icon: Icons.videocam, color: AppColors.info)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(value: "3", label: "Security Alerts", icon: Icons.warning_amber, color: AppColors.error)),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Attendance
          _section(context, "Recent Attendance", Icons.access_time, _attendanceList(isDark, secondaryText)),
          const SizedBox(height: 16),
          // Recent Alerts
          _section(context, "Recent Alerts", Icons.warning_amber, _alertsList(isDark, secondaryText)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, IconData icon, Widget child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 18, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _attendanceList(bool isDark, Color secondaryText) {
    final data = [
      {"name": "Ahmed Hassan", "time": "08:45 AM", "status": "Present"},
      {"name": "Sara Mohamed", "time": "08:52 AM", "status": "Present"},
      {"name": "Omar Ali", "time": "09:15 AM", "status": "Late"},
      {"name": "Fatima Ibrahim", "time": "08:30 AM", "status": "Present"},
    ];
    return Column(
      children: data.map((d) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d["name"]!, style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(d["time"]!, style: TextStyle(color: secondaryText, fontSize: 12)),
                ],
              ),
            ),
            StatusBadge(text: d["status"]!),
          ],
        ),
      )).toList(),
    );
  }

  Widget _alertsList(bool isDark, Color secondaryText) {
    final data = [
      {"title": "Violence Detected", "sub": "Camera 3 - Warehouse • 2 hours ago", "status": "Critical"},
      {"title": "Unusual Activity", "sub": "Camera 7 - Parking • 5 hours ago", "status": "High"},
      {"title": "Camera Offline", "sub": "Camera 5 - Lobby • 1 day ago", "status": "Warning"},
    ];
    return Column(
      children: data.map((d) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                color: d["status"] == "Critical" ? AppColors.error : (d["status"] == "High" ? AppColors.warning : Colors.yellow),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d["title"]!, style: const TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(d["sub"]!, style: TextStyle(color: secondaryText, fontSize: 12)),
                ],
              ),
            ),
            StatusBadge(text: d["status"]!),
          ],
        ),
      )).toList(),
    );
  }
}
