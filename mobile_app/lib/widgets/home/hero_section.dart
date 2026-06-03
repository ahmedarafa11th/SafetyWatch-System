import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class HeroSection extends StatelessWidget {
  final bool isDark;
  final Color secondaryText;
  final VoidCallback onGetStarted;
  final VoidCallback onWatchDemo;

  const HeroSection({
    super.key,
    required this.isDark,
    required this.secondaryText,
    required this.onGetStarted,
    required this.onWatchDemo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0A0F1E), const Color(0xFF111936), const Color(0xFF0D1229)]
              : [const Color(0xFFEFF6FF), const Color(0xFFE0ECFF), const Color(0xFFF0F5FF)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left text column
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Graduation Project 2026
                  Text(
                    'Graduation Project 2026',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      fontStyle: FontStyle.italic,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Main title
                  Text(
                    'Enhancing Workplace\nSafety Using AI',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Highlighted subtitle
                  Text(
                    'Real-time violence detection and automated attendance tracking',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF7DD3FC) : AppColors.primary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  Text(
                    'Enhance workplace safety with real-time violence detection and automated attendance tracking using AI-driven face recognition and monitoring solutions.',
                    style: TextStyle(
                      fontSize: 8,
                      color: secondaryText,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // CTA Buttons
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ElevatedButton.icon(
                        onPressed: onWatchDemo,
                        icon: const Icon(Icons.play_arrow, size: 11),
                        label: const Text('Live Demo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 8)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: onGetStarted,
                        icon: Icon(Icons.grid_view, size: 9,
                            color: isDark ? Colors.white70 : const Color(0xFF475569)),
                        label: Text('How It Works',
                            style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 8,
                              color: isDark ? Colors.white70 : const Color(0xFF475569),
                            )),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Right image column
            Expanded(
              flex: 4,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Camera image
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFBFDBFE),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? AppColors.primary.withAlpha(20) : AppColors.primary.withAlpha(30),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        'assets/images/hero_camera.jpg',
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Alert System badge (top right)
                  Positioned(
                    top: 0,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B).withAlpha(230) : Colors.white.withAlpha(230),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(30),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber, size: 14, color: AppColors.warning),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Alert System',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  )),
                              Text('Real-time',
                                  style: TextStyle(
                                    fontSize: 7,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Face Detection badge (bottom left)
                  Positioned(
                    bottom: -8,
                    left: -8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B).withAlpha(230) : Colors.white.withAlpha(230),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(30),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.face, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Face Detection',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  )),
                              Text('98% Accuracy',
                                  style: TextStyle(
                                    fontSize: 7,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
