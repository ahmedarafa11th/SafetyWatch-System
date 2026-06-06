import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/loading_shimmer.dart';
import '../../providers/employee_dashboard_provider.dart';
import '../../providers/auth_provider.dart';

class EmployeeDashboardScreen extends ConsumerStatefulWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  ConsumerState<EmployeeDashboardScreen> createState() =>
      _EmployeeDashboardScreenState();
}

class _EmployeeDashboardScreenState
    extends ConsumerState<EmployeeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(employeeDashboardProvider.notifier).fetch());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final state = ref.watch(employeeDashboardProvider);
    final authState = ref.watch(authProvider);

    final userName = authState.user?.name ?? 'Employee';

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(employeeDashboardProvider.notifier).fetch(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with name
            Text("Welcome back, $userName",
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("Track your attendance and work statistics",
                style: TextStyle(color: secondaryText, fontSize: 14)),
            const SizedBox(height: 20),

            // Error
            if (state.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withAlpha(80)),
                ),
                child: Text(state.error!,
                    style: const TextStyle(
                        color: Colors.redAccent, fontSize: 13)),
              ),

            // Stat cards
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    value: state.isLoading
                        ? '—'
                        : '${state.stats.daysPresent}',
                    label: "Days Present",
                    icon: Icons.calendar_today,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    value: state.isLoading
                        ? '—'
                        : '${state.stats.daysAbsent}',
                    label: "Days Absent",
                    icon: Icons.event_busy,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    value: state.isLoading
                        ? '—'
                        : state.stats.totalHours,
                    label: "Total Hours",
                    icon: Icons.access_time,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    value: state.isLoading
                        ? '—'
                        : '${state.attendanceRate}%',
                    label: "Attendance Rate",
                    icon: Icons.trending_up,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Attendance
            _buildSectionCard(
              context,
              title: "Recent Attendance",
              icon: Icons.access_time,
              child: state.isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: ListShimmer(itemCount: 3),
                    )
                  : state.recentRecords.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text("No recent attendance records.",
                              style: TextStyle(
                                  color: secondaryText, fontSize: 14)),
                        )
                      : Column(
                          children: state.recentRecords
                              .map(
                                (record) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(record.date,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.w500,
                                                    fontSize: 14)),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${record.checkInFormatted} → ${record.checkOutFormatted}',
                                              style: TextStyle(
                                                  color: secondaryText,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(record.hoursFormatted,
                                              style: TextStyle(
                                                  color: secondaryText,
                                                  fontSize: 12)),
                                          const SizedBox(height: 4),
                                          StatusBadge(
                                              text: record.statusDisplay),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
            ),
            const SizedBox(height: 16),

            // This Month progress
            _buildSectionCard(
              context,
              title: "This Month",
              icon: Icons.person_outline,
              child: state.isLoading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: ListShimmer(itemCount: 3),
                    )
                  : _buildThisMonth(state, isDark, secondaryText),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Widget child}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon,
                  size: 18,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
      ),
    );
  }

  Widget _buildThisMonth(dynamic state, bool isDark, Color secondaryText) {
    final attendanceRate = state.attendanceRate / 100.0;
    final total = state.stats.daysPresent +
        state.stats.daysLate +
        state.stats.daysAbsent;
    final punctualityRate = total > 0
        ? state.stats.daysPresent / total
        : 0.0;

    return Column(
      children: [
        _progressRow("Attendance", attendanceRate, AppColors.primary),
        const SizedBox(height: 16),
        _progressRow("Punctuality", punctualityRate, AppColors.primary),
        const SizedBox(height: 20),
        Divider(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        const SizedBox(height: 16),
        _infoRow(
            "Total Work Hours", state.stats.totalHours, isDark, secondaryText),
        const SizedBox(height: 16),
        _infoRow("Days Worked", '${state.stats.daysPresent + state.stats.daysLate} days',
            isDark, secondaryText),
      ],
    );
  }

  Widget _progressRow(String label, double value, Color color) {
    final clamped = value.clamp(0.0, 1.0);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            Text("${(clamped * 100).toStringAsFixed(1)}%",
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: clamped,
            minHeight: 8,
            backgroundColor: color.withAlpha(30),
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _infoRow(
      String label, String value, bool isDark, Color secondaryText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label,
            style: TextStyle(color: secondaryText, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
