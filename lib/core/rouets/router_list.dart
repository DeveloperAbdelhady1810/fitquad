import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_app/features/admin/ui/views/admin_view.dart';
import 'package:gym_app/features/auth/manager/onboarding_cubit.dart';
import 'package:gym_app/features/auth/ui/views/sign_up_view.dart';
import 'package:gym_app/features/auth/ui/widgets/loading_screen.dart';
import 'package:gym_app/features/coach/chat/manager/messages_cubit.dart';
import 'package:gym_app/features/coach/home/manager/coach_cubit.dart';
import 'package:gym_app/features/coach/home/ui/widgets/member_profile_screen.dart';
import 'package:gym_app/features/member/eat/widgets/nutrition_overview_screen.dart';
import 'package:gym_app/features/member/eat/widgets/nutrition_plan_screen.dart';
import 'package:gym_app/features/member/eat/widgets/plan_ready_screen.dart';
import 'package:gym_app/features/member/home/manager/member_cubit.dart';
import 'package:gym_app/features/member/home/ui/widgets/choose_coach_screen.dart';
import 'package:gym_app/features/member/home/ui/widgets/request_sent_screen.dart';
import 'package:gym_app/features/member/home/ui/widgets/week_summary_screen.dart';
import 'package:gym_app/features/member/gym/ui/gym_selection_screen.dart';
import 'package:gym_app/features/member/inbody/manager/inbody_cubit.dart';
import 'package:gym_app/features/member/gamification/badges_screen.dart';
import 'package:gym_app/features/member/community/community_feed_screen.dart';
import 'package:gym_app/features/member/community/leaderboard_screen.dart';
import 'package:gym_app/features/member/home/ui/views/workout_active_screen.dart';
import 'package:gym_app/features/member/train/widgets/workout_history_screen.dart';
import 'package:gym_app/features/member/notifications/notifications_screen.dart';
import 'package:gym_app/features/member/payment/ui/payment_webview_screen.dart';
import 'package:gym_app/features/member/inbody/ui/inbody_form_screen.dart';
import 'package:gym_app/features/member/inbody/ui/inbody_screen.dart';
import 'package:gym_app/features/member/profile/ui/widgets/profile_tab.dart';
import 'package:gym_app/features/member/train/widgets/design_manually_screen.dart';
import 'package:gym_app/features/member/partner_gyms/ui/partner_gyms_screen.dart';
import 'package:gym_app/features/member/partner_gyms/ui/my_gym_memberships_screen.dart';

import '../../features/auth/ui/views/login_view.dart';
import '../../features/auth/ui/views/splash_screen.dart';
import '../../features/auth/ui/views/survey_view.dart';
import '../../features/coach/home/ui/views/coach_bottom_nav_bar_view.dart';
import '../../features/member/data/models/member_model.dart';
import '../../features/member/eat/widgets/design_nutritio_manualy_screen.dart';
import '../../features/member/eat/widgets/meal_card.dart';
import '../../features/member/home/ui/views/bottom_nav_bar_view.dart';
import '../../features/member/shop/ui/views/cart_view.dart';
import '../enums/choose_coach.dart';

class RoutesList {
  static final List<RouteBase> all = [
    //toDo auth-----------------------------------------------------
    GoRoute(
      path: SplashScreen.routeName,
      builder: (context, state) => const SplashScreen(),
    ),

    GoRoute(
      path: LoginView.routeName,
      builder: (context, state) => const LoginView(),
    ),

    GoRoute(
      path: SignUpView.routeName,
      builder: (context, state) => const SignUpView(),
    ),

    GoRoute(
      path: OnboardingView.routeName,

      builder: (context, state) => BlocProvider(
        create: (_) => OnboardingCubit(),
        child: OnboardingView(),
      ),
    ),

    //todo home ---------------------------------------------
    GoRoute(
      path: BottomNavBarView.routeName,
      builder: (context, state) => const BottomNavBarView(),
    ),

    GoRoute(
      path: ProfileScreen.routeName,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: ChooseCoachScreen.routeName,
      builder: (context, state) {
        final source = state.extra is ChooseCoachSource
            ? (state.extra as ChooseCoachSource) == ChooseCoachSource.train
                ? 'train'
                : 'eat'
            : null;
        return BlocProvider(
          create: (context) => MemberCubit()..loadCoaches(source: source),
          child: const ChooseCoachScreen(),
        );
      },
    ),
    //todo cart -----------------------------------------------------
    GoRoute(
      path: CartView.routeName,
      builder: (context, state) => const CartView(),
    ),
    // todo coach ---------------------------------------------------
    GoRoute(
      path: CoachBottomNavBarView.routeName,

      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => MessagesCubit()),
          BlocProvider(create: (_) => CoachCubit()..getCoachSessions('1')),
        ],

        child: CoachBottomNavBarView(),
      ),
    ),

    GoRoute(
      path: MemberProfileScreen.routeName,

      builder: (context, state) {
        final member = state.extra as MemberModel;

        return BlocProvider(

        create: (_) => CoachCubit()..getCoachSessions('1'),
          child: MemberProfileScreen(member: member,),
        );
      },
    ),

    GoRoute(
      path: AdminView.routeName,
      builder: (context, state) => const AdminView(),
    ),


    GoRoute(
      path: LoadingScreen.routeName,
      builder: (context, state) => const LoadingScreen(),
    ),
    GoRoute(
      path: DesignPlanManuallyScreen.routeName,
      builder: (context, state) => const DesignPlanManuallyScreen(),
    ),

    GoRoute(
      path: RequestSentScreen.routeName,
      builder: (context, state) => const RequestSentScreen(),
    ),

    GoRoute(
      path: PlanReadyScreen.routeName,

      builder: (context, state) {
        final source = state.extra as ChooseCoachSource;
        return PlanReadyScreen(source:source,);
  }
    ),

    GoRoute(
      path: NutritionPlanScreen.routeName,
      builder: (context, state) => const NutritionPlanScreen(),
    ),

    GoRoute(
      path: DesignNutritionManuallyScreen.routeName,
      builder: (context, state) => const DesignNutritionManuallyScreen(),
    ),


    GoRoute(
      path: WeekSummaryScreen.routeName,
      builder: (context, state) {
        final weekPlan =
        state.extra as List<Map<String, dynamic>>;

        return WeekSummaryScreen(weekPlan: weekPlan,);
      }
    ),

    GoRoute(
      path: NutritionOverviewScreen.routeName,
      builder: (context, state) {
        final meals = state.extra as List<MealModel>;

        return NutritionOverviewScreen(
          meals: meals,
        );
      },
    ),

    GoRoute(
      path: InBodyScreen.routeName,
      builder: (context, state) => const InBodyScreen(),
    ),

    GoRoute(
      path: InBodyFormScreen.routeName,
      builder: (context, state) => BlocProvider(
        create: (_) => InBodyCubit(),
        child: const InBodyFormScreen(),
      ),
    ),

    GoRoute(
      path: GymSelectionScreen.routeName,
      builder: (context, state) => const GymSelectionScreen(),
    ),

    GoRoute(
      path: NotificationsScreen.routeName,
      builder: (context, state) => const NotificationsScreen(),
    ),

    GoRoute(
      path: PaymentWebviewScreen.routeName,
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        return PaymentWebviewScreen(
          paymentUrl: args['payment_url'] as String,
          coachName: args['coach_name'] as String,
          totalAmount: (args['total_amount'] as num).toDouble(),
        );
      },
    ),

    GoRoute(
      path: BadgesScreen.routeName,
      builder: (context, state) => const BadgesScreen(),
    ),

    GoRoute(
      path: WorkoutActiveScreen.routeName,
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        return WorkoutActiveScreen(
          exercises: List<Map<String, dynamic>>.from(
              args['exercises'] as List),
          planTitle: args['plan_title'] as String,
        );
      },
    ),

    GoRoute(
      path: WorkoutHistoryScreen.routeName,
      builder: (context, state) => const WorkoutHistoryScreen(),
    ),

    GoRoute(
      path: CommunityFeedScreen.routeName,
      builder: (context, state) => const CommunityFeedScreen(),
    ),

    GoRoute(
      path: LeaderboardScreen.routeName,
      builder: (context, state) => const LeaderboardScreen(),
    ),

    GoRoute(
      path: PartnerGymsScreen.routeName,
      builder: (context, state) => const PartnerGymsScreen(),
    ),

    GoRoute(
      path: MyGymMembershipsScreen.routeName,
      builder: (context, state) => const MyGymMembershipsScreen(),
    ),

  ];
}
