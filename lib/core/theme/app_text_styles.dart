
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../helpers/font_weight_helper.dart';
import 'app_colors.dart';


class InterTextStyle extends TextStyle {
  const InterTextStyle({
    super.fontSize,
    super.fontWeight,
    super.fontStyle,
    super.color,
    super.letterSpacing,
    super.height,
    super.decoration,
  }) : super(fontFamily:'Inter');
}


class AppTextStyles {
  const AppTextStyles._();

//// black
  static TextStyle font16BlackBold = InterTextStyle(
    fontSize: 16.sp,
    color: AppColors.black,
    fontWeight: FontWeightHelper.bold,
  );
  static TextStyle font16BlackRegular= InterTextStyle(
    fontSize: 16.sp,
    color: AppColors.black,
    fontWeight: FontWeightHelper.regular,
  );
  static TextStyle font20BlackRegular= InterTextStyle(
    fontSize: 20.sp,
    color: AppColors.black,
    fontWeight: FontWeightHelper.regular,
  );

  static TextStyle font25BlackRegular = InterTextStyle(
    fontSize: 25.sp,
    color: AppColors.black,
    fontWeight: FontWeightHelper.regular,
  );

  static TextStyle font14BlackRegular = InterTextStyle(
    fontSize: 14.sp,
    color: AppColors.black,
    fontWeight: FontWeightHelper.regular,
  );




  //// white

  static TextStyle font14WhiteRegular = InterTextStyle(
    fontSize: 14.sp,
    color: AppColors.white,
    fontWeight: FontWeightHelper.regular,
  );

  static TextStyle font16WhiteBold = InterTextStyle(
    fontSize: 16.sp,
    color: AppColors.white,
    fontWeight: FontWeightHelper.bold,
  );

  static TextStyle font25WhiteRegular = InterTextStyle(
    fontSize: 25.sp,
    color: AppColors.white,
    fontWeight: FontWeightHelper.regular,
  );

  static TextStyle font16WhiteRegular = InterTextStyle(
    fontSize: 16.sp,
    color: AppColors.white,
    fontWeight: FontWeightHelper.regular,
  );

  static TextStyle font20WhiteRegular = InterTextStyle(
    fontSize: 20.sp,
    color: AppColors.white,
    fontWeight: FontWeightHelper.regular,
  );


  ///grey
  static TextStyle font14GreyRegular = InterTextStyle(
    fontSize: 14.sp,
    color: AppColors.grey,
    fontWeight: FontWeightHelper.regular,
  );

  static TextStyle font16GreyBold = InterTextStyle(
    fontSize: 16.sp,
    color: AppColors.grey,
    fontWeight: FontWeightHelper.bold,
  );

  static TextStyle font25GreyRegular = InterTextStyle(
    fontSize: 25.sp,
    color: AppColors.grey,
    fontWeight: FontWeightHelper.regular,
  );

  static TextStyle font16GreyRegular = InterTextStyle(
    fontSize: 16.sp,
    color: AppColors.grey,
    fontWeight: FontWeightHelper.regular,
  );

  static TextStyle font20GreyRegular = InterTextStyle(
    fontSize: 20.sp,
    color: AppColors.grey,
    fontWeight: FontWeightHelper.regular,
  );

  static TextStyle font24GreyBold = InterTextStyle(
    fontSize: 24.sp,
    color: AppColors.grey,
    fontWeight: FontWeightHelper.bold,
  );



  static TextStyle font16TealRegular = InterTextStyle(
    fontSize: 16.sp,
    color: AppColors.teal,
    fontWeight: FontWeightHelper.regular,
  );
}