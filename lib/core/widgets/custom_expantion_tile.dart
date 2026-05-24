import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CustomExpansionTile extends StatelessWidget {
  final String title;
  final String disc;
  const CustomExpansionTile({super.key, required this.title, required this.disc});

  @override
  Widget build(BuildContext context) {
    return  Container(
      padding: REdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ExpansionTile(
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        shape: Border.all(color: Colors.transparent),

        collapsedShape: Border.all(color: Colors.transparent),
        title: Text(title , style: AppTextStyles.font16BlackRegular,),
        children: [
          Padding(
            padding:  REdgeInsets.all(8.0),
            child: Text(
              disc,
              style:AppTextStyles.font16BlackRegular,
            ),
          ),
        ],
      ),
    );
  }
}
