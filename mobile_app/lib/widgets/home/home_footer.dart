import 'package:flutter/material.dart';

class HomeFooter extends StatelessWidget {
  final bool isDark;
  const HomeFooter({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0F1E) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.visibility, size: 20,
                  color: isDark ? Colors.white : const Color(0xFF1E293B)),
              const SizedBox(width: 6),
              Text('SafetyWatch',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  )),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'AI-Powered Workplace Safety System',
            style: TextStyle(
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 16),
          Divider(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            height: 1,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _footerLink('About'),
              _footerLink('Features'),
              _footerLink('Contact'),
              _footerLink('Privacy'),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '© 2026 SafetyWatch. All rights reserved.',
            style: TextStyle(
              color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _footerLink(String text) {
    return Text(text,
        style: TextStyle(
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ));
  }
}
