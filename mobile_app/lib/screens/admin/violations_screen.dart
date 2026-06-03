import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../widgets/status_badge.dart';

class ViolationsScreenPage extends StatelessWidget {
  const ViolationsScreenPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final violations = [
      {"type": "Violence", "camera": "Camera 3 - Warehouse", "time": "2026-02-01 14:35", "severity": "Critical", "desc": "Physical altercation detected between two individuals"},
      {"type": "Restricted Access", "camera": "Camera 8 - Server Room", "time": "2026-02-01 11:20", "severity": "High", "desc": "Unauthorized person attempted to access restricted area"},
      {"type": "Safety Violation", "camera": "Camera 7 - Parking", "time": "2026-01-31 09:45", "severity": "Medium", "desc": "Employee not wearing required safety equipment"},
      {"type": "Unusual Activity", "camera": "Camera 2 - Office Floor", "time": "2026-01-30 16:10", "severity": "Medium", "desc": "Suspicious movement detected after business hours"},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Violations", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("Review detected safety violations", style: TextStyle(color: secondaryText, fontSize: 14)),
          const SizedBox(height: 20),

          ...violations.map((v) => Container(
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
                    Expanded(child: Text(v["type"]!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                    StatusBadge(text: v["severity"]!),
                  ],
                ),
                const SizedBox(height: 8),
                Text(v["desc"]!, style: TextStyle(color: secondaryText, fontSize: 13)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.videocam, size: 14, color: secondaryText),
                    const SizedBox(width: 6),
                    Text(v["camera"]!, style: TextStyle(color: secondaryText, fontSize: 12)),
                    const SizedBox(width: 16),
                    Icon(Icons.access_time, size: 14, color: secondaryText),
                    const SizedBox(width: 6),
                    Text(v["time"]!, style: TextStyle(color: secondaryText, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("View Details", style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Resolve", style: TextStyle(fontSize: 12)),
                    ),
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
