import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Aurora palette — deep navy base, teal/cyan mid, lime accent
  static const Color midnightBlue = Color(0xFF020B14);
  static const Color darkNavy = Color(0xFF0A1F35);
  static const Color deepBlue = Color(0xFF0C5C6B);
  static const Color aquaBlue = Color(0xFF14B8A6);
  static const Color cyan = Color(0xFF2DD4BF);
  static const Color teal = Color(0xFF0D9488);
  static const Color limeAccent = Color(0xFFD4F76A);
  static const Color mintGlow = Color(0xFFA7F3D0);

  static const Color lightBackground = Color(0xFFF4FBFF);
  static const Color cardDark = Color(0xFF0C2238);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color successGreen = Color(0xFF4ADE80);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color dangerRed = Color(0xFFEF4444);
  static const Color textPrimary = Color(0xFF0B1F33);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8BA8BE);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [limeAccent, aquaBlue, cyan],
    stops: [0.0, 0.45, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = primaryGradient;

  static const LinearGradient heroCardGradient = LinearGradient(
    colors: [limeAccent, aquaBlue, cyan, deepBlue],
    stops: [0.0, 0.35, 0.7, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient screenBackgroundGradient = LinearGradient(
    colors: [
      Color(0xFF3D6B1E),
      Color(0xFF0F766E),
      Color(0xFF0A1F35),
      Color(0xFF020B14),
    ],
    stops: [0.0, 0.28, 0.62, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static List<BoxShadow> glowShadow({Color? color, double blur = 16}) => [
        BoxShadow(
          color: (color ?? limeAccent).withValues(alpha: 0.3),
          blurRadius: blur,
          spreadRadius: 0,
          offset: const Offset(0, 4),
        ),
      ];

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return warningOrange;
      case 'washing':
        return aquaBlue;
      case 'completed':
        return successGreen;
      case 'cancelled':
        return dangerRed;
      default:
        return textSecondary;
    }
  }
}
