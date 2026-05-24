import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/core/helpers/spacing.dart';
import 'package:gym_app/core/widgets/custom_button.dart';
import 'package:gym_app/core/widgets/custom_tab_bar.dart';
import 'package:gym_app/core/widgets/custom_text_feild.dart';
import 'package:gym_app/features/coach/home/manager/coach_cubit.dart';

import '../../../../../core/helpers/app_decoration.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../generated/l10n.dart';

Future<void> showBroadcastDialog(BuildContext context) async {
  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (dialogContext) {
      final s = S.of(context);
      return BlocProvider.value(
        value: context.read<CoachCubit>(),

        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.35,
            padding: const EdgeInsets.all(10),
            decoration: AppDecorations.containerDecoration.copyWith(
              color: AppColors.primary,
            ),
            child: BlocBuilder<CoachCubit, CoachState>(
              builder: (context, state) {
                if (state is CoachesLoaded) {
                  return DefaultTabController(
                    length: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(
                            s.broadcast_message,
                            style: AppTextStyles.font16WhiteBold,
                          ),
                          trailing: IconButton(
                            onPressed: () => context.pop(),
                            icon: Icon(Icons.close, color: AppColors.grey),
                          ),
                        ),
                        vGap(10),
                        Text(
                          s.recipients,
                          style: AppTextStyles.font14WhiteRegular,
                        ),
                        vGap(5),
                        CustomTabBar(
                          tabs: [
                            Tab(text: s.all_members),
                            Tab(text: s.low_activity),
                          ],
                        ),
                        vGap(10),
                        Expanded(
                          child: TabBarView(
                            children: [
                              CustomTextFormField(
                                maxLines: 3,
                                textInputType: TextInputType.text,
                                hintText: s.type_your_announcement,
                              ),
                              CustomTextFormField(
                                maxLines: 3,
                                textInputType: TextInputType.text,
                                hintText: s.type_your_announcement,

                              ),
                            ],
                          ),
                        ),

                        vGap(20),
                        CustomButton(
                          text: s.send,
                          onPressed: () => context.pop(),
                          color: Colors.purple,
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ),
      );
    },
  );
}
