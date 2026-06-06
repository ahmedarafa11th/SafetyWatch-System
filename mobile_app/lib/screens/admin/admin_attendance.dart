import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/app_colors.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/loading_shimmer.dart';
import '../../providers/attendance_provider.dart';
import 'package:intl/intl.dart';

class AdminAttendanceScreen extends ConsumerStatefulWidget {
  const AdminAttendanceScreen({super.key});

  @override
  ConsumerState<AdminAttendanceScreen> createState() =>
      _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState
    extends ConsumerState<AdminAttendanceScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(adminAttendanceProvider.notifier).fetch());
  }

  void _showMonthPicker() {
    final state = ref.read(adminAttendanceProvider);
    String tempMonth = state.filterMonth ?? '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text("Select Month"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(
                  labelText: "Month (YYYY-MM)",
                  hintText: "e.g. 2026-06",
                ),
                controller: TextEditingController(text: tempMonth),
                onChanged: (v) => tempMonth = v,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                ref.read(adminAttendanceProvider.notifier).clearFilter();
                Navigator.pop(ctx);
              },
              child: const Text("Clear"),
            ),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(adminAttendanceProvider.notifier)
                    .setFilter(tempMonth);
                Navigator.pop(ctx);
              },
              child: const Text("Apply"),
            ),
          ],
        ),
      ),
    );
  }

  void _exportCsv() {
    final csv = ref
        .read(adminAttendanceProvider.notifier)
        .generateCsv(includeEmployeeName: true);
    Share.share(csv, subject: 'attendance-admin-logs.csv');
  }

  String _formatMonthBtn(String? val) {
    if (val == null || val.isEmpty) return 'Filter by Month';
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
    final state = ref.watch(adminAttendanceProvider);

    return RefreshIndicator(
      onRefresh: () => ref
          .read(adminAttendanceProvider.notifier)
          .fetch(month: state.filterMonth),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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
                      const Text("Attendance",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("Monitor company-wide attendance",
                          style:
                              TextStyle(color: secondaryText, fontSize: 14)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: state.records.isEmpty ? null : _exportCsv,
                  icon: const Icon(Icons.download, size: 20),
                  tooltip: "Export CSV",
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Filter button
            InkWell(
              onTap: _showMonthPicker,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                      color:
                          isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      _formatMonthBtn(state.filterMonth),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Stats
            Row(
              children: [
                Expanded(
                    child: StatCard(
                        value: '${state.stats.daysPresent}',
                        label: "Present",
                        icon: Icons.check_circle_outline,
                        color: AppColors.success)),
                const SizedBox(width: 10),
                Expanded(
                    child: StatCard(
                        value: '${state.stats.daysLate}',
                        label: "Late",
                        icon: Icons.schedule,
                        color: AppColors.warning)),
                const SizedBox(width: 10),
                Expanded(
                    child: StatCard(
                        value: '${state.stats.daysAbsent}',
                        label: "Absent",
                        icon: Icons.cancel_outlined,
                        color: AppColors.error)),
              ],
            ),
            const SizedBox(height: 20),

            // Records list
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: ListShimmer(itemCount: 6),
              )
            else if (state.records.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text("No attendance records found.",
                      style: TextStyle(color: secondaryText, fontSize: 14)),
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
                              Text(
                                record.employeeName ?? '—',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                record.date.isNotEmpty 
                                  ? DateFormat('MMM dd, yyyy').format(DateTime.tryParse(record.date) ?? DateTime.now())
                                  : '—',
                                style: TextStyle(
                                    color: secondaryText, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${record.checkInFormatted} → ${record.checkOutFormatted}',
                              style: TextStyle(
                                  color: secondaryText, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(record.hoursFormatted,
                                    style: TextStyle(
                                        color: secondaryText, fontSize: 12)),
                                const SizedBox(width: 8),
                                StatusBadge(text: record.statusDisplay),
                              ],
                            ),
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
          ],
        ),
      ),
    );
  }
}
