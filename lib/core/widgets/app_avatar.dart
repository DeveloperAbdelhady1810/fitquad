import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Reusable avatar that shows a [NetworkImage] when [url] is non-null,
/// falls back to initials derived from [name], and handles load errors.
class AppAvatar extends StatelessWidget {
  final String? url;
  final String name;
  final double radius;
  final Color? bgColor;
  final Color? textColor;

  const AppAvatar({
    super.key,
    required this.name,
    this.url,
    this.radius = 20,
    this.bgColor,
    this.textColor,
  });

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  double get _fontSize => (radius * 0.55).clamp(10, 28);

  @override
  Widget build(BuildContext context) {
    final bg   = bgColor ?? AppColors.teal.withValues(alpha: 0.2);
    final fg   = textColor ?? AppColors.teal;

    if (url != null && url!.isNotEmpty) {
      return CircleAvatar(
        radius: radius.r,
        backgroundColor: bg,
        child: ClipOval(
          child: Image.network(
            url!,
            width:  radius.r * 2,
            height: radius.r * 2,
            fit:    BoxFit.cover,
            errorBuilder: (_, __, ___) => _initialsWidget(bg, fg),
            loadingBuilder: (_, child, progress) =>
                progress == null ? child : _initialsWidget(bg, fg),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius.r,
      backgroundColor: bg,
      child: _initialsWidget(bg, fg),
    );
  }

  Widget _initialsWidget(Color bg, Color fg) => Container(
    width:  double.infinity,
    height: double.infinity,
    decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
    alignment: Alignment.center,
    child: Text(
      _initials,
      style: AppTextStyles.font14WhiteRegular.copyWith(
          color: fg,
          fontSize: _fontSize,
          fontWeight: FontWeight.bold),
    ),
  );
}
