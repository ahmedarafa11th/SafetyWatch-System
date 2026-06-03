import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class TeamSection extends StatelessWidget {
  final bool isDark;
  const TeamSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final members = [
      {'name': 'Ahmed Arafa', 'role': 'AI & Deep Learning', 'initials': 'AA', 'color': AppColors.primary},
      {'name': 'Mohamed Bahaa', 'role': 'AI & Deep Learning', 'initials': 'MB', 'color': AppColors.success},
      {'name': 'Ahmed Hossam', 'role': 'UI/UX', 'initials': 'AH', 'color': AppColors.info},
      {'name': 'Mahmoud Abdelaal', 'role': 'Backend Development', 'initials': 'MA', 'color': AppColors.warning},
      {'name': 'Mano Alaa', 'role': 'Backend Development', 'initials': 'MA', 'color': const Color(0xFF7C3AED)},
      {'name': 'Mostafa Bassam', 'role': 'Frontend Development', 'initials': 'MB', 'color': AppColors.success},
      {'name': 'Kareem Tarek', 'role': 'Frontend Development', 'initials': 'KT', 'color': AppColors.info},
      {'name': 'Ahmed Kamal', 'role': 'Flutter', 'initials': 'AK', 'color': AppColors.primary},
      {'name': 'Ziad Moamen', 'role': 'Flutter', 'initials': 'ZM', 'color': const Color(0xFF7C3AED)},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 36),
      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      child: Column(
        children: [
          Text('Team & Roles',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              )),
          const SizedBox(height: 6),
          Text(
            'Graduation project team members and their technical contributions',
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // First row - 4 members
          Row(
            children: [
              for (int i = 0; i < 4; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(child: _memberCard(members[i])),
              ],
            ],
          ),
          const SizedBox(height: 8),
          // Second row - 4 members
          Row(
            children: [
              for (int i = 4; i < 8; i++) ...[
                if (i > 4) const SizedBox(width: 8),
                Expanded(child: _memberCard(members[i])),
              ],
            ],
          ),
          const SizedBox(height: 8),
          // Third row - 1 member (left aligned)
          Row(
            children: [
              Expanded(child: _memberCard(members[8])),
              const SizedBox(width: 8),
              const Expanded(child: SizedBox()),
              const SizedBox(width: 8),
              const Expanded(child: SizedBox()),
              const SizedBox(width: 8),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _memberCard(Map<String, dynamic> member) {
    final name = member['name'] as String;
    final role = member['role'] as String;
    final initials = member['initials'] as String;
    final color = member['color'] as Color;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
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
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withAlpha(isDark ? 40 : 50),
              shape: BoxShape.circle,
              border: Border.all(color: color.withAlpha(isDark ? 80 : 100)),
            ),
            child: Center(
              child: Text(initials,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                  )),
            ),
          ),
          const SizedBox(height: 8),
          Text(name,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text(role,
              style: TextStyle(
                fontSize: 8,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
