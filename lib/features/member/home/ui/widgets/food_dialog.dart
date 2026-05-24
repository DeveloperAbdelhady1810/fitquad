import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/features/member/home/ui/widgets/eaten_today_card.dart';
import 'package:gym_app/features/member/home/ui/widgets/food_search_dialog.dart';

import '../../../../../core/helpers/app_decoration.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../generated/l10n.dart';
import '../../manager/food_cubit.dart';

Future<void> showFoodDialog(BuildContext context) async {
  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (dialogContext) {

      return BlocProvider.value(
        value: context.read<FoodCubit>(),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: const EdgeInsets.all(10),
            decoration: AppDecorations.containerDecoration.copyWith(
              color: AppColors.primary,
            ),
            child: BlocBuilder<FoodCubit, FoodState>(
              builder: (context, state) {
                final s = S.of(context);

                if (state is FoodLoaded) {
                  return Column(
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.restaurant_menu,
                          color: AppColors.emerald,
                        ),
                        title: Text(
                          s.log_food,
                          style: AppTextStyles.font16WhiteBold,
                        ),

                        trailing: IconButton(
                          onPressed: () => context.pop(),
                          icon: Icon(Icons.close, color: AppColors.grey),
                        ),
                      ),

                      const Divider(),
                      vGap(10),
                      ListTile(
                        leading: Icon(Icons.refresh, color: AppColors.grey),
                        title: Text(
                          s.eaten_today.toUpperCase(),
                          style: AppTextStyles.font14GreyRegular,
                        ),
                      ),

                BlocBuilder<FoodCubit, FoodState>(
                builder: (context, state) {
                if (state is! FoodLoaded) return const SizedBox();

                if (state.loggedFoods.isEmpty) {
                return const Text(
                "No food logged yet",
                style: TextStyle(color: Colors.grey),
                );
                }

                return Column(
                children: state.loggedFoods
                    .map((food) => EatenTodayCard(foodModel: food,))
                    .toList(),
                );
                },
                ),

                      GestureDetector(
                        onTap: () =>showSearchFoodDialog(context) ,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.search),
                              SizedBox(width: 8),
                              Text("I ate something else..."),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
    },
  );
}
