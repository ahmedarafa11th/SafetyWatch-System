import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';

class EmployeeDashboardScreen extends StatelessWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text("My Dashboard", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("Track your attendance and work statistics", style: TextStyle(color: secondaryText, fontSize: 14)),
          const SizedBox(height: 20),

          // Stat cards - 2x2 grid
          Row(
            children: [
              Expanded(child: StatCard(value: "22", label: "Days Present", icon: Icons.calendar_today, color: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(value: "1", label: "Days Absent", icon: Icons.event_busy, color: AppColors.error)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: StatCard(value: "8.5", label: "Average Hours", icon: Icons.access_time, color: AppColors.info)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(value: "95.6%", label: "Attendance Rate", icon: Icons.trending_up, color: AppColors.success)),
            ],
          ),
          const SizedBox(height: 24),

          // Recent Attendance
          _buildSectionCard(
            context,
            title: "Recent Attendance",
            icon: Icons.access_time,
            child: _buildAttendanceTable(isDark, secondaryText),
          ),
          const SizedBox(height: 16),

          // This Month
          _buildSectionCard(
            context,
            title: "This Month",
            icon: Icons.person_outline,
            child: _buildThisMonth(isDark, secondaryText),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, {required String title, required IconData icon, required Widget child}) {
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
          Row(
            children: [
              Icon(icon, size: 18, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildAttendanceTable(bool isDark, Color secondaryText) {
    final headers = ["DATE", "CHECK IN", "CHECK OUT", "HOURS", "STATUS"];
    final data = [
      ["2026-02-01", "08:45 AM", "05:30 PM", "8.75h", "Present"],
      ["2026-01-31", "08:50 AM", "05:25 PM", "8.58h", "Present"],
      ["2026-01-30", "08:35 AM", "05:40 PM", "9.08h", "Present"],
      ["2026-01-29", "08:55 AM", "05:35 PM", "8.67h", "Present"],
      ["2026-01-28", "09:10 AM", "05:45 PM", "8.58h", "Late"],
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 40,
        dataRowMinHeight: 44,
        dataRowMaxHeight: 44,
        columnSpacing: 24,
        headingTextStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: secondaryText, letterSpacing: 0.5),
        dataTextStyle: TextStyle(fontSize: 13, color: isDark ? Colors.white : AppColors.lightTextPrimary),
        columns: headers.map((h) => DataColumn(label: Text(h))).toList(),
        rows: data.map((row) => DataRow(
          cells: [
            DataCell(Text(row[0])),
            DataCell(Text(row[1])),
            DataCell(Text(row[2])),
            DataCell(Text(row[3])),
            DataCell(StatusBadge(text: row[4])),
          ],
        )).toList(),
      ),
    );
  }

  Widget _buildThisMonth(bool isDark, Color secondaryText) {
    return Column(
      children: [
        _progressRow("Attendance", 0.956, AppColors.primary),
        const SizedBox(height: 16),
        _progressRow("Punctuality", 0.783, AppColors.primary),
        const SizedBox(height: 20),
        Divider(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        const SizedBox(height: 16),
        _infoRow("Total Work Hours", "186.5h", isDark, secondaryText),
        const SizedBox(height: 16),
        _infoRow("Days Worked", "22 days", isDark, secondaryText),
      ],
    );
  }

  Widget _progressRow(String label, double value, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            Text("${(value * 100).toStringAsFixed(1)}%", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: color.withAlpha(30),
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value, bool isDark, Color secondaryText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: secondaryText, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
