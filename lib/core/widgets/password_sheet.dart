import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_text_styles.dart';
import 'custom_button.dart';
import 'custom_text_feild.dart';
import 'dart:math';

class PasswordSheet {
  static Future<void> show({
    required BuildContext context,
    final String? Function(String?)? validator,
    required void Function({String? newPassword}) onChanged,
  }) {
    final controllerPassword = TextEditingController();

    String generatePassword(int length) {
      const chars =
          'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#\$%&*';
      Random rnd = Random();
      return String.fromCharCodes(
        Iterable.generate(
          length,
              (_) => chars.codeUnitAt(rnd.nextInt(chars.length)),
        ),
      );
    }

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 25,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Change Password', style: AppTextStyles.font16BlackBold),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text('Enter new password or generate one',
                  style: AppTextStyles.font14GreyRegular),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      controller: controllerPassword,
                      hintText: 'Password',
                      textInputType: TextInputType.text,
                      validator: validator,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      controllerPassword.text = generatePassword(10);
                    },
                    child:  Text('Generate' , style: AppTextStyles.font14BlackRegular,),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              CustomButton(
                text: 'Save',
                onPressed: () {
                  onChanged(
                    newPassword: controllerPassword.text.isNotEmpty
                        ? controllerPassword.text
                        : null,
                  );
                  context.pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
