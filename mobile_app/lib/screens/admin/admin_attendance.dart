import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';

class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({super.key});

  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {
  String? selectedMonth;

  final List<Map<String, String>> rows = [
    {'name': 'Ahmed Hassan', 'date': '2026-02-01', 'checkIn': '08:45 AM', 'checkOut': '05:30 PM', 'hours': '8.75h', 'status': 'Present'},
    {'name': 'Sara Mohamed', 'date': '2026-02-01', 'checkIn': '08:52 AM', 'checkOut': '05:45 PM', 'hours': '8.88h', 'status': 'Present'},
    {'name': 'Omar Ali', 'date': '2026-02-01', 'checkIn': '09:15 AM', 'checkOut': '06:00 PM', 'hours': '8.75h', 'status': 'Late'},
    {'name': 'Fatima Ibrahim', 'date': '2026-02-01', 'checkIn': '08:30 AM', 'checkOut': '05:15 PM', 'hours': '8.75h', 'status': 'Present'},
    {'name': 'Mohamed Khaled', 'date': '2026-02-01', 'checkIn': '08:00 AM', 'checkOut': '04:30 PM', 'hours': '8.5h', 'status': 'Present'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Attendance Logs", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("Monitor employee attendance records", style: TextStyle(color: secondaryText, fontSize: 14)),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2024), lastDate: DateTime(2030));
                    if (picked != null) setState(() => selectedMonth = '${picked.year}-${picked.month.toString().padLeft(2, '0')}');
                  },
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
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export feature coming soon'))),
                icon: const Icon(Icons.download, size: 18),
                label: const Text("Export", style: TextStyle(fontSize: 13)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(child: StatCard(value: "128", label: "Present Today", icon: Icons.check_circle_outline, color: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(value: "12", label: "Late Today", icon: Icons.schedule, color: AppColors.warning)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: StatCard(value: "5", label: "Absent Today", icon: Icons.event_busy, color: AppColors.error)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(value: "88.3%", label: "Attendance Rate", icon: Icons.trending_up, color: AppColors.success)),
            ],
          ),
          const SizedBox(height: 24),

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
                headingTextStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: secondaryText, letterSpacing: 0.5),
                dataTextStyle: TextStyle(fontSize: 13, color: isDark ? Colors.white : AppColors.lightTextPrimary),
                columns: const [
                  DataColumn(label: Text("NAME")),
                  DataColumn(label: Text("DATE")),
                  DataColumn(label: Text("CHECK IN")),
                  DataColumn(label: Text("CHECK OUT")),
                  DataColumn(label: Text("HOURS")),
                  DataColumn(label: Text("STATUS")),
                ],
                rows: rows.map((r) => DataRow(cells: [
                  DataCell(Text(r['name']!, style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(Text(r['date']!)),
                  DataCell(Text(r['checkIn']!)),
                  DataCell(Text(r['checkOut']!)),
                  DataCell(Text(r['hours']!)),
                  DataCell(StatusBadge(text: r['status']!)),
                ])).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
