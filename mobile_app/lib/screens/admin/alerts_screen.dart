import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/status_badge.dart';

class AlertsScreenPage extends StatelessWidget {
  const AlertsScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final alerts = [
      {"title": "Violence Detected", "desc": "Aggressive behavior detected in warehouse area", "camera": "Camera 3 - Warehouse", "time": "2026-02-01 14:35", "confidence": "92%", "status": "Critical"},
      {"title": "Suspicious Activity", "desc": "Person near restricted area", "camera": "Camera 8 - Server Room", "time": "2026-02-01 11:20", "confidence": "85%", "status": "High"},
      {"title": "Unusual Movement", "desc": "Rapid movement detected in parking", "camera": "Camera 7 - Parking", "time": "2026-01-31 09:45", "confidence": "78%", "status": "Medium"},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Security Alerts", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                ],
              )),
              TextButton(onPressed: () {}, child: const Text("Mark All Read")),
            ],
          ),
          Text("Monitor and respond to security events", style: TextStyle(color: secondaryText, fontSize: 14)),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(child: StatCard(value: "2", label: "Active", icon: Icons.error_outline, color: AppColors.error)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(value: "1", label: "Critical", icon: Icons.warning_amber, color: AppColors.warning)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: StatCard(value: "2", label: "Resolved", icon: Icons.check_circle_outline, color: AppColors.success)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(value: "90%", label: "Confidence", icon: Icons.analytics, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 24),

          ...alerts.map((a) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
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
                    Expanded(child: Text(a["title"]!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                    StatusBadge(text: a["status"]!),
                  ],
                ),
                const SizedBox(height: 8),
                Text(a["desc"]!, style: TextStyle(color: secondaryText, fontSize: 13)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.videocam, size: 14, color: secondaryText),
                      const SizedBox(width: 4),
                      Text(a["camera"]!, style: TextStyle(color: secondaryText, fontSize: 12)),
                    ]),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.access_time, size: 14, color: secondaryText),
                      const SizedBox(width: 4),
                      Text(a["time"]!, style: TextStyle(color: secondaryText, fontSize: 12)),
                    ]),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.gps_fixed, size: 14, color: secondaryText),
                      const SizedBox(width: 4),
                      Text("Confidence: ${a["confidence"]!}", style: TextStyle(color: secondaryText, fontSize: 12)),
                    ]),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text("Resolve", style: TextStyle(fontSize: 12))),
                    const SizedBox(width: 8),
                    OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text("Dismiss", style: TextStyle(fontSize: 12))),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
