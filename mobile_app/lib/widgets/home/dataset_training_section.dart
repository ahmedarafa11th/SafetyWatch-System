import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class DatasetTrainingSection extends StatelessWidget {
  final bool isDark;
  const DatasetTrainingSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 36),
      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      child: Column(
        children: [
          Text('Dataset & Training',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              )),
          const SizedBox(height: 6),
          Text(
            'A robust dataset and careful training process ensure reliability',
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // 3 cards in a row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _dataCard(
                  icon: Icons.storage,
                  iconColor: AppColors.primary,
                  title: 'Data Sources',
                  desc: 'Collected 10,000+ images from public surveillance datasets, ensuring diverse scenarios.',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dataCard(
                  icon: Icons.tune,
                  iconColor: AppColors.warning,
                  title: 'Augmentation & Prep',
                  desc: 'Applied flipping, rotation, brightness adjustment, and noise injection.',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _dataCard(
                  icon: Icons.model_training,
                  iconColor: AppColors.success,
                  title: 'Training Methodology',
                  desc: 'Transfer learning with fine-tuning, cross-validation and early stopping.',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _dataCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
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
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withAlpha(isDark ? 25 : 30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 10),
          Text(title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              )),
          const SizedBox(height: 6),
          Text(desc,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                height: 1.4,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
