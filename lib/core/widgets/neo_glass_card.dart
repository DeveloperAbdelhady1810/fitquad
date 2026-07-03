import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/neo_theme.dart';

class NeoGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;
  final double? width;
  final double? height;

  const NeoGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderColor,
    this.boxShadow,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0x88201F21),
            border: Border.all(
              color: borderColor ?? NeoColors.cyan.withValues(alpha: 0.20),
            ),
            boxShadow: boxShadow,
          ),
          child: child,
        ),
      ),
    );
  }
}
