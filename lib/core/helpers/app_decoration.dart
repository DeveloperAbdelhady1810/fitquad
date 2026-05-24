import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';


class AppDecorations {
  AppDecorations._(); // private constructor to prevent instantiation

  static BoxDecoration get containerDecoration => BoxDecoration(
    color: AppColors.secondary,
    border: Border.all(color: Colors.grey),
    borderRadius: BorderRadius.circular(14.r),
  );

  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(14),
     boxShadow: [
       BoxShadow(
         blurRadius: 6,
         color: Colors.black45,
         offset: Offset(0, 0),

       ),
     ]
  );

  static BoxDecoration get greyContainerDecoration => BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(14),

  );

}