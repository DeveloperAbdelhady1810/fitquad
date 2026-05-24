import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/widgets/custom_tab_bar.dart';

import '../../../../../core/enums/food_enum.dart';
import '../../../../../core/helpers/app_decoration.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../generated/l10n.dart';
import '../../manager/food_cubit.dart';

Future<void> showSearchFoodDialog(BuildContext context) async {
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


                if (state is FoodLoaded) {
                  final s = S.of(context);
                  final cubit = context.read<FoodCubit>();
                  final categories = FoodCategory.values;

                  return DefaultTabController(
                    length: categories.length,
                    child: Column(
                      children: [
                        ListTile(
                          leading: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => context.pop(),
                                icon: Icon(Icons.arrow_back_outlined, color: AppColors.grey),
                              ),
                              Icon(Icons.restaurant_menu, color: AppColors.emerald),
                            ],
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

                        CustomTabBar(
                          isScrollable: true,
                          tabs: categories.map((c) => Text(c.name)).toList(),
                          onTap: (index) {
                            cubit.changeCategory(categories[index]);
                          },
                        ),

                        Expanded(
                          child: TabBarView(
                            children: categories.map((category) {
                              final foods = category == FoodCategory.all
                                  ? state.foods
                                  : state.foods
                                  .where((f) => f.category == category)
                                  .toList();

                              return ListView.builder(
                                itemCount: foods.length,
                                itemBuilder: (context, index) {
                                  final food = foods[index];

                                  return

                                    ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: AppColors.secondary,
                                      radius: 25.r,
                                      child: Text('🍴' , style: AppTextStyles.font16GreyRegular,),
                                    ),
                                    title: Row(
                                      textBaseline:TextBaseline.ideographic ,
                                      children: [
                                        Text(food.nameEn, style: AppTextStyles.font16WhiteBold,),
                                        hGap(5),
                                        Text(food.nameAr, style: AppTextStyles.font14GreyRegular,),
                                      ],
                                    ),
                                    subtitle: Row(
                                      children: [
                                        Text('${food.calories} cal |',style: AppTextStyles.font14GreyRegular,),
                                        Text(
                                          ' ${food.protein}g protein', style: AppTextStyles.font14GreyRegular.copyWith(color: Colors.deepOrange),

                                        ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(
                                        food.isLogged
                                            ? Icons.check_circle
                                            : Icons.add_circle_outline,
                                        color:
                                        food.isLogged ? Colors.green : Colors.grey,
                                      ),
                                      onPressed: () {
                                        cubit.logFood(food.id);
                                        context.pop();
                                        context.pop();

                                      },
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
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
