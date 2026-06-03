import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class AIModelsSection extends StatelessWidget {
  final bool isDark;
  const AIModelsSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 36),
      color: isDark ? const Color(0xFF0D1229) : Colors.white,
      child: Column(
        children: [
          Text('AI Models',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              )),
          const SizedBox(height: 6),
          Text(
            'State-of-the-art deep learning models powering our system',
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Side-by-side model cards
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _modelCard(
                  imagePath: 'assets/images/violence_detection.png',
                  title: 'Violence Detection Model',
                  desc: 'A fine-tuned deep learning model that detects violence and aggressive behavior in real-time video feeds.',
                  accuracy: '90%',
                  metric: 'Accuracy',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _modelCard(
                  imagePath: 'assets/images/face_recognition.png',
                  title: 'Face Recognition Model',
                  desc: 'Advanced facial recognition for automated employee identification and attendance tracking.',
                  accuracy: '95%',
                  metric: 'Recognition Rate',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

        ],
      ),
    );
  }

  Widget _modelCard({
    required String imagePath,
    required String title,
    required String desc,
    required String accuracy,
    required String metric,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: isDark
            ? []
            : [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              imagePath,
              width: double.infinity,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Text(title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
              maxLines: 2),
          const SizedBox(height: 6),
          Text(desc,
              style: TextStyle(
                fontSize: 9,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                height: 1.5,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(accuracy,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  )),
              const SizedBox(width: 6),
              Icon(Icons.trending_up, color: AppColors.success, size: 16),
            ],
          ),
          const SizedBox(height: 2),
          Text(metric,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              )),
        ],
      ),
    );
  }
}
