import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/app_colors.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/loading_shimmer.dart';
import '../../providers/alerts_provider.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(alertsProvider.notifier).fetch());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final state = ref.watch(alertsProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(alertsProvider.notifier).fetch(),
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
                      const Text("Security Alerts",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                          "Real-time violence detection and security monitoring",
                          style:
                              TextStyle(color: secondaryText, fontSize: 14)),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(alertsProvider.notifier).markAllRead();
                  },
                  icon: const Icon(Icons.notifications_off_outlined, size: 16),
                  label: const Text("Mark All Read", style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Stats
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    value: state.isLoading ? '—' : '${state.stats.active}',
                    label: "Active",
                    icon: Icons.error_outline,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    value: state.isLoading ? '—' : '${state.stats.critical}',
                    label: "Critical",
                    icon: Icons.warning_amber,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StatCard(
                    value:
                        state.isLoading ? '—' : '${state.stats.resolvedToday}',
                    label: "Resolved",
                    icon: Icons.check_circle_outline,
                    color: AppColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Alert list
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: ListShimmer(itemCount: 4),
              )
            else if (state.error != null)
              _errorBanner(state.error!)
            else if (state.alerts.isEmpty)
              _emptyState(secondaryText)
            else
              AnimationLimiter(
                child: Column(
                  children: state.alerts.asMap().entries.map((entry) {
                    final index = entry.key;
                    final alert = entry.value;
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: _alertCard(alert, state, isDark, secondaryText),
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

  Widget _alertCard(dynamic alert, AlertsState state, bool isDark, Color secondaryText) {
    final isActioning = state.actioningId == alert.id;

    return Dismissible(
      key: Key('alert_${alert.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.success,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.check_circle_outline, color: Colors.white),
      ),
      onDismissed: (_) {
        // TODO: Implement actual dismiss/resolve logic
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Title row with severity & status badges
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _severityColor(alert.severity).withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.warning_amber,
                  size: 20,
                  color: _severityColor(alert.severity),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  alert.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Badges
          Row(
            children: [
              _badge(alert.severityDisplay, _severityColor(alert.severity)),
              const SizedBox(width: 8),
              _badge(alert.statusDisplay, _statusColor(alert.status)),
            ],
          ),
          const SizedBox(height: 8),

          // Description
          if (alert.description != null && alert.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                alert.description!,
                style: TextStyle(color: secondaryText, fontSize: 13),
              ),
            ),

          // Meta
          Row(
            children: [
              Icon(Icons.videocam, size: 14, color: secondaryText),
              const SizedBox(width: 4),
              Text(alert.cameraName ?? 'Unknown Camera',
                  style: TextStyle(color: secondaryText, fontSize: 12)),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 14, color: secondaryText),
              const SizedBox(width: 4),
              Expanded(
                child: Text(alert.formattedDate,
                    style: TextStyle(color: secondaryText, fontSize: 12)),
              ),
            ],
          ),

          if (alert.confidence != null) ...[
            const SizedBox(height: 4),
            Text('Confidence: ${alert.confidence}%',
                style: TextStyle(color: secondaryText, fontSize: 12)),
          ],

          // Action buttons (only for active alerts)
          if (alert.isActive) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: isActioning
                      ? null
                      : () => ref
                          .read(alertsProvider.notifier)
                          .resolve(alert.id),
                  icon: const Icon(Icons.check, size: 16),
                  label: Text(isActioning ? "..." : "Resolve",
                      style: const TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.success,
                    side: BorderSide(color: AppColors.success.withAlpha(128)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: isActioning
                      ? null
                      : () => ref
                          .read(alertsProvider.notifier)
                          .dismiss(alert.id),
                  icon: const Icon(Icons.close, size: 16),
                  label: Text(isActioning ? "..." : "Dismiss",
                      style: const TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(color: AppColors.error.withAlpha(128)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
          ],
        ),
       ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        text,
        style:
            TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _errorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withAlpha(80)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(Color secondaryText) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.check_circle_outline,
                size: 48, color: AppColors.success.withAlpha(128)),
            const SizedBox(height: 12),
            Text("No alerts found. System is clear ✓",
                style: TextStyle(color: secondaryText, fontSize: 14)),
          ],
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
      case 'medium':
        return Colors.orange;
      default:
        return Colors.yellow.shade700;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return AppColors.error;
      case 'resolved':
        return AppColors.success;
      case 'dismissed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
