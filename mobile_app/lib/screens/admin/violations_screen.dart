import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../core/app_colors.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/loading_shimmer.dart';
import '../../providers/violations_provider.dart';

class ViolationsScreen extends ConsumerStatefulWidget {
  const ViolationsScreen({super.key});

  @override
  ConsumerState<ViolationsScreen> createState() => _ViolationsScreenState();
}

class _ViolationsScreenState extends ConsumerState<ViolationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(violationsProvider.notifier).fetch();
      ref.read(violationsProvider.notifier).fetchCameras();
    });
  }

  void _exportCsv() {
    final csv = ref.read(violationsProvider.notifier).generateCsv();
    Share.share(csv, subject: 'violation-logs.csv');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final state = ref.watch(violationsProvider);

    return RefreshIndicator(
      onRefresh: () => ref.read(violationsProvider.notifier).fetch(
            cameraId: state.cameraFilter,
          ),
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
                      const Text("Violations",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: state.violations.isEmpty ? null : _exportCsv,
                  icon: const Icon(Icons.download, size: 20),
                  tooltip: "Export CSV",
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Camera filter dropdown
            if (state.cameras.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                      color:
                          isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: state.cameraFilter,
                    hint: const Text("All Cameras"),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text("All Cameras"),
                      ),
                      ...state.cameras.map(
                        (cam) => DropdownMenuItem(
                          value: cam.id.toString(),
                          child: Text(cam.name),
                        ),
                      ),
                    ],
                    onChanged: (v) => ref
                        .read(violationsProvider.notifier)
                        .setCameraFilter(v),
                  ),
                ),
              ),
            const SizedBox(height: 16),

            // Stats
            Row(
              children: [
                Expanded(
                    child: StatCard(
                        value: state.isLoading
                            ? '—'
                            : '${state.stats.total}',
                        label: "Total",
                        icon: Icons.warning,
                        color: AppColors.error)),
                const SizedBox(width: 10),
                Expanded(
                    child: StatCard(
                        value: state.isLoading
                            ? '—'
                            : '${state.stats.highSeverity}',
                        label: "High",
                        icon: Icons.priority_high,
                        color: AppColors.warning)),
                const SizedBox(width: 10),
                Expanded(
                    child: StatCard(
                        value: state.isLoading
                            ? '—'
                            : '${state.stats.resolved}',
                        label: "Resolved",
                        icon: Icons.check,
                        color: AppColors.success)),
              ],
            ),
            const SizedBox(height: 20),

            // Violations list
            if (state.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: ListShimmer(itemCount: 5),
              )
            else if (state.violations.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text("No violations recorded.",
                      style: TextStyle(color: secondaryText, fontSize: 14)),
                ),
              )
            else
              AnimationLimiter(
                child: Column(
                  children: state.violations.asMap().entries.map((entry) {
                    final index = entry.key;
                    final v = entry.value;
                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Dismissible(
                            key: Key('violation_${v.id}'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete_outline, color: Colors.white),
                            ),
                            onDismissed: (_) {
                              // TODO: Implement actual dismiss logic
                            },
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                    color: isDark
                                        ? AppColors.darkBorder
                                        : AppColors.lightBorder),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                      child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning_amber,
                                size: 18,
                                color: _sevColor(v.severity)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(v.type,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15)),
                            ),
                            _badge(v.severityDisplay, _sevColor(v.severity)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.videocam,
                                size: 14, color: secondaryText),
                            const SizedBox(width: 4),
                            Text(v.cameraName ?? '—',
                                style: TextStyle(
                                    color: secondaryText, fontSize: 12)),
                            const SizedBox(width: 16),
                            Icon(Icons.person,
                                size: 14, color: secondaryText),
                            const SizedBox(width: 4),
                            Text(v.employeeName ?? 'Unknown',
                                style: TextStyle(
                                    color: secondaryText, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 14, color: secondaryText),
                            const SizedBox(width: 4),
                            Text(v.formattedDate,
                                style: TextStyle(
                                    color: secondaryText, fontSize: 12)),
                            const Spacer(),
                            _badge(v.statusDisplay,
                                v.status == 'resolved'
                                    ? AppColors.success
                                    : AppColors.info),
                          ],
                        ),
                      ],
                    ),
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

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Color _sevColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      default:
        return Colors.yellow.shade700;
    }
  }
}
