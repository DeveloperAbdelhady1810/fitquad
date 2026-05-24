import 'package:flutter/material.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';

class CustomDropdown<T> extends StatefulWidget {
  final List<T> items;
  final T? value;
  final String hint;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;
  final double maxHeight;

  const CustomDropdown({
    super.key,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
    required this.hint,
    this.value,
    this.maxHeight = 220,
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Header
        GestureDetector(
          onTap: () => setState(() => _isOpen = !_isOpen),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400),
              color: AppColors.secondary
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.value == null
                      ? widget.hint
                      : widget.labelBuilder(widget.value as T),
                  style: AppTextStyles.font14GreyRegular
                ),
                AnimatedRotation(
                  turns: _isOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child:  Icon(Icons.keyboard_arrow_down, color: AppColors.grey,),
                ),
              ],
            ),
          ),
        ),

        if (_isOpen)
          Container(
            margin: const EdgeInsets.only(top: 6),
            constraints: BoxConstraints(maxHeight: widget.maxHeight),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              color: Colors.white,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.items.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: Colors.grey.shade200,
              ),
              itemBuilder: (_, index) {
                final item = widget.items[index];
                final isSelected = item == widget.value;

                return ListTile(
                  title: Text(
                    widget.labelBuilder(item),
                    style: TextStyle(
                      fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    widget.onChanged(item);
                    setState(() => _isOpen = false);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
