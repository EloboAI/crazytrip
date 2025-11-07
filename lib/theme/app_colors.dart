import 'package:flutter/material.dart';

/// Crazy Trip - Color System
/// Based on Material Design 3 Expressive with vibrant, adventure-themed colors
class AppColors {
  AppColors._();

  // Brand Colors - Accessible adventure palette (WCAG AA compliant)
  static const Color primaryColor = Color(
    0xFF5E35B1,
  ); // Deep purple - distinguible for all color vision types
  static const Color secondaryColor = Color(
    0xFFD84315,
  ); // Deep orange - high contrast, colorblind-friendly
  static const Color tertiaryColor = Color(
    0xFF00897B,
  ); // Teal - distinct from primary/secondary
  static const Color errorColor = Color(0xFFC62828); // Dark red for better contrast

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFFFFBFE);
  static const Color lightSurface = Color(0xFFFFFBFE);
  static const Color lightSurfaceVariant = Color(0xFFE7E0EC);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightOnSecondary = Color(0xFFFFFFFF);
  static const Color lightOnBackground = Color(0xFF1C1B1F);
  static const Color lightOnSurface = Color(0xFF1C1B1F);
  static const Color lightOutline = Color(0xFF79747E);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF1C1B1F);
  static const Color darkSurface = Color(0xFF1C1B1F);
  static const Color darkSurfaceVariant = Color(0xFF49454F);
  static const Color darkOnPrimary = Color(0xFF381E72);
  static const Color darkOnSecondary = Color(0xFF4A2532);
  static const Color darkOnBackground = Color(0xFFE6E1E5);
  static const Color darkOnSurface = Color(0xFFE6E1E5);
  static const Color darkOutline = Color(0xFF938F99);

  // Gamification Colors - High contrast, colorblind-safe
  static const Color goldColor = Color(0xFFF9A825); // Amber gold - better contrast
  static const Color silverColor = Color(0xFF757575); // Medium gray
  static const Color bronzeColor = Color(0xFF8D6E63); // Brown - distinct from gold
  static const Color xpColor = Color(0xFF0277BD); // Blue - safe for protanopia/deuteranopia
  static const Color streakColor = Color(0xFFE65100); // Deep orange - high visibility
  static const Color achievementColor = Color(0xFF6A1B9A); // Deep purple - distinct

  // Semantic Colors - WCAG AA compliant
  static const Color successColor = Color(0xFF2E7D32); // Dark green - better contrast
  static const Color warningColor = Color(0xFFEF6C00); // Deep orange
  static const Color infoColor = Color(0xFF0277BD); // Blue - colorblind-safe

  // AR & Map Overlay Colors - Better contrast
  static const Color arOverlayBackground = Color(0x4D000000); // 30% black - more visible
  static const Color arHighlight = Color(0xFFFDD835); // Yellow - high visibility
  static const Color mapPinActive = Color(0xFFD32F2F); // Red - colorblind-safe
  static const Color mapPinInactive = Color(0xFF616161); // Dark gray - better contrast

  // Gradient Colors - Accessible combinations
  static const List<Color> primaryGradient = [
    Color(0xFF5E35B1), // Deep purple
    Color(0xFF7E57C2), // Medium purple
  ];

  static const List<Color> discoveryGradient = [
    Color(0xFFD84315), // Deep orange
    Color(0xFFFF7043), // Light orange-red
  ];

  static const List<Color> achievementGradient = [
    Color(0xFF00897B), // Teal
    Color(0xFF26A69A), // Light teal
  ];

  // Surface Elevation Colors (for dark mode)
  static Color elevatedSurface(int elevation) {
    // Material Design 3 elevation tint
    final opacity = (elevation * 0.05).clamp(0.0, 0.15);
    return Color.lerp(darkSurface, Colors.white, opacity)!;
  }
}
