import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/home/hero_section.dart';
import '../widgets/home/problem_solution_section.dart';
import '../widgets/home/system_overview_section.dart';
import '../widgets/home/core_features_section.dart';
import '../widgets/home/home_footer.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;
  const HomeScreen({super.key, required this.onToggleTheme});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: isDark ? const Color(0xFF0A0F1E) : Colors.white,
            surfaceTintColor: Colors.transparent,
            titleSpacing: 10,
            toolbarHeight: 48,
            elevation: isDark ? 0 : 1,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.visibility,
                  size: 20,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'SafetyWatch',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  size: 16,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
                onPressed: onToggleTheme,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
              ),
              const SizedBox(width: 4),
              // Login button
              OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                icon: Icon(Icons.login, size: 12,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                label: Text(
                  'Login',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Sign Up button
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/signup'),
                  icon: const Icon(Icons.person_add_outlined, size: 11),
                  label: const Text(
                    'Sign Up',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Body - All sections
          SliverToBoxAdapter(
            child: Column(
              children: [
                HeroSection(
                  isDark: isDark,
                  secondaryText: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                  onGetStarted: () => Navigator.pushNamed(context, '/signup'),
                  onWatchDemo: () {},
                ),
                ProblemSolutionSection(isDark: isDark),
                SystemOverviewSection(isDark: isDark),
                CoreFeaturesSection(isDark: isDark),
                HomeFooter(isDark: isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
