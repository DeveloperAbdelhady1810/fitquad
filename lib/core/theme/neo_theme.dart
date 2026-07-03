import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Neo "Cyber-Performance Kinetic" design tokens ─────────────────────────────

class NeoColors {
  const NeoColors._();

  // Surfaces
  static const bg           = Color(0xFF131315);  // Deep Obsidian
  static const bgLow        = Color(0xFF0E0E10);
  static const surface      = Color(0xFF201F21);  // Card bg
  static const surfaceHigh  = Color(0xFF2A2A2C);
  static const surfaceTop   = Color(0xFF353437);

  // Brand neons
  static const cyan   = Color(0xFF00F3FF);  // Electric Cyan – primary action
  static const lime   = Color(0xFFCCFF00);  // Neon Lime – success / progress
  static const magenta= Color(0xFFFF00FF);  // Hot Magenta – alerts / tertiary

  // Text
  static const onSurface        = Color(0xFFE5E1E4);
  static const onSurfaceVariant = Color(0xFFB9CACB);
  static const outline          = Color(0xFF849495);
  static const outlineVariant   = Color(0xFF3A494B);
}

class NeoTextStyles {
  const NeoTextStyles._();

  // Anton – display / hero headings (always UPPERCASE in Neo)
  static TextStyle displayHero = GoogleFonts.anton(
    fontSize: 48.sp,
    color: NeoColors.onSurface,
    letterSpacing: 0.02,
  );

  static TextStyle headlineLg = GoogleFonts.anton(
    fontSize: 28.sp,
    color: NeoColors.onSurface,
  );

  static TextStyle headlineMd = GoogleFonts.anton(
    fontSize: 20.sp,
    color: NeoColors.onSurface,
  );

  static TextStyle headlineSm = GoogleFonts.anton(
    fontSize: 16.sp,
    color: NeoColors.onSurface,
  );

  // JetBrains Mono – numerical data / metrics
  static TextStyle dataLg = GoogleFonts.jetBrainsMono(
    fontSize: 28.sp,
    fontWeight: FontWeight.w700,
    color: NeoColors.cyan,
    letterSpacing: 0.05,
  );

  static TextStyle dataMd = GoogleFonts.jetBrainsMono(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: NeoColors.cyan,
    letterSpacing: 0.05,
  );

  static TextStyle dataSm = GoogleFonts.jetBrainsMono(
    fontSize: 13.sp,
    fontWeight: FontWeight.w500,
    color: NeoColors.onSurfaceVariant,
    letterSpacing: 0.05,
  );

  // Inter – body / labels
  static TextStyle bodyLg = GoogleFonts.inter(
    fontSize: 16.sp,
    color: NeoColors.onSurface,
  );

  static TextStyle bodySm = GoogleFonts.inter(
    fontSize: 13.sp,
    color: NeoColors.onSurfaceVariant,
  );

  static TextStyle labelCaps = GoogleFonts.inter(
    fontSize: 10.sp,
    fontWeight: FontWeight.w700,
    color: NeoColors.onSurfaceVariant,
    letterSpacing: 0.10,
  );
}

class NeoDecorations {
  const NeoDecorations._();

  // Card: sharp edges, 1px cyan border, dark glass bg
  static BoxDecoration card = BoxDecoration(
    color: NeoColors.surface,
    border: Border.all(color: NeoColors.cyan.withValues(alpha: 0.25)),
  );

  static BoxDecoration cardCyan = BoxDecoration(
    color: NeoColors.surface,
    border: Border.all(color: NeoColors.cyan.withValues(alpha: 0.6)),
    boxShadow: [
      BoxShadow(
        color: NeoColors.cyan.withValues(alpha: 0.10),
        blurRadius: 12,
        spreadRadius: 0,
      ),
    ],
  );

  static BoxDecoration cardLime = BoxDecoration(
    color: NeoColors.surface,
    border: Border.all(color: NeoColors.lime.withValues(alpha: 0.5)),
    boxShadow: [
      BoxShadow(
        color: NeoColors.lime.withValues(alpha: 0.08),
        blurRadius: 10,
      ),
    ],
  );

  static BoxDecoration cardMagenta = BoxDecoration(
    color: NeoColors.surface,
    border: Border.all(color: NeoColors.magenta.withValues(alpha: 0.4)),
    boxShadow: [
      BoxShadow(
        color: NeoColors.magenta.withValues(alpha: 0.08),
        blurRadius: 10,
      ),
    ],
  );

  static BoxDecoration activeButton = BoxDecoration(
    color: NeoColors.cyan,
  );

  static BoxDecoration outlineButton = BoxDecoration(
    border: Border.all(color: NeoColors.cyan),
  );
}

// Glow box-shadow helpers
BoxShadow neoCyanGlow({double alpha = 0.25, double blur = 16}) =>
    BoxShadow(color: NeoColors.cyan.withValues(alpha: alpha), blurRadius: blur);

BoxShadow neoLimeGlow({double alpha = 0.20, double blur = 12}) =>
    BoxShadow(color: NeoColors.lime.withValues(alpha: alpha), blurRadius: blur);

BoxShadow neoMagentaGlow({double alpha = 0.20, double blur = 12}) =>
    BoxShadow(color: NeoColors.magenta.withValues(alpha: alpha), blurRadius: blur);
