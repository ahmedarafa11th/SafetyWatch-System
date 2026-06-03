import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class CoreFeaturesSection extends StatelessWidget {
  final bool isDark;
  const CoreFeaturesSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final features = [
      {'icon': Icons.remove_red_eye, 'title': 'AI Violence Detection', 'desc': 'Real-time violence and threat detection using deep learning models'},
      {'icon': Icons.face, 'title': 'Face Recognition & Attendance', 'desc': 'Automated attendance tracking through facial recognition technology'},
      {'icon': Icons.shield, 'title': 'Real-Time Safety Alerts', 'desc': 'Instant notifications when safety violations are detected'},
      {'icon': Icons.analytics, 'title': 'Analytics Dashboard', 'desc': 'Comprehensive monitoring with detailed analytics and reports'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 36),
      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      child: Column(
        children: [
          Text('Core Features',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              )),
          const SizedBox(height: 6),
          Text(
            'Our comprehensive AI-powered features for workplace safety',
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          // 4 cards in a single row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: features
                .map((f) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: f == features.first ? 0 : 4,
                          right: f == features.last ? 0 : 4,
                        ),
                        child: _featureCard(
                          f['icon'] as IconData,
                          f['title'] as String,
                          f['desc'] as String,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _featureCard(IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: isDark
            ? []
            : [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(isDark ? 25 : 30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(height: 8),
          Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
              maxLines: 2),
          const SizedBox(height: 4),
          Text(desc,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 8,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                height: 1.3,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
