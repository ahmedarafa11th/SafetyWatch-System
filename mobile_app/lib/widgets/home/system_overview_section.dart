import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class SystemOverviewSection extends StatelessWidget {
  final bool isDark;
  const SystemOverviewSection({super.key, required this.isDark});

  void _showArchitectureDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Text('System Architecture',
                  style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  )),
              const SizedBox(height: 6),
              Text('Complete system pipeline and technology stack',
                  style: TextStyle(fontSize: 11, color: labelColor)),
              const SizedBox(height: 24),

              // Pipeline Steps
              _pipelineCard(isDark, Icons.videocam, 'Input: Camera Feed',
                  'Live video streams from surveillance cameras are captured and sent to the processing pipeline.', AppColors.primary),
              _arrowDown(isDark),
              _pipelineCard(isDark, Icons.psychology, 'AI Processing',
                  'Deep learning models analyze video frames for violence detection and face recognition in real-time.', AppColors.warning),
              _arrowDown(isDark),
              _pipelineCard(isDark, Icons.notification_important, 'Alert Generation',
                  'When violations are detected, instant alerts are generated and sent to administrators.', AppColors.error),
              _arrowDown(isDark),

              // Output card with sub-views
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.success.withAlpha(isDark ? 30 : 40),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.dashboard, color: AppColors.success, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Output: Dashboard & Alerts',
                                  style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                                  )),
                              const SizedBox(height: 4),
                              Text('Web dashboard provides real-time monitoring, analytics, and alert management for admins and employees.',
                                  style: TextStyle(fontSize: 10, color: labelColor, height: 1.4)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.success.withAlpha(isDark ? 20 : 25),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.success.withAlpha(isDark ? 50 : 60)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Admin View', style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A))),
                                const SizedBox(height: 4),
                                Text('Full system control', style: TextStyle(fontSize: 10, color: labelColor)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Employee View', style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : const Color(0xFF0F172A))),
                                const SizedBox(height: 4),
                                Text('Personal attendance', style: TextStyle(fontSize: 10, color: labelColor)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              _arrowDown(isDark),

              // Technology Stack
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TECHNOLOGY STACK',
                        style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                          letterSpacing: 0.5,
                        )),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _techItem('Frontend', 'React + Tailwind', isDark),
                        _techItem('Backend', 'Python + Flask', isDark),
                        _techItem('AI/ML', 'TensorFlow +\nPyTorch', isDark),
                        _techItem('Database', 'PostgreSQL', isDark),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pipelineCard(bool isDark, IconData icon, String title, String desc, Color color) {
    final labelColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(isDark ? 30 : 40),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(fontSize: 10, color: labelColor, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _arrowDown(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Center(
        child: Text('V', style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w700,
          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
        )),
      ),
    );
  }

  Widget _techItem(String title, String value, bool isDark) {
    final labelColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    return Expanded(
      child: Column(
        children: [
          Text(title, style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(value, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9, color: labelColor, height: 1.3)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 36),
      color: isDark ? const Color(0xFF0D1229) : Colors.white,
      child: Column(
        children: [
          Text('System Overview',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              )),
          const SizedBox(height: 6),
          Text(
            'End-to-end AI safety monitoring pipeline',
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _overviewItem(Icons.videocam, 'Live Feed'),
              _arrow(),
              _overviewItem(Icons.psychology, 'Analysis'),
              _arrow(),
              _overviewItem(Icons.warning_amber, 'Alerts'),
              _arrow(),
              _overviewItem(Icons.dashboard, 'Dashboard'),
            ],
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () => _showArchitectureDialog(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(isDark ? 15 : 20),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withAlpha(isDark ? 40 : 50)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.architecture, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text('View System Architecture',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewItem(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
          boxShadow: isDark
              ? []
              : [BoxShadow(color: Colors.black.withAlpha(6), blurRadius: 6, offset: const Offset(0, 1))],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(height: 5),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                )),
          ],
        ),
      ),
    );
  }

  Widget _arrow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Icon(Icons.arrow_forward, size: 12,
          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
    );
  }
}
