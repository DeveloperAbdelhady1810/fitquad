import 'package:flutter/material.dart';

class ThemeConfig {
  final String id;
  final String name;
  final String emoji;
  final Color accent;
  final Color accentDim;
  final Color gradientStart;
  final Color gradientEnd;

  const ThemeConfig({
    required this.id,
    required this.name,
    required this.emoji,
    required this.accent,
    required this.accentDim,
    required this.gradientStart,
    required this.gradientEnd,
  });

  static const List<ThemeConfig> presets = [
    ThemeConfig(
      id: 'teal',
      name: 'Ocean',
      emoji: '🌊',
      accent: Color(0xFF00a689),
      accentDim: Color(0x3300a689),
      gradientStart: Color(0xFF00a689),
      gradientEnd: Color(0xFF006655),
    ),
    ThemeConfig(
      id: 'purple',
      name: 'Cosmos',
      emoji: '🔮',
      accent: Color(0xFFa338d8),
      accentDim: Color(0x33a338d8),
      gradientStart: Color(0xFFa338d8),
      gradientEnd: Color(0xFF6b1f8c),
    ),
    ThemeConfig(
      id: 'blue',
      name: 'Arctic',
      emoji: '❄️',
      accent: Color(0xFF4d8dbd),
      accentDim: Color(0x334d8dbd),
      gradientStart: Color(0xFF4d8dbd),
      gradientEnd: Color(0xFF1a4f7a),
    ),
    ThemeConfig(
      id: 'gold',
      name: 'Ember',
      emoji: '🔥',
      accent: Color(0xFFe8a020),
      accentDim: Color(0x33e8a020),
      gradientStart: Color(0xFFe8a020),
      gradientEnd: Color(0xFFa05010),
    ),
  ];

  ThemeData toMaterialTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF020618),
      colorScheme: ColorScheme.dark(
        primary: accent,
        secondary: accent,
        surface: const Color(0xFF0F172A),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: accent),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? accent : null),
        trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? accent.withValues(alpha: 0.3) : null),
      ),
    );
  }
}
