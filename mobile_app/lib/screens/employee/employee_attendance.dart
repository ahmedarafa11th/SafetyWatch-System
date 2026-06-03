import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';

class EmployeeAttendanceScreen extends StatefulWidget {
  const EmployeeAttendanceScreen({super.key});

  @override
  State<EmployeeAttendanceScreen> createState() => _EmployeeAttendanceScreenState();
}

class _EmployeeAttendanceScreenState extends State<EmployeeAttendanceScreen> {
  String? selectedMonth;

  final List<Map<String, String>> rows = [
    {'date': '2026-02-01', 'checkIn': '08:45 AM', 'checkOut': '05:30 PM', 'hours': '8.75h', 'status': 'Present'},
    {'date': '2026-01-31', 'checkIn': '08:50 AM', 'checkOut': '05:25 PM', 'hours': '8.58h', 'status': 'Present'},
    {'date': '2026-01-30', 'checkIn': '08:35 AM', 'checkOut': '05:40 PM', 'hours': '9.08h', 'status': 'Present'},
    {'date': '2026-01-29', 'checkIn': '08:55 AM', 'checkOut': '05:35 PM', 'hours': '8.67h', 'status': 'Present'},
    {'date': '2026-01-28', 'checkIn': '09:10 AM', 'checkOut': '05:45 PM', 'hours': '8.58h', 'status': 'Late'},
    {'date': '2026-01-27', 'checkIn': '08:40 AM', 'checkOut': '05:20 PM', 'hours': '8.67h', 'status': 'Present'},
    {'date': '2026-01-26', 'checkIn': '08:30 AM', 'checkOut': '05:15 PM', 'hours': '8.75h', 'status': 'Present'},
    {'date': '2026-01-25', 'checkIn': '-', 'checkOut': '-', 'hours': '0h', 'status': 'Absent'},
    {'date': '2026-01-24', 'checkIn': '08:45 AM', 'checkOut': '05:30 PM', 'hours': '8.75h', 'status': 'Present'},
    {'date': '2026-01-23', 'checkIn': '08:55 AM', 'checkOut': '05:40 PM', 'hours': '8.75h', 'status': 'Present'},
    {'date': '2026-01-22', 'checkIn': '08:25 AM', 'checkOut': '05:10 PM', 'hours': '8.75h', 'status': 'Present'},
    {'date': '2026-01-21', 'checkIn': '09:05 AM', 'checkOut': '05:50 PM', 'hours': '8.75h', 'status': 'Late'},
  ];

  Future<void> pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      helpText: 'Select Month',
    );
    if (picked != null) {
      setState(() {
        selectedMonth = '${picked.year}-${picked.month.toString().padLeft(2, '0')}';
      });
    }
  }

  List<Map<String, String>> get filteredRows {
    if (selectedMonth == null) return rows;
    return rows.where((r) => r['date']!.startsWith(selectedMonth!)).toList();
  }

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
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("My Attendance Logs", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text("View your complete attendance history", style: TextStyle(color: secondaryText, fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: pickMonth,
                  icon: const Icon(Icons.calendar_month, size: 18),
                  label: Text(selectedMonth ?? 'Filter by Date', style: const TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Export feature coming soon')),
                  );
                },
                icon: const Icon(Icons.download, size: 18),
                label: const Text("Export", style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Stats
          Row(
            children: [
              Expanded(child: StatCard(value: "9", label: "Days Present", icon: Icons.calendar_today, color: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(value: "2", label: "Days Late", icon: Icons.schedule, color: AppColors.warning)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: StatCard(value: "1", label: "Days Absent", icon: Icons.event_busy, color: AppColors.error)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(value: "96.1h", label: "Total Hours", icon: Icons.access_time, color: AppColors.success)),
            ],
          ),
          const SizedBox(height: 24),

          // Table
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowHeight: 48,
                dataRowMinHeight: 52,
                dataRowMaxHeight: 52,
                columnSpacing: 20,
                horizontalMargin: 16,
                headingTextStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: secondaryText,
                  letterSpacing: 0.5,
                ),
                dataTextStyle: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
                columns: const [
                  DataColumn(label: Text("DATE")),
                  DataColumn(label: Text("CHECK IN")),
                  DataColumn(label: Text("CHECK OUT")),
                  DataColumn(label: Text("TOTAL HOURS")),
                  DataColumn(label: Text("STATUS")),
                ],
                rows: filteredRows.map((row) => DataRow(
                  cells: [
                    DataCell(Text(row['date']!)),
                    DataCell(Text(row['checkIn']!)),
                    DataCell(Text(row['checkOut']!)),
                    DataCell(Text(row['hours']!)),
                    DataCell(StatusBadge(text: row['status']!)),
                  ],
                )).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
