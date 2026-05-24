import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../generated/l10n.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    this.hintText,
    required this.textInputType,
    this.validator,
    this.icon,
    this.initialValue,
    this.maxLines,
    this.onChanged,
    this.minLines,
    this.controller,
    this.labelText,
    this.inputFormatters,
    this.hintWidget,
  });
  final String? labelText;
  final int? maxLines;
  final IconData? icon;
  final String? hintText;
  final int? minLines;
  final TextInputType textInputType;
  final String? Function(String?)? validator;
  final void Function(String?)? onChanged;
  final String? initialValue;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? hintWidget;
  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool _isObscured;
  late bool? showFields = false;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.textInputType == TextInputType.visiblePassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      initialValue: widget.initialValue,
      obscureText: _isObscured,
      inputFormatters: widget.inputFormatters,
      onChanged: widget.onChanged,
      cursorColor: AppColors.teal,
      maxLines: widget.maxLines ?? 1,
      minLines: widget.minLines ?? 1,
      keyboardType: widget.textInputType,
      textAlign: TextAlign.start,
      style: AppTextStyles.font16GreyRegular,

      validator:
          widget.validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return S.of(context).required_field;
            }
            return null;
          },

      decoration: InputDecoration(
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.red, width: 1),
        ),
        errorStyle: AppTextStyles.font14BlackRegular.copyWith(
          color: AppColors.red,
          height: 1.2,
          overflow: TextOverflow.visible,
        ),
        errorMaxLines: 3,
        labelText: widget.labelText,
        hintText: widget.hintText,
        hint: widget.hintWidget,

        labelStyle: AppTextStyles.font16BlackBold.copyWith(
          color: AppColors.grey,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: AppTextStyles.font14WhiteRegular.copyWith(
          color: AppColors.grey,
        ),
        filled: true,
        fillColor: AppColors.black.withAlpha((0.2 * 255).toInt()),
        border: _buildBorder(),
        enabledBorder: _buildBorder(),
        focusedBorder: _buildBorder(focused: true),
        suffixIcon: _buildSuffixIcon(),
        prefixIcon:  _buildPrefixIcon(),

      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.textInputType == TextInputType.visiblePassword) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _isObscured = !_isObscured;
          });
        },
        child: Icon(
          _isObscured ? Icons.visibility_off : Icons.visibility,
          color: AppColors.grey,
        ),
      );
    }
    return null;
  }
  Widget? _buildPrefixIcon() {
    if (widget.textInputType == TextInputType.visiblePassword) {
      return const Icon(Icons.lock_outline);
    } else if (widget.textInputType == TextInputType.emailAddress) {
      return const Icon(Icons.email);
    } else if (widget.textInputType == TextInputType.phone) {
      return const Icon(Icons.phone);
    } else if (widget.icon != null) {
      return Icon(widget.icon);
    }
    return null;
  }

  OutlineInputBorder _buildBorder({bool focused = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.grey, width: 1),
    );
  }
}
