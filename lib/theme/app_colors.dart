import 'package:flutter/material.dart';

/// Crazy Trip - Color System
/// Based on Material Design 3 Expressive with vibrant, adventure-themed colors
class AppColors {
  AppColors._();

  // Brand Colors - Vibrant adventure palette
  static const Color primaryColor = Color(0xFF6B4EFF); // Vibrant purple for adventure
  static const Color secondaryColor = Color(0xFFFF6B9D); // Energetic pink for discovery
  static const Color tertiaryColor = Color(0xFF00C9A7); // Fresh teal for exploration
  static const Color errorColor = Color(0xFFFF5449);

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

  // Gamification Colors
  static const Color goldColor = Color(0xFFFFD700); // 1st place, premium
  static const Color silverColor = Color(0xFFC0C0C0); // 2nd place
  static const Color bronzeColor = Color(0xFFCD7F32); // 3rd place
  static const Color xpColor = Color(0xFF00E5FF); // Experience points
  static const Color streakColor = Color(0xFFFF6F00); // Fire/streak indicator
  static const Color achievementColor = Color(0xFF7C4DFF); // Achievement unlock

  // Semantic Colors
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF2196F3);

  // AR & Map Overlay Colors
  static const Color arOverlayBackground = Color(0x33000000); // 20% black
  static const Color arHighlight = Color(0xFFFFEB3B);
  static const Color mapPinActive = Color(0xFFFF5252);
  static const Color mapPinInactive = Color(0xFF9E9E9E);

  // Gradient Colors for cards and highlights
  static const List<Color> primaryGradient = [
    Color(0xFF6B4EFF),
    Color(0xFF9D4EFF),
  ];

  static const List<Color> discoveryGradient = [
    Color(0xFFFF6B9D),
    Color(0xFFFF9D6B),
  ];

  static const List<Color> achievementGradient = [
    Color(0xFF00C9A7),
    Color(0xFF00A7C9),
  ];

  // Surface Elevation Colors (for dark mode)
  static Color elevatedSurface(int elevation) {
    // Material Design 3 elevation tint
    final opacity = (elevation * 0.05).clamp(0.0, 0.15);
    return Color.lerp(darkSurface, Colors.white, opacity)!;
  }
}
