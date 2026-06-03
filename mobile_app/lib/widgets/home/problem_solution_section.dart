import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class ProblemSolutionSection extends StatelessWidget {
  final bool isDark;
  const ProblemSolutionSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 36),
      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      child: Column(
        children: [
          Text(
            'Problem & Solution',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Understanding the challenges and our AI-driven approach',
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Side-by-side Problem & Solution cards
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Problem Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.error.withAlpha(isDark ? 25 : 30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.error_outline, color: AppColors.error, size: 16),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text('The Problem',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _bulletItem('Traditional surveillance requires constant human monitoring', AppColors.error),
                      _bulletItem('Manual attendance tracking is error-prone', AppColors.error),
                      _bulletItem('Safety violations often go undetected in real-time', AppColors.error),
                      _bulletItem('Lack of intelligent alerting systems', AppColors.error),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Solution Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.success.withAlpha(isDark ? 25 : 30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.lightbulb_outline, color: AppColors.success, size: 16),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text('Our Solution',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _bulletItem('Real-time AI detection with deep learning', AppColors.success),
                      _bulletItem('Automated face recognition for attendance', AppColors.success),
                      _bulletItem('Instant alerts for safety violations', AppColors.success),
                      _bulletItem('Comprehensive monitoring dashboard', AppColors.success),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bulletItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 12, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style: TextStyle(
                  fontSize: 10,
                  height: 1.4,
                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                )),
          ),
        ],
      ),
    );
  }
}
