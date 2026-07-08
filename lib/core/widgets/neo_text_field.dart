import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/theme/neo_theme.dart';

import '../../generated/l10n.dart';

/// Neo-styled counterpart to [CustomTextFormField], used on login/signup
/// when the Neo skin is active.
class NeoTextField extends StatefulWidget {
  const NeoTextField({
    super.key,
    this.hintText,
    required this.textInputType,
    this.validator,
    this.controller,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
  });

  final String? hintText;
  final TextInputType textInputType;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  @override
  State<NeoTextField> createState() => _NeoTextFieldState();
}

class _NeoTextFieldState extends State<NeoTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.textInputType == TextInputType.visiblePassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _isObscured,
      inputFormatters: widget.inputFormatters,
      keyboardType: widget.textInputType,
      textCapitalization: widget.textCapitalization,
      cursorColor: NeoColors.cyan,
      style: NeoTextStyles.bodySm.copyWith(color: NeoColors.onSurface),
      validator: widget.validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return S.of(context).required_field;
            }
            return null;
          },
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: NeoTextStyles.bodySm.copyWith(color: NeoColors.outline),
        filled: true,
        fillColor: NeoColors.bg,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        errorStyle: TextStyle(color: NeoColors.magenta, fontSize: 11.sp),
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(focused: true),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: NeoColors.magenta),
        ),
        prefixIcon: _prefixIcon(),
        suffixIcon: widget.textInputType == TextInputType.visiblePassword
            ? GestureDetector(
                onTap: () => setState(() => _isObscured = !_isObscured),
                child: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                  color: NeoColors.outline,
                ),
              )
            : null,
      ),
    );
  }

  Widget? _prefixIcon() {
    if (widget.textInputType == TextInputType.visiblePassword) {
      return Icon(Icons.lock_outline, color: NeoColors.outline);
    } else if (widget.textInputType == TextInputType.emailAddress) {
      return Icon(Icons.email_outlined, color: NeoColors.outline);
    } else if (widget.textInputType == TextInputType.phone) {
      return Icon(Icons.phone_outlined, color: NeoColors.outline);
    }
    return null;
  }

  OutlineInputBorder _border({bool focused = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(
        color: focused ? NeoColors.cyan : NeoColors.cyan.withValues(alpha: 0.25),
      ),
    );
  }
}
