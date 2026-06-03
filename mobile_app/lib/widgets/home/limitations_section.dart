import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class LimitationsSection extends StatelessWidget {
  final bool isDark;
  const LimitationsSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 36),
      color: isDark ? const Color(0xFF0D1229) : Colors.white,
      child: Column(
        children: [
          Text('Limitations & Future Work',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              )),
          const SizedBox(height: 6),
          Text(
            'We are constantly improving our system for better results',
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Side-by-side cards
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Limitations Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [const Color(0xFF7C3AED).withAlpha(30), const Color(0xFF1E293B)]
                          : [const Color(0xFF7C3AED).withAlpha(15), Colors.white],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF7C3AED).withAlpha(60)
                          : const Color(0xFF7C3AED).withAlpha(40),
                    ),
                    boxShadow: isDark
                        ? []
                        : [BoxShadow(color: const Color(0xFF7C3AED).withAlpha(10), blurRadius: 15, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C3AED).withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.info_outline, color: Color(0xFF7C3AED), size: 16),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text('Current Limitations',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _limitItem('Performance may vary in low-light conditions'),
                      _limitItem('Requires stable network for real-time processing'),
                      _limitItem('Limited to trained violence categories'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Future Improvements Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [AppColors.primary.withAlpha(30), const Color(0xFF1E293B)]
                          : [AppColors.primary.withAlpha(15), Colors.white],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? AppColors.primary.withAlpha(60)
                          : AppColors.primary.withAlpha(40),
                    ),
                    boxShadow: isDark
                        ? []
                        : [BoxShadow(color: AppColors.primary.withAlpha(10), blurRadius: 15, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.rocket_launch, color: AppColors.primary, size: 16),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text('Future Improvements',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _futureItem('Multi-camera synchronization support'),
                      _futureItem('Edge computing for faster processing'),
                      _futureItem('Expanded violence category detection'),
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

  Widget _limitItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber, size: 12, color: Color(0xFFFBBF24)),
          const SizedBox(width: 6),
          Expanded(
              child: Text(text,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                    height: 1.4,
                  ))),
        ],
      ),
    );
  }

  Widget _futureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.arrow_forward, size: 12, color: AppColors.primary),
          const SizedBox(width: 6),
          Expanded(
              child: Text(text,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                    height: 1.4,
                  ))),
        ],
      ),
    );
  }
}
