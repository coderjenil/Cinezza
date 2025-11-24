import 'package:flutter/material.dart';

class AppColors {
  // Light Theme - Blue Professional Colors
  static const Color lightPrimary = Color(0xFF2563EB); // Bright Blue
  static const Color lightAccent = Color(0xFF0EA5E9); // Sky Blue
  static const Color lightBackground = Color(0xFFFAFAFA); // Off White
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1E293B); // Dark Slate
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Dark Theme - Deep Blue Premium Palette
  static const Color darkPrimary = Color(0xFF3B82F6); // Blue
  static const Color darkAccent = Color(0xFF06B6D4); // Cyan
  static const Color darkBackground = Color(0xFF0F172A); // Dark Navy
  static const Color darkSurface = Color(0xFF1E293B); // Slate
  static const Color darkCardBackground = Color(0xFF334155); // Blue Gray
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextTertiary = Color(0xFF94A3B8);

  // Legacy compatibility
  static const Color primary = darkPrimary;
  static const Color accent = darkAccent;
  static const Color backgroundDark = darkBackground;
  static const Color backgroundLight = darkSurface;
  static const Color cardBackground = darkCardBackground;
  static const Color textPrimary = darkTextPrimary;
  static const Color textSecondary = darkTextSecondary;
  static const Color textTertiary = darkTextTertiary;

  // Functional Colors
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color info = Color(0xFF3B82F6); // Blue

  // Modern Blue Gradients - Light Theme
  static const LinearGradient lightPrimaryGradient = LinearGradient(
    colors: [Color(0xFF2563EB), Color(0xFF3B82F6)], // Blue Gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightAccentGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)], // Sky to Cyan
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Modern Blue Gradients - Dark Theme
  static const LinearGradient darkPrimaryGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)], // Blue Gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkAccentGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF0891B2)], // Cyan Gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Special Blue Gradients
  static const LinearGradient oceanGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF2563EB), Color(0xFF4F46E5)], // Ocean Blue
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient deepBlueGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF1E40AF), Color(0xFF3B82F6)], // Deep Blue
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Background Gradients
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient lightBackgroundGradient = LinearGradient(
    colors: [Color(0xFFFAFAFA), Color(0xFFF1F5F9)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Shimmer Gradient
  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [
      Color(0xFF1E293B),
      Color(0xFF334155),
      Color(0xFF1E293B),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  // Glass Effect
  static Color glassBackground = Colors.white.withOpacity(0.08);
  static Color glassBorder = Colors.white.withOpacity(0.15);

  // Legacy gradients
  static const LinearGradient primaryGradient = darkPrimaryGradient;
  static const LinearGradient accentGradient = darkAccentGradient;

  static LinearGradient cardGradient = LinearGradient(
    colors: [
      Colors.white.withOpacity(0.08),
      Colors.white.withOpacity(0.02),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Helper methods
  static LinearGradient getPrimaryGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkPrimaryGradient
        : lightPrimaryGradient;
  }

  static LinearGradient getAccentGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkAccentGradient
        : lightAccentGradient;
  }

  // Get fire/trending gradient (using blue instead of orange)
  static LinearGradient getTrendingGradient(BuildContext context) {
    return const LinearGradient(
      colors: [Color(0xFF06B6D4), Color(0xFF0EA5E9)], // Cyan to Sky Blue
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
