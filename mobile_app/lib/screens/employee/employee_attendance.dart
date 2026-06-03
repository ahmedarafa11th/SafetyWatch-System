import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/app_colors.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/loading_shimmer.dart';
import '../../providers/attendance_provider.dart';

class EmployeeAttendanceScreen extends ConsumerStatefulWidget {
  const EmployeeAttendanceScreen({super.key});

  @override
  ConsumerState<EmployeeAttendanceScreen> createState() =>
      _EmployeeAttendanceScreenState();
}

class _EmployeeAttendanceScreenState
    extends ConsumerState<EmployeeAttendanceScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(employeeAttendanceProvider.notifier).fetch());
  }

  void _showMonthPicker() {
    final state = ref.read(employeeAttendanceProvider);
    String tempMonth = state.filterMonth ?? '';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Filter by Month"),
        content: TextField(
          decoration: const InputDecoration(
            labelText: "Month (YYYY-MM)",
            hintText: "e.g. 2026-06",
          ),
          controller: TextEditingController(text: tempMonth),
          onChanged: (v) => tempMonth = v,
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(employeeAttendanceProvider.notifier).clearFilter();
              Navigator.pop(ctx);
            },
            child: const Text("Clear"),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(employeeAttendanceProvider.notifier)
                  .setFilter(tempMonth);
              Navigator.pop(ctx);
            },
            child: const Text("Apply"),
          ),
        ],
      ),
    );
  }

  void _exportCsv() {
    final csv = ref
        .read(employeeAttendanceProvider.notifier)
        .generateCsv(includeEmployeeName: false);
    Share.share(csv, subject: 'my-attendance-logs.csv');
  }

  String _formatMonthLabel(String? val) {
    if (val == null || val.isEmpty) return 'Filter by Date';
    try {
      final parts = val.split('-');
      final months = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
      ];
      return '${months[int.parse(parts[1]) - 1]} ${parts[0]}';
    } catch (_) {
      return val;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final state = ref.watch(employeeAttendanceProvider);

    return RefreshIndicator(
      onRefresh: () => ref
          .read(employeeAttendanceProvider.notifier)
          .fetch(month: state.filterMonth),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text("My Attendance Logs",
                style:
                    TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("View your complete attendance history",
                style: TextStyle(color: secondaryText, fontSize: 14)),
            const SizedBox(height: 16),

            // Filter + Export buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showMonthPicker,
                    icon: const Icon(Icons.calendar_month, size: 18),
                    label: Text(
                      _formatMonthLabel(state.filterMonth),
                      style: const TextStyle(fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      side: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: state.records.isEmpty ? null : _exportCsv,
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text("Export",
                      style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Stats
            Row(
              children: [
                Expanded(
                    child: StatCard(
                        value: '${state.stats.daysPresent}',
                        label: "Days Present",
                        icon: Icons.calendar_today,
                        color: AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(
                    child: StatCard(
                        value: '${state.stats.daysLate}',
                        label: "Days Late",
                        icon: Icons.schedule,
                        color: AppColors.warning)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: StatCard(
                        value: '${state.stats.daysAbsent}',
                        label: "Days Absent",
                        icon: Icons.event_busy,
                        color: AppColors.error)),
                const SizedBox(width: 12),
                Expanded(
                    child: StatCard(
                        value: state.stats.totalHours,
                        label: "Total Hours",
                        icon: Icons.access_time,
                        color: AppColors.success)),
              ],
            ),
            const SizedBox(height: 24),

            // Records list (card-based, replacing DataTable)
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: ListShimmer(itemCount: 5),
              )
            else if (state.records.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text("No attendance records found.",
                      style:
                          TextStyle(color: secondaryText, fontSize: 14)),
                ),
              )
            else
              AnimationLimiter(
                child: Column(
                  children: state.records.asMap().entries.map((entry) {
                    final index = entry.key;
                    final record = entry.value;
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(record.date,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                              const SizedBox(height: 4),
                              Text(
                                '${record.checkInFormatted} → ${record.checkOutFormatted}',
                                style: TextStyle(
                                    color: secondaryText, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(record.hoursFormatted,
                                style: TextStyle(
                                    color: secondaryText, fontSize: 12)),
                            const SizedBox(height: 4),
                            StatusBadge(text: record.statusDisplay),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
               ),
              ),
             );
            }).toList(),
            ),
          ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
