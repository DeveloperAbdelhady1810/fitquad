import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_text_styles.dart';

class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.rating, this.size = 16});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        RatingBarIndicator(
          rating: rating,
          itemBuilder: (context, index) =>
              Icon(Icons.star, color:Colors.yellow),
          itemCount: 5,
          itemSize: size.r,
          unratedColor: Colors.yellow.withValues(alpha: 0.3),
        ),
        SizedBox(width: 4.w),
        Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Text(
            "(${rating.toStringAsFixed(1)})",
            style: AppTextStyles.font14GreyRegular.copyWith(
              fontSize: (size * 0.75).sp,
            ),
          ),
        ),
      ],
    );
  }
}
