import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  final double fontSize;

  const LogoWidget({
    super.key,
    this.size = 48,
    this.fontSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          isDark ? 'assets/images/logo_v2_dark.png' : 'assets/images/logo_v2.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.visibility,
            size: size,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(width: 8),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Safety',
                style: GoogleFonts.sora(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF084298),
                ),
              ),
              TextSpan(
                text: 'Watch',
                style: GoogleFonts.sora(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF3B82F6),
                ),
              ),
            ],
          ),
          style: TextStyle(fontSize: fontSize),
        ),
      ],
    );
  }
}
