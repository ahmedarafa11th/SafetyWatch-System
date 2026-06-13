import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_colors.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/loading_shimmer.dart';
import '../../providers/dashboard_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch dashboard data on first load
    Future.microtask(() => ref.read(dashboardProvider.notifier).fetch());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final state = ref.watch(dashboardProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(dashboardProvider.notifier).fetch(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Admin Dashboard",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            // Error banner
            if (state.error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withAlpha(80)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.redAccent, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.error!,
                        style: const TextStyle(
                            color: Colors.redAccent, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            // Stat cards
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    value: state.isLoading
                        ? '—'
                        : '${state.stats.totalEmployees}',
                    label: "Total Employees",
                    icon: Icons.people,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    value: state.isLoading
                        ? '—'
                        : '${state.stats.presentToday}',
                    label: "Present Today",
                    icon: Icons.check_circle_outline,
                    color: AppColors.success,
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
                        : '${state.stats.activeCameras}',
                    label: "Active Cameras",
                    icon: Icons.videocam,
                    color: AppColors.info,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    value: state.isLoading
                        ? '—'
                        : '${state.stats.activeAlerts}',
                    label: "Security Alerts",
                    icon: Icons.warning_amber,
                    color: state.stats.activeAlerts > 0
                        ? AppColors.error
                        : AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Attendance
            _section(
              context,
              "Recent Attendance",
              Icons.access_time,
              state.isLoading
                  ? _loadingWidget()
                  : state.recentAttendance.isEmpty
                      ? _emptyWidget("No attendance records for today.")
                      : Column(
                          children: state.recentAttendance
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
                                            Text(
                                              record.employeeName ?? '—',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              record.checkInFormatted,
                                              style: TextStyle(
                                                  color: secondaryText,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                      StatusBadge(
                                          text: record.statusDisplay),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
            ),
            const SizedBox(height: 16),

            // Recent Alerts
            _section(
              context,
              "Recent Alerts",
              Icons.warning_amber,
              state.isLoading
                  ? _loadingWidget()
                  : state.recentAlerts.isEmpty
                      ? _emptyWidget("No active alerts. System is clear")
                      : Column(
                          children: state.recentAlerts
                              .map(
                                (alert) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: _severityColor(alert.severity),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              alert.title,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${alert.cameraName ?? 'Unknown Camera'} • ${alert.formattedDate}',
                                              style: TextStyle(
                                                  color: secondaryText,
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                      StatusBadge(
                                          text: alert.severityDisplay),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _section(
      BuildContext context, String title, IconData icon, Widget child) {
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
          Row(children: [
            Icon(icon,
                size: 18,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary),
            const SizedBox(width: 8),
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 16),
          child,
        ],
      ),
      ),
    );
  }

  Widget _loadingWidget() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: ListShimmer(itemCount: 3),
    );
  }

  Widget _emptyWidget(String message) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'critical':
        return AppColors.error;
      case 'high':
        return AppColors.warning;
      default:
        return Colors.yellow;
    }
  }
}
