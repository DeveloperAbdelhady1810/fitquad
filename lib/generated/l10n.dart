// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `IronPulse`
  String get app_name {
    return Intl.message('IronPulse', name: 'app_name', desc: '', args: []);
  }

  /// `Your complete fitness ecosystem`
  String get app_tagline {
    return Intl.message(
      'Your complete fitness ecosystem',
      name: 'app_tagline',
      desc: '',
      args: [],
    );
  }

  /// `Welcome Back`
  String get welcome_back {
    return Intl.message(
      'Welcome Back',
      name: 'welcome_back',
      desc: '',
      args: [],
    );
  }

  /// `Select your role to continue`
  String get select_role {
    return Intl.message(
      'Select your role to continue',
      name: 'select_role',
      desc: '',
      args: [],
    );
  }

  /// `Member`
  String get member {
    return Intl.message('Member', name: 'member', desc: '', args: []);
  }

  /// `Coach`
  String get coach {
    return Intl.message('Coach', name: 'coach', desc: '', args: []);
  }

  /// `Admin`
  String get admin {
    return Intl.message('Admin', name: 'admin', desc: '', args: []);
  }

  /// `Log In`
  String get login {
    return Intl.message('Log In', name: 'login', desc: '', args: []);
  }

  /// `Don't have an account?`
  String get no_account {
    return Intl.message(
      'Don\'t have an account?',
      name: 'no_account',
      desc: '',
      args: [],
    );
  }

  /// `Email or phone`
  String get email_or_phone {
    return Intl.message(
      'Email or phone',
      name: 'email_or_phone',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message('Password', name: 'password', desc: '', args: []);
  }

  /// `Required field`
  String get required_field {
    return Intl.message(
      'Required field',
      name: 'required_field',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account?`
  String get already_have_account {
    return Intl.message(
      'Already have an account?',
      name: 'already_have_account',
      desc: '',
      args: [],
    );
  }

  /// `Log in`
  String get log_in {
    return Intl.message('Log in', name: 'log_in', desc: '', args: []);
  }

  /// `Sign up`
  String get sign_up {
    return Intl.message('Sign up', name: 'sign_up', desc: '', args: []);
  }

  /// `Create account`
  String get create_account {
    return Intl.message(
      'Create account',
      name: 'create_account',
      desc: '',
      args: [],
    );
  }

  /// `Phone (optional)`
  String get phone_optional {
    return Intl.message(
      'Phone (optional)',
      name: 'phone_optional',
      desc: '',
      args: [],
    );
  }

  /// `What's your main goal?`
  String get main_goal_question {
    return Intl.message(
      'What\'s your main goal?',
      name: 'main_goal_question',
      desc: '',
      args: [],
    );
  }

  /// `This helps us personalize your training plan.`
  String get main_goal_description {
    return Intl.message(
      'This helps us personalize your training plan.',
      name: 'main_goal_description',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get continu {
    return Intl.message('Continue', name: 'continu', desc: '', args: []);
  }

  /// `Build Muscle`
  String get build_muscle {
    return Intl.message(
      'Build Muscle',
      name: 'build_muscle',
      desc: '',
      args: [],
    );
  }

  /// `Hypertrophy & Strength`
  String get hypertrophy {
    return Intl.message(
      'Hypertrophy & Strength',
      name: 'hypertrophy',
      desc: '',
      args: [],
    );
  }

  /// `Lose Weight`
  String get lose_weight {
    return Intl.message('Lose Weight', name: 'lose_weight', desc: '', args: []);
  }

  /// `Fat Loss & Toning`
  String get fat_loss_toning {
    return Intl.message(
      'Fat Loss & Toning',
      name: 'fat_loss_toning',
      desc: '',
      args: [],
    );
  }

  /// `Endurance`
  String get endurance {
    return Intl.message('Endurance', name: 'endurance', desc: '', args: []);
  }

  /// `Cardio & Stamina`
  String get cardio_stamina {
    return Intl.message(
      'Cardio & Stamina',
      name: 'cardio_stamina',
      desc: '',
      args: [],
    );
  }

  /// `Flexibility`
  String get flexibility {
    return Intl.message('Flexibility', name: 'flexibility', desc: '', args: []);
  }

  /// `Mobility & Health`
  String get mobility_health {
    return Intl.message(
      'Mobility & Health',
      name: 'mobility_health',
      desc: '',
      args: [],
    );
  }

  /// `Step`
  String get step {
    return Intl.message('Step', name: 'step', desc: '', args: []);
  }

  /// `Training Frequency`
  String get training_frequency {
    return Intl.message(
      'Training Frequency',
      name: 'training_frequency',
      desc: '',
      args: [],
    );
  }

  /// `Back`
  String get back {
    return Intl.message('Back', name: 'back', desc: '', args: []);
  }

  /// `How many days a week can you train?`
  String get training_question {
    return Intl.message(
      'How many days a week can you train?',
      name: 'training_question',
      desc: '',
      args: [],
    );
  }

  /// `days/week`
  String get days_per_week {
    return Intl.message('days/week', name: 'days_per_week', desc: '', args: []);
  }

  /// `Recommended: 3-5 days for consistent results.`
  String get recommended_days {
    return Intl.message(
      'Recommended: 3-5 days for consistent results.',
      name: 'recommended_days',
      desc: '',
      args: [],
    );
  }

  /// `Session Duration`
  String get session_duration {
    return Intl.message(
      'Session Duration',
      name: 'session_duration',
      desc: '',
      args: [],
    );
  }

  /// `How much time do you have per session?`
  String get session_duration_question {
    return Intl.message(
      'How much time do you have per session?',
      name: 'session_duration_question',
      desc: '',
      args: [],
    );
  }

  /// `Mins`
  String get mins {
    return Intl.message('Mins', name: 'mins', desc: '', args: []);
  }

  /// `Express`
  String get express {
    return Intl.message('Express', name: 'express', desc: '', args: []);
  }

  /// `Standard`
  String get standard {
    return Intl.message('Standard', name: 'standard', desc: '', args: []);
  }

  /// `Optimal`
  String get optimal {
    return Intl.message('Optimal', name: 'optimal', desc: '', args: []);
  }

  /// `Extended`
  String get extended {
    return Intl.message('Extended', name: 'extended', desc: '', args: []);
  }

  /// `All Set!`
  String get all_set {
    return Intl.message('All Set!', name: 'all_set', desc: '', args: []);
  }

  /// `We have everything we need to build your personalized training and nutrition plan.`
  String get plan_ready_message {
    return Intl.message(
      'We have everything we need to build your personalized training and nutrition plan.',
      name: 'plan_ready_message',
      desc: '',
      args: [],
    );
  }

  /// `Frequency:`
  String get frequency {
    return Intl.message('Frequency:', name: 'frequency', desc: '', args: []);
  }

  /// `Goal:`
  String get goal {
    return Intl.message('Goal:', name: 'goal', desc: '', args: []);
  }

  /// `Duration:`
  String get duration {
    return Intl.message('Duration:', name: 'duration', desc: '', args: []);
  }

  /// `Generate Plan`
  String get generate_plan {
    return Intl.message(
      'Generate Plan',
      name: 'generate_plan',
      desc: '',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message('Home', name: 'home', desc: '', args: []);
  }

  /// `Train`
  String get train {
    return Intl.message('Train', name: 'train', desc: '', args: []);
  }

  /// `Eat`
  String get eat {
    return Intl.message('Eat', name: 'eat', desc: '', args: []);
  }

  /// `Shop`
  String get shop {
    return Intl.message('Shop', name: 'shop', desc: '', args: []);
  }

  /// `Me`
  String get me {
    return Intl.message('Me', name: 'me', desc: '', args: []);
  }

  /// `Pro Member`
  String get pro_member {
    return Intl.message('Pro Member', name: 'pro_member', desc: '', args: []);
  }

  /// `Account`
  String get account {
    return Intl.message('Account', name: 'account', desc: '', args: []);
  }

  /// `Personal Details`
  String get personal_details {
    return Intl.message(
      'Personal Details',
      name: 'personal_details',
      desc: '',
      args: [],
    );
  }

  /// `Membership & Billing`
  String get membership_billing {
    return Intl.message(
      'Membership & Billing',
      name: 'membership_billing',
      desc: '',
      args: [],
    );
  }

  /// `Visit History`
  String get visit_history {
    return Intl.message(
      'Visit History',
      name: 'visit_history',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message('Settings', name: 'settings', desc: '', args: []);
  }

  /// `Notifications`
  String get notifications {
    return Intl.message(
      'Notifications',
      name: 'notifications',
      desc: '',
      args: [],
    );
  }

  /// `EN`
  String get language {
    return Intl.message('EN', name: 'language', desc: '', args: []);
  }

  /// `Language`
  String get language_option {
    return Intl.message(
      'Language',
      name: 'language_option',
      desc: '',
      args: [],
    );
  }

  /// `Log Out`
  String get log_out {
    return Intl.message('Log Out', name: 'log_out', desc: '', args: []);
  }

  /// `All`
  String get category_all {
    return Intl.message('All', name: 'category_all', desc: '', args: []);
  }

  /// `Supplements`
  String get category_supplements {
    return Intl.message(
      'Supplements',
      name: 'category_supplements',
      desc: '',
      args: [],
    );
  }

  /// `Apparel`
  String get category_apparel {
    return Intl.message(
      'Apparel',
      name: 'category_apparel',
      desc: '',
      args: [],
    );
  }

  /// `Gear`
  String get category_gear {
    return Intl.message('Gear', name: 'category_gear', desc: '', args: []);
  }

  /// `Accessories`
  String get category_accessories {
    return Intl.message(
      'Accessories',
      name: 'category_accessories',
      desc: '',
      args: [],
    );
  }

  /// `My Cart `
  String get my_cart {
    return Intl.message('My Cart ', name: 'my_cart', desc: '', args: []);
  }

  /// `Your cart is empty`
  String get cart_empty {
    return Intl.message(
      'Your cart is empty',
      name: 'cart_empty',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message('Close', name: 'close', desc: '', args: []);
  }

  /// `Start Shopping`
  String get start_shopping {
    return Intl.message(
      'Start Shopping',
      name: 'start_shopping',
      desc: '',
      args: [],
    );
  }

  /// `Market`
  String get market {
    return Intl.message('Market', name: 'market', desc: '', args: []);
  }

  /// `Checkout`
  String get checkout {
    return Intl.message('Checkout', name: 'checkout', desc: '', args: []);
  }

  /// `Search Products`
  String get search_products {
    return Intl.message(
      'Search Products',
      name: 'search_products',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get total {
    return Intl.message('Total', name: 'total', desc: '', args: []);
  }

  /// `Today's Workout`
  String get todays_workout {
    return Intl.message(
      'Today\'s Workout',
      name: 'todays_workout',
      desc: '',
      args: [],
    );
  }

  /// `View Plan`
  String get view_plan {
    return Intl.message('View Plan', name: 'view_plan', desc: '', args: []);
  }

  /// `kcal`
  String get kcal {
    return Intl.message('kcal', name: 'kcal', desc: '', args: []);
  }

  /// `Exercises`
  String get exercises {
    return Intl.message('Exercises', name: 'exercises', desc: '', args: []);
  }

  /// `Start Workout`
  String get start_workout {
    return Intl.message(
      'Start Workout',
      name: 'start_workout',
      desc: '',
      args: [],
    );
  }

  /// `Nutrition`
  String get nutrition {
    return Intl.message('Nutrition', name: 'nutrition', desc: '', args: []);
  }

  /// `Log Meal`
  String get log_meal {
    return Intl.message('Log Meal', name: 'log_meal', desc: '', args: []);
  }

  /// `Calories`
  String get calories {
    return Intl.message('Calories', name: 'calories', desc: '', args: []);
  }

  /// `Protein`
  String get protein {
    return Intl.message('Protein', name: 'protein', desc: '', args: []);
  }

  /// `Activity`
  String get activity {
    return Intl.message('Activity', name: 'activity', desc: '', args: []);
  }

  /// `Kg Weight`
  String get weight_kg {
    return Intl.message('Kg Weight', name: 'weight_kg', desc: '', args: []);
  }

  /// `Hrs Sleep`
  String get sleep_hrs {
    return Intl.message('Hrs Sleep', name: 'sleep_hrs', desc: '', args: []);
  }

  /// `L Water`
  String get water_l {
    return Intl.message('L Water', name: 'water_l', desc: '', args: []);
  }

  /// `No Meal Plan`
  String get no_meal_plan {
    return Intl.message(
      'No Meal Plan',
      name: 'no_meal_plan',
      desc: '',
      args: [],
    );
  }

  /// `Generate a nutrition plan using the AI Coach to see your daily meals.`
  String get generate_nutrition_plan {
    return Intl.message(
      'Generate a nutrition plan using the AI Coach to see your daily meals.',
      name: 'generate_nutrition_plan',
      desc: '',
      args: [],
    );
  }

  /// `No Active Plan`
  String get no_active_plan {
    return Intl.message(
      'No Active Plan',
      name: 'no_active_plan',
      desc: '',
      args: [],
    );
  }

  /// `You haven't generated a personalized training plan yet. Use the AI Coach to get started.`
  String get no_training_plan_yet {
    return Intl.message(
      'You haven\'t generated a personalized training plan yet. Use the AI Coach to get started.',
      name: 'no_training_plan_yet',
      desc: '',
      args: [],
    );
  }

  /// `No products`
  String get no_products {
    return Intl.message('No products', name: 'no_products', desc: '', args: []);
  }

  /// `Generate AI Plan`
  String get generate_ai_plan {
    return Intl.message(
      'Generate AI Plan',
      name: 'generate_ai_plan',
      desc: '',
      args: [],
    );
  }

  /// `Custom Workouts and Nutrition`
  String get custom_workouts_and_nutrition {
    return Intl.message(
      'Custom Workouts and Nutrition',
      name: 'custom_workouts_and_nutrition',
      desc: '',
      args: [],
    );
  }

  /// `Strength`
  String get strength {
    return Intl.message('Strength', name: 'strength', desc: '', args: []);
  }

  /// `Next Step`
  String get next_step {
    return Intl.message('Next Step', name: 'next_step', desc: '', args: []);
  }

  /// `Target Body Shape`
  String get target_body_shape {
    return Intl.message(
      'Target Body Shape',
      name: 'target_body_shape',
      desc: '',
      args: [],
    );
  }

  /// `V-Taper`
  String get v_taper {
    return Intl.message('V-Taper', name: 'v_taper', desc: '', args: []);
  }

  /// `Lean and Toned`
  String get lean_and_toned {
    return Intl.message(
      'Lean and Toned',
      name: 'lean_and_toned',
      desc: '',
      args: [],
    );
  }

  /// `Bulky`
  String get bulky {
    return Intl.message('Bulky', name: 'bulky', desc: '', args: []);
  }

  /// `Athletic`
  String get athletic {
    return Intl.message('Athletic', name: 'athletic', desc: '', args: []);
  }

  /// `Schedule and Training`
  String get schedule_and_training {
    return Intl.message(
      'Schedule and Training',
      name: 'schedule_and_training',
      desc: '',
      args: [],
    );
  }

  /// `Nutrition Preference`
  String get nutrition_preference {
    return Intl.message(
      'Nutrition Preference',
      name: 'nutrition_preference',
      desc: '',
      args: [],
    );
  }

  /// `Balanced`
  String get balanced {
    return Intl.message('Balanced', name: 'balanced', desc: '', args: []);
  }

  /// `Keto`
  String get keto {
    return Intl.message('Keto', name: 'keto', desc: '', args: []);
  }

  /// `Vegan`
  String get vegan {
    return Intl.message('Vegan', name: 'vegan', desc: '', args: []);
  }

  /// `High Protein`
  String get high_protein {
    return Intl.message(
      'High Protein',
      name: 'high_protein',
      desc: '',
      args: [],
    );
  }

  /// `Paleo`
  String get paleo {
    return Intl.message('Paleo', name: 'paleo', desc: '', args: []);
  }

  /// `Profile`
  String get profile {
    return Intl.message('Profile', name: 'profile', desc: '', args: []);
  }

  /// `Schedule`
  String get schedule {
    return Intl.message('Schedule', name: 'schedule', desc: '', args: []);
  }

  /// `Chat`
  String get chat {
    return Intl.message('Chat', name: 'chat', desc: '', args: []);
  }

  /// `Members`
  String get members {
    return Intl.message('Members', name: 'members', desc: '', args: []);
  }

  /// `Senior Coach`
  String get senior_coach {
    return Intl.message(
      'Senior Coach',
      name: 'senior_coach',
      desc: '',
      args: [],
    );
  }

  /// `Edit Profile`
  String get edit_profile {
    return Intl.message(
      'Edit Profile',
      name: 'edit_profile',
      desc: '',
      args: [],
    );
  }

  /// `Experience & Specialization`
  String get experience_specialization {
    return Intl.message(
      'Experience & Specialization',
      name: 'experience_specialization',
      desc: '',
      args: [],
    );
  }

  /// `Experience`
  String get experience {
    return Intl.message('Experience', name: 'experience', desc: '', args: []);
  }

  /// `Specialties`
  String get specialties {
    return Intl.message('Specialties', name: 'specialties', desc: '', args: []);
  }

  /// `Fat Loss`
  String get fat_loss {
    return Intl.message('Fat Loss', name: 'fat_loss', desc: '', args: []);
  }

  /// `Bodybuilding`
  String get bodybuilding {
    return Intl.message(
      'Bodybuilding',
      name: 'bodybuilding',
      desc: '',
      args: [],
    );
  }

  /// `Rehab`
  String get rehab {
    return Intl.message('Rehab', name: 'rehab', desc: '', args: []);
  }

  /// `Availability`
  String get availability {
    return Intl.message(
      'Availability',
      name: 'availability',
      desc: '',
      args: [],
    );
  }

  /// `Show as Available for new members`
  String get show_available_new_members {
    return Intl.message(
      'Show as Available for new members',
      name: 'show_available_new_members',
      desc: '',
      args: [],
    );
  }

  /// `Security`
  String get security {
    return Intl.message('Security', name: 'security', desc: '', args: []);
  }

  /// `Day`
  String get day {
    return Intl.message('Day', name: 'day', desc: '', args: []);
  }

  /// `Week`
  String get week {
    return Intl.message('Week', name: 'week', desc: '', args: []);
  }

  /// `Year`
  String get year {
    return Intl.message('Year', name: 'year', desc: '', args: []);
  }

  /// `Upcoming`
  String get upcoming {
    return Intl.message('Upcoming', name: 'upcoming', desc: '', args: []);
  }

  /// `Ongoing`
  String get ongoing {
    return Intl.message('Ongoing', name: 'ongoing', desc: '', args: []);
  }

  /// `Completed`
  String get completed {
    return Intl.message('Completed', name: 'completed', desc: '', args: []);
  }

  /// `Month`
  String get month {
    return Intl.message('Month', name: 'month', desc: '', args: []);
  }

  /// `Track your progress and view projections based on your plan.`
  String get track_progress {
    return Intl.message(
      'Track your progress and view projections based on your plan.',
      name: 'track_progress',
      desc: '',
      args: [],
    );
  }

  /// `Weight Tracker`
  String get weight_tracker {
    return Intl.message(
      'Weight Tracker',
      name: 'weight_tracker',
      desc: '',
      args: [],
    );
  }

  /// `Log Weight`
  String get log_weight {
    return Intl.message('Log Weight', name: 'log_weight', desc: '', args: []);
  }

  /// `Analysis and Projection`
  String get analysis_projection {
    return Intl.message(
      'Analysis and Projection',
      name: 'analysis_projection',
      desc: '',
      args: [],
    );
  }

  /// `Save Changes`
  String get save_changes {
    return Intl.message(
      'Save Changes',
      name: 'save_changes',
      desc: '',
      args: [],
    );
  }

  /// `Update Current Weight`
  String get update_current_weight {
    return Intl.message(
      'Update Current Weight',
      name: 'update_current_weight',
      desc: '',
      args: [],
    );
  }

  /// `Sleep Log`
  String get sleep_log {
    return Intl.message('Sleep Log', name: 'sleep_log', desc: '', args: []);
  }

  /// `Log your sleep duration to monitor recovery.`
  String get log_sleep_duration {
    return Intl.message(
      'Log your sleep duration to monitor recovery.',
      name: 'log_sleep_duration',
      desc: '',
      args: [],
    );
  }

  /// `Below Recommended Amount`
  String get below_recommended_amount {
    return Intl.message(
      'Below Recommended Amount',
      name: 'below_recommended_amount',
      desc: '',
      args: [],
    );
  }

  /// `Optimal Recovery Zone`
  String get optimal_recovery_zone {
    return Intl.message(
      'Optimal Recovery Zone',
      name: 'optimal_recovery_zone',
      desc: '',
      args: [],
    );
  }

  /// `Why it matters?`
  String get why_it_matters {
    return Intl.message(
      'Why it matters?',
      name: 'why_it_matters',
      desc: '',
      args: [],
    );
  }

  /// `Sleep is when your muscles repair and grow. Aiming for 7-9 hours helps optimize your gains from the "Upper Body Power" plan.`
  String get sleep_importance_description {
    return Intl.message(
      'Sleep is when your muscles repair and grow. Aiming for 7-9 hours helps optimize your gains from the "Upper Body Power" plan.',
      name: 'sleep_importance_description',
      desc: '',
      args: [],
    );
  }

  /// `hrs`
  String get hrs {
    return Intl.message('hrs', name: 'hrs', desc: '', args: []);
  }

  /// `Hydration`
  String get hydration {
    return Intl.message('Hydration', name: 'hydration', desc: '', args: []);
  }

  /// `Keep track of your daily water intake.`
  String get hydration_description {
    return Intl.message(
      'Keep track of your daily water intake.',
      name: 'hydration_description',
      desc: '',
      args: [],
    );
  }

  /// `Daily Goal: 3.0 Liters`
  String get hydration_daily_goal {
    return Intl.message(
      'Daily Goal: 3.0 Liters',
      name: 'hydration_daily_goal',
      desc: '',
      args: [],
    );
  }

  /// `Let's Get Started`
  String get lets_get_started {
    return Intl.message(
      'Let\'s Get Started',
      name: 'lets_get_started',
      desc: '',
      args: [],
    );
  }

  /// `Choose how you want to build your training plan.`
  String get choose_plan_method {
    return Intl.message(
      'Choose how you want to build your training plan.',
      name: 'choose_plan_method',
      desc: '',
      args: [],
    );
  }

  /// `Design manually`
  String get design_manually {
    return Intl.message(
      'Design manually',
      name: 'design_manually',
      desc: '',
      args: [],
    );
  }

  /// `Ask AI Coach`
  String get ask_ai_coach {
    return Intl.message(
      'Ask AI Coach',
      name: 'ask_ai_coach',
      desc: '',
      args: [],
    );
  }

  /// `Real Coach`
  String get real_coach {
    return Intl.message('Real Coach', name: 'real_coach', desc: '', args: []);
  }

  /// `Select your days and exercises`
  String get select_days_exercises {
    return Intl.message(
      'Select your days and exercises',
      name: 'select_days_exercises',
      desc: '',
      args: [],
    );
  }

  /// `Instant personalized plan`
  String get instant_personalized_plan {
    return Intl.message(
      'Instant personalized plan',
      name: 'instant_personalized_plan',
      desc: '',
      args: [],
    );
  }

  /// `Request a professional plan`
  String get request_professional_plan {
    return Intl.message(
      'Request a professional plan',
      name: 'request_professional_plan',
      desc: '',
      args: [],
    );
  }

  /// `Log Food`
  String get log_food {
    return Intl.message('Log Food', name: 'log_food', desc: '', args: []);
  }

  /// `I ate something else`
  String get ate_something_else {
    return Intl.message(
      'I ate something else',
      name: 'ate_something_else',
      desc: '',
      args: [],
    );
  }

  /// `Eaten Today`
  String get eaten_today {
    return Intl.message('Eaten Today', name: 'eaten_today', desc: '', args: []);
  }

  /// `All planned meals completed! 🎉`
  String get all_meals_completed {
    return Intl.message(
      'All planned meals completed! 🎉',
      name: 'all_meals_completed',
      desc: '',
      args: [],
    );
  }

  /// `Logged`
  String get logged {
    return Intl.message('Logged', name: 'logged', desc: '', args: []);
  }

  /// `Upcoming Meals`
  String get upcoming_meals {
    return Intl.message(
      'Upcoming Meals',
      name: 'upcoming_meals',
      desc: '',
      args: [],
    );
  }

  /// `Tap to search the Egyptian Food Database`
  String get tap_search_egyptian_food {
    return Intl.message(
      'Tap to search the Egyptian Food Database',
      name: 'tap_search_egyptian_food',
      desc: '',
      args: [],
    );
  }

  /// `All`
  String get all {
    return Intl.message('All', name: 'all', desc: '', args: []);
  }

  /// `Breakfast`
  String get breakfast {
    return Intl.message('Breakfast', name: 'breakfast', desc: '', args: []);
  }

  /// `Lunch`
  String get lunch {
    return Intl.message('Lunch', name: 'lunch', desc: '', args: []);
  }

  /// `Dinner`
  String get dinner {
    return Intl.message('Dinner', name: 'dinner', desc: '', args: []);
  }

  /// `Dessert`
  String get dessert {
    return Intl.message('Dessert', name: 'dessert', desc: '', args: []);
  }

  /// `Snack`
  String get snack {
    return Intl.message('Snack', name: 'snack', desc: '', args: []);
  }

  /// `Popular Food`
  String get popular_food {
    return Intl.message(
      'Popular Food',
      name: 'popular_food',
      desc: '',
      args: [],
    );
  }

  /// `Food Search`
  String get food_search {
    return Intl.message('Food Search', name: 'food_search', desc: '', args: []);
  }

  /// `Supplements`
  String get supplements {
    return Intl.message('Supplements', name: 'supplements', desc: '', args: []);
  }

  /// `Apparel`
  String get apparel {
    return Intl.message('Apparel', name: 'apparel', desc: '', args: []);
  }

  /// `Gear`
  String get gear {
    return Intl.message('Gear', name: 'gear', desc: '', args: []);
  }

  /// `Accessories`
  String get accessories {
    return Intl.message('Accessories', name: 'accessories', desc: '', args: []);
  }

  /// `Input your own macros and meals`
  String get input_your_own_macros_and_meals {
    return Intl.message(
      'Input your own macros and meals',
      name: 'input_your_own_macros_and_meals',
      desc: '',
      args: [],
    );
  }

  /// `Generate a meal plan instantly`
  String get generate_a_meal_plan_instantly {
    return Intl.message(
      'Generate a meal plan instantly',
      name: 'generate_a_meal_plan_instantly',
      desc: '',
      args: [],
    );
  }

  /// `Request a plan from your trainer`
  String get request_a_plan_from_your_trainer {
    return Intl.message(
      'Request a plan from your trainer',
      name: 'request_a_plan_from_your_trainer',
      desc: '',
      args: [],
    );
  }

  /// `Set manually`
  String get set_manually {
    return Intl.message(
      'Set manually',
      name: 'set_manually',
      desc: '',
      args: [],
    );
  }

  /// `Fuel Your Body`
  String get fuel_your_body {
    return Intl.message(
      'Fuel Your Body',
      name: 'fuel_your_body',
      desc: '',
      args: [],
    );
  }

  /// `Choose how you want to build your nutrition plan`
  String get choose_how_to_build_plan {
    return Intl.message(
      'Choose how you want to build your nutrition plan',
      name: 'choose_how_to_build_plan',
      desc: '',
      args: [],
    );
  }

  /// `AI Coach`
  String get ai_coach {
    return Intl.message('AI Coach', name: 'ai_coach', desc: '', args: []);
  }

  /// `Your personal fitness assistant`
  String get your_personal_fitness_assistant {
    return Intl.message(
      'Your personal fitness assistant',
      name: 'your_personal_fitness_assistant',
      desc: '',
      args: [],
    );
  }

  /// `Hello! I'm your AI Coach. I can help you customize your training, build meal plans, or adjust your goals. What would you like to do today?`
  String get hello_ai_coach {
    return Intl.message(
      'Hello! I\'m your AI Coach. I can help you customize your training, build meal plans, or adjust your goals. What would you like to do today?',
      name: 'hello_ai_coach',
      desc: '',
      args: [],
    );
  }

  /// `Ask your AI Coach`
  String get ask_your_ai_coach {
    return Intl.message(
      'Ask your AI Coach',
      name: 'ask_your_ai_coach',
      desc: '',
      args: [],
    );
  }

  /// `Create new training plan`
  String get create_new_training_plan {
    return Intl.message(
      'Create new training plan',
      name: 'create_new_training_plan',
      desc: '',
      args: [],
    );
  }

  /// `Adjust my workout day`
  String get adjust_my_workout_day {
    return Intl.message(
      'Adjust my workout day',
      name: 'adjust_my_workout_day',
      desc: '',
      args: [],
    );
  }

  /// `I want to lose fat`
  String get i_want_to_lose_fat {
    return Intl.message(
      'I want to lose fat',
      name: 'i_want_to_lose_fat',
      desc: '',
      args: [],
    );
  }

  /// `Make nutrition plan`
  String get make_nutrition_plan {
    return Intl.message(
      'Make nutrition plan',
      name: 'make_nutrition_plan',
      desc: '',
      args: [],
    );
  }

  /// `Strong`
  String get strong {
    return Intl.message('Strong', name: 'strong', desc: '', args: []);
  }

  /// `Focus`
  String get focus {
    return Intl.message('Focus', name: 'focus', desc: '', args: []);
  }

  /// `High`
  String get high {
    return Intl.message('High', name: 'high', desc: '', args: []);
  }

  /// `Intensity`
  String get intensity {
    return Intl.message('Intensity', name: 'intensity', desc: '', args: []);
  }

  /// `Next Set`
  String get next_set {
    return Intl.message('Next Set', name: 'next_set', desc: '', args: []);
  }

  /// `Previous`
  String get previous {
    return Intl.message('Previous', name: 'previous', desc: '', args: []);
  }

  /// `Coach's Proposal`
  String get coach_proposal {
    return Intl.message(
      'Coach\'s Proposal',
      name: 'coach_proposal',
      desc: '',
      args: [],
    );
  }

  /// `Review the details before accepting.`
  String get review_details_before_accepting {
    return Intl.message(
      'Review the details before accepting.',
      name: 'review_details_before_accepting',
      desc: '',
      args: [],
    );
  }

  /// `Target Goal`
  String get target_goal {
    return Intl.message('Target Goal', name: 'target_goal', desc: '', args: []);
  }

  /// `Coach Assigned (Training)`
  String get coach_assigned_training {
    return Intl.message(
      'Coach Assigned (Training)',
      name: 'coach_assigned_training',
      desc: '',
      args: [],
    );
  }

  /// `Weekly Schedule`
  String get weekly_schedule {
    return Intl.message(
      'Weekly Schedule',
      name: 'weekly_schedule',
      desc: '',
      args: [],
    );
  }

  /// `Accept Plan`
  String get accept_plan {
    return Intl.message('Accept Plan', name: 'accept_plan', desc: '', args: []);
  }

  /// `Reject Plan`
  String get reject_plan {
    return Intl.message('Reject Plan', name: 'reject_plan', desc: '', args: []);
  }

  /// `Find a Coach`
  String get find_a_coach {
    return Intl.message(
      'Find a Coach',
      name: 'find_a_coach',
      desc: '',
      args: [],
    );
  }

  /// `Select a pro to build your workout plan`
  String get select_a_pro_to_build_workout {
    return Intl.message(
      'Select a pro to build your workout plan',
      name: 'select_a_pro_to_build_workout',
      desc: '',
      args: [],
    );
  }

  /// `Hire Coach`
  String get hire_coach {
    return Intl.message('Hire Coach', name: 'hire_coach', desc: '', args: []);
  }

  /// `Confirm Request`
  String get confirm_request {
    return Intl.message(
      'Confirm Request',
      name: 'confirm_request',
      desc: '',
      args: [],
    );
  }

  /// `You are about to hire `
  String get you_are_about_to_hire_coach {
    return Intl.message(
      'You are about to hire ',
      name: 'you_are_about_to_hire_coach',
      desc: '',
      args: [],
    );
  }

  /// `Service`
  String get service {
    return Intl.message('Service', name: 'service', desc: '', args: []);
  }

  /// `Turnaround`
  String get turnaround {
    return Intl.message('Turnaround', name: 'turnaround', desc: '', args: []);
  }

  /// `Confirm and Pay`
  String get confirm_and_pay {
    return Intl.message(
      'Confirm and Pay',
      name: 'confirm_and_pay',
      desc: '',
      args: [],
    );
  }

  /// `Request Sent`
  String get request_sent {
    return Intl.message(
      'Request Sent',
      name: 'request_sent',
      desc: '',
      args: [],
    );
  }

  /// `Waiting for Mike Mentzer to create your plan.`
  String get waiting_for_coach {
    return Intl.message(
      'Waiting for Mike Mentzer to create your plan.',
      name: 'waiting_for_coach',
      desc: '',
      args: [],
    );
  }

  /// `Usually takes 24-48 hours.`
  String get usually_takes_time {
    return Intl.message(
      'Usually takes 24-48 hours.',
      name: 'usually_takes_time',
      desc: '',
      args: [],
    );
  }

  /// `Back to Dashboard`
  String get back_to_dashboard {
    return Intl.message(
      'Back to Dashboard',
      name: 'back_to_dashboard',
      desc: '',
      args: [],
    );
  }

  /// `Plan Ready!`
  String get plan_ready {
    return Intl.message('Plan Ready!', name: 'plan_ready', desc: '', args: []);
  }

  /// `Your coach has designed your new workout plan.`
  String get coach_designed_plan {
    return Intl.message(
      'Your coach has designed your new workout plan.',
      name: 'coach_designed_plan',
      desc: '',
      args: [],
    );
  }

  /// `Price`
  String get price {
    return Intl.message('Price', name: 'price', desc: '', args: []);
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Fit`
  String get fit {
    return Intl.message('Fit', name: 'fit', desc: '', args: []);
  }

  /// `Low Activity`
  String get low_activity {
    return Intl.message(
      'Low Activity',
      name: 'low_activity',
      desc: '',
      args: [],
    );
  }

  /// `New`
  String get neww {
    return Intl.message('New', name: 'neww', desc: '', args: []);
  }

  /// `Today's Sessions`
  String get todays_sessions {
    return Intl.message(
      'Today\'s Sessions',
      name: 'todays_sessions',
      desc: '',
      args: [],
    );
  }

  /// `View Full Schedule`
  String get view_full_schedule {
    return Intl.message(
      'View Full Schedule',
      name: 'view_full_schedule',
      desc: '',
      args: [],
    );
  }

  /// `Members to Follow Up`
  String get members_to_follow_up {
    return Intl.message(
      'Members to Follow Up',
      name: 'members_to_follow_up',
      desc: '',
      args: [],
    );
  }

  /// `Open`
  String get open {
    return Intl.message('Open', name: 'open', desc: '', args: []);
  }

  /// `Create Plan`
  String get create_plan {
    return Intl.message('Create Plan', name: 'create_plan', desc: '', args: []);
  }

  /// `Workout Completion Rate`
  String get workout_completion_rate {
    return Intl.message(
      'Workout Completion Rate',
      name: 'workout_completion_rate',
      desc: '',
      args: [],
    );
  }

  /// `Add Session`
  String get add_session {
    return Intl.message('Add Session', name: 'add_session', desc: '', args: []);
  }

  /// `Broadcast`
  String get broadcast {
    return Intl.message('Broadcast', name: 'broadcast', desc: '', args: []);
  }

  /// `Create Workout Plan`
  String get create_workout_plan {
    return Intl.message(
      'Create Workout Plan',
      name: 'create_workout_plan',
      desc: '',
      args: [],
    );
  }

  /// `Design a new training program for a member.`
  String get design_new_training_program {
    return Intl.message(
      'Design a new training program for a member.',
      name: 'design_new_training_program',
      desc: '',
      args: [],
    );
  }

  /// `Select Member`
  String get select_member {
    return Intl.message(
      'Select Member',
      name: 'select_member',
      desc: '',
      args: [],
    );
  }

  /// `Plan Name`
  String get plan_name {
    return Intl.message('Plan Name', name: 'plan_name', desc: '', args: []);
  }

  /// `Duration (Weeks)`
  String get duration_weeks {
    return Intl.message(
      'Duration (Weeks)',
      name: 'duration_weeks',
      desc: '',
      args: [],
    );
  }

  /// `Create Draft`
  String get create_draft {
    return Intl.message(
      'Create Draft',
      name: 'create_draft',
      desc: '',
      args: [],
    );
  }

  /// `Assign Nutrition Plan`
  String get assign_nutrition_plan {
    return Intl.message(
      'Assign Nutrition Plan',
      name: 'assign_nutrition_plan',
      desc: '',
      args: [],
    );
  }

  /// `Set calorie and macro targets.`
  String get set_calorie_macro_targets {
    return Intl.message(
      'Set calorie and macro targets.',
      name: 'set_calorie_macro_targets',
      desc: '',
      args: [],
    );
  }

  /// `Daily Calories`
  String get daily_calories {
    return Intl.message(
      'Daily Calories',
      name: 'daily_calories',
      desc: '',
      args: [],
    );
  }

  /// `Protein (g)`
  String get protein_grams {
    return Intl.message(
      'Protein (g)',
      name: 'protein_grams',
      desc: '',
      args: [],
    );
  }

  /// `Carbs (g)`
  String get carbs_grams {
    return Intl.message('Carbs (g)', name: 'carbs_grams', desc: '', args: []);
  }

  /// `Fats (g)`
  String get fats_grams {
    return Intl.message('Fats (g)', name: 'fats_grams', desc: '', args: []);
  }

  /// `Assign Plan`
  String get assign_plan {
    return Intl.message('Assign Plan', name: 'assign_plan', desc: '', args: []);
  }

  /// `Broadcast Message`
  String get broadcast_message {
    return Intl.message(
      'Broadcast Message',
      name: 'broadcast_message',
      desc: '',
      args: [],
    );
  }

  /// `Recipients`
  String get recipients {
    return Intl.message('Recipients', name: 'recipients', desc: '', args: []);
  }

  /// `Message`
  String get message {
    return Intl.message('Message', name: 'message', desc: '', args: []);
  }

  /// `Type your announcement`
  String get type_your_announcement {
    return Intl.message(
      'Type your announcement',
      name: 'type_your_announcement',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get send {
    return Intl.message('Send', name: 'send', desc: '', args: []);
  }

  /// `All Members`
  String get all_members {
    return Intl.message('All Members', name: 'all_members', desc: '', args: []);
  }

  /// `Schedule Session`
  String get schedule_session {
    return Intl.message(
      'Schedule Session',
      name: 'schedule_session',
      desc: '',
      args: [],
    );
  }

  /// `Session Type`
  String get session_type {
    return Intl.message(
      'Session Type',
      name: 'session_type',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get date {
    return Intl.message('Date', name: 'date', desc: '', args: []);
  }

  /// `Time`
  String get time {
    return Intl.message('Time', name: 'time', desc: '', args: []);
  }

  /// `Overview`
  String get overview {
    return Intl.message('Overview', name: 'overview', desc: '', args: []);
  }

  /// `Training`
  String get training {
    return Intl.message('Training', name: 'training', desc: '', args: []);
  }

  /// `InBody`
  String get inbody {
    return Intl.message('InBody', name: 'inbody', desc: '', args: []);
  }

  /// `Messages`
  String get messages {
    return Intl.message('Messages', name: 'messages', desc: '', args: []);
  }

  /// `Member Profile`
  String get member_profile {
    return Intl.message(
      'Member Profile',
      name: 'member_profile',
      desc: '',
      args: [],
    );
  }

  /// `Create Your Plan`
  String get create_your_plan {
    return Intl.message(
      'Create Your Plan',
      name: 'create_your_plan',
      desc: '',
      args: [],
    );
  }

  /// `Step 1: Basics`
  String get step_1_basics {
    return Intl.message(
      'Step 1: Basics',
      name: 'step_1_basics',
      desc: '',
      args: [],
    );
  }

  /// `Training Days per Week`
  String get training_days_per_week {
    return Intl.message(
      'Training Days per Week',
      name: 'training_days_per_week',
      desc: '',
      args: [],
    );
  }

  /// `Generating your plan`
  String get generating_your_plan {
    return Intl.message(
      'Generating your plan',
      name: 'generating_your_plan',
      desc: '',
      args: [],
    );
  }

  /// `Analyzing your metrics`
  String get analyzing_your_metrics {
    return Intl.message(
      'Analyzing your metrics',
      name: 'analyzing_your_metrics',
      desc: '',
      args: [],
    );
  }

  /// `Save Plan`
  String get save_plan {
    return Intl.message('Save Plan', name: 'save_plan', desc: '', args: []);
  }

  /// `Custom Plan`
  String get custom_plan {
    return Intl.message('Custom Plan', name: 'custom_plan', desc: '', args: []);
  }

  /// `Target: Custom`
  String get target_custom {
    return Intl.message(
      'Target: Custom',
      name: 'target_custom',
      desc: '',
      args: [],
    );
  }

  /// `Your coach has designed your new workout plan.`
  String get coach_designed_new_plan {
    return Intl.message(
      'Your coach has designed your new workout plan.',
      name: 'coach_designed_new_plan',
      desc: '',
      args: [],
    );
  }

  /// `Nutrition Plan`
  String get nutrition_plan {
    return Intl.message(
      'Nutrition Plan',
      name: 'nutrition_plan',
      desc: '',
      args: [],
    );
  }

  /// `Daily Targets`
  String get daily_targets {
    return Intl.message(
      'Daily Targets',
      name: 'daily_targets',
      desc: '',
      args: [],
    );
  }

  /// `Next Meals`
  String get next_meals {
    return Intl.message('Next Meals', name: 'next_meals', desc: '', args: []);
  }

  /// `Diet Type`
  String get diet_type {
    return Intl.message('Diet Type', name: 'diet_type', desc: '', args: []);
  }

  /// `Save Meal Plan`
  String get save_meal_plan {
    return Intl.message(
      'Save Meal Plan',
      name: 'save_meal_plan',
      desc: '',
      args: [],
    );
  }

  /// `Add Meal`
  String get add_meal {
    return Intl.message('Add Meal', name: 'add_meal', desc: '', args: []);
  }

  /// `Carbs`
  String get carbs {
    return Intl.message('Carbs', name: 'carbs', desc: '', args: []);
  }

  /// `Fat`
  String get fat {
    return Intl.message('Fat', name: 'fat', desc: '', args: []);
  }

  /// `Water Intake`
  String get water_intake {
    return Intl.message(
      'Water Intake',
      name: 'water_intake',
      desc: '',
      args: [],
    );
  }

  /// `Sleep Duration`
  String get sleep_duration {
    return Intl.message(
      'Sleep Duration',
      name: 'sleep_duration',
      desc: '',
      args: [],
    );
  }

  /// `Target:`
  String get target {
    return Intl.message('Target:', name: 'target', desc: '', args: []);
  }

  /// `Daily Timetable`
  String get daily_timetable {
    return Intl.message(
      'Daily Timetable',
      name: 'daily_timetable',
      desc: '',
      args: [],
    );
  }

  /// `Daily Nutrition`
  String get daily_nutrition {
    return Intl.message(
      'Daily Nutrition',
      name: 'daily_nutrition',
      desc: '',
      args: [],
    );
  }

  /// `Recent Check-ins`
  String get recent_checkins {
    return Intl.message(
      'Recent Check-ins',
      name: 'recent_checkins',
      desc: '',
      args: [],
    );
  }

  /// `Downtown`
  String get downtown {
    return Intl.message('Downtown', name: 'downtown', desc: '', args: []);
  }

  /// `Uptown`
  String get uptown {
    return Intl.message('Uptown', name: 'uptown', desc: '', args: []);
  }

  /// `Private Notes`
  String get private_notes {
    return Intl.message(
      'Private Notes',
      name: 'private_notes',
      desc: '',
      args: [],
    );
  }

  /// `Save Notes`
  String get save_notes {
    return Intl.message('Save Notes', name: 'save_notes', desc: '', args: []);
  }

  /// `Logs Summary`
  String get logs_summary {
    return Intl.message(
      'Logs Summary',
      name: 'logs_summary',
      desc: '',
      args: [],
    );
  }

  /// `Daily Meal Plan`
  String get daily_meal_plan {
    return Intl.message(
      'Daily Meal Plan',
      name: 'daily_meal_plan',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message('Edit', name: 'edit', desc: '', args: []);
  }

  /// `Coach Comments`
  String get coach_comments {
    return Intl.message(
      'Coach Comments',
      name: 'coach_comments',
      desc: '',
      args: [],
    );
  }

  /// `Save Comments`
  String get save_comments {
    return Intl.message(
      'Save Comments',
      name: 'save_comments',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get history {
    return Intl.message('History', name: 'history', desc: '', args: []);
  }

  /// `View Summary`
  String get view_summary {
    return Intl.message(
      'View Summary',
      name: 'view_summary',
      desc: '',
      args: [],
    );
  }

  /// `Preview`
  String get preview {
    return Intl.message('Preview', name: 'preview', desc: '', args: []);
  }

  /// `Gym Admin`
  String get gym_admin {
    return Intl.message('Gym Admin', name: 'gym_admin', desc: '', args: []);
  }

  /// `Dashboard`
  String get dashboard {
    return Intl.message('Dashboard', name: 'dashboard', desc: '', args: []);
  }

  /// `Coaches`
  String get coaches {
    return Intl.message('Coaches', name: 'coaches', desc: '', args: []);
  }

  /// `Plans`
  String get plans {
    return Intl.message('Plans', name: 'plans', desc: '', args: []);
  }

  /// `Check-Ins`
  String get check_ins {
    return Intl.message('Check-Ins', name: 'check_ins', desc: '', args: []);
  }

  /// `Analytics`
  String get analytics {
    return Intl.message('Analytics', name: 'analytics', desc: '', args: []);
  }

  /// `Marketing`
  String get marketing {
    return Intl.message('Marketing', name: 'marketing', desc: '', args: []);
  }

  /// `Staff`
  String get staff {
    return Intl.message('Staff', name: 'staff', desc: '', args: []);
  }

  /// `Top Products`
  String get top_products {
    return Intl.message(
      'Top Products',
      name: 'top_products',
      desc: '',
      args: [],
    );
  }

  /// `Live Status`
  String get live_status {
    return Intl.message('Live Status', name: 'live_status', desc: '', args: []);
  }

  /// `Members Currently Inside`
  String get members_currently_inside {
    return Intl.message(
      'Members Currently Inside',
      name: 'members_currently_inside',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get active {
    return Intl.message('Active', name: 'active', desc: '', args: []);
  }

  /// `Sessions`
  String get sessions {
    return Intl.message('Sessions', name: 'sessions', desc: '', args: []);
  }

  /// `Products`
  String get products {
    return Intl.message('Products', name: 'products', desc: '', args: []);
  }

  /// `Orders`
  String get orders {
    return Intl.message('Orders', name: 'orders', desc: '', args: []);
  }

  /// `Promo Codes`
  String get promo_codes {
    return Intl.message('Promo Codes', name: 'promo_codes', desc: '', args: []);
  }

  /// `Manage discounts and offers`
  String get manage_discounts_offers {
    return Intl.message(
      'Manage discounts and offers',
      name: 'manage_discounts_offers',
      desc: '',
      args: [],
    );
  }

  /// `Enter Code`
  String get enter_code {
    return Intl.message('Enter Code', name: 'enter_code', desc: '', args: []);
  }

  /// `Create`
  String get create {
    return Intl.message('Create', name: 'create', desc: '', args: []);
  }

  /// `Push Notifications`
  String get push_notifications {
    return Intl.message(
      'Push Notifications',
      name: 'push_notifications',
      desc: '',
      args: [],
    );
  }

  /// `Audience`
  String get audience {
    return Intl.message('Audience', name: 'audience', desc: '', args: []);
  }

  /// `No members found`
  String get no_members_found {
    return Intl.message(
      'No members found',
      name: 'no_members_found',
      desc: '',
      args: [],
    );
  }

  /// `Search by name`
  String get search_by_name {
    return Intl.message(
      'Search by name',
      name: 'search_by_name',
      desc: '',
      args: [],
    );
  }

  /// `Inactive`
  String get inactive {
    return Intl.message('Inactive', name: 'inactive', desc: '', args: []);
  }

  /// `Frozen`
  String get frozen {
    return Intl.message('Frozen', name: 'frozen', desc: '', args: []);
  }

  /// `Expiring`
  String get expiring {
    return Intl.message('Expiring', name: 'expiring', desc: '', args: []);
  }

  /// `View Profile`
  String get view_profile {
    return Intl.message(
      'View Profile',
      name: 'view_profile',
      desc: '',
      args: [],
    );
  }

  /// `Last Check-in`
  String get last_check_in {
    return Intl.message(
      'Last Check-in',
      name: 'last_check_in',
      desc: '',
      args: [],
    );
  }

  /// `Status`
  String get status {
    return Intl.message('Status', name: 'status', desc: '', args: []);
  }

  /// `Plan`
  String get plan {
    return Intl.message('Plan', name: 'plan', desc: '', args: []);
  }

  /// `Edit Plan`
  String get edit_plan {
    return Intl.message('Edit Plan', name: 'edit_plan', desc: '', args: []);
  }

  /// `Active Members`
  String get active_members {
    return Intl.message(
      'Active Members',
      name: 'active_members',
      desc: '',
      args: [],
    );
  }

  /// `Inventory`
  String get inventory {
    return Intl.message('Inventory', name: 'inventory', desc: '', args: []);
  }

  /// `Add Product`
  String get add_product {
    return Intl.message('Add Product', name: 'add_product', desc: '', args: []);
  }

  /// `Add Staff`
  String get add_staff {
    return Intl.message('Add Staff', name: 'add_staff', desc: '', args: []);
  }

  /// `Name`
  String get name {
    return Intl.message('Name', name: 'name', desc: '', args: []);
  }

  /// `Role`
  String get role {
    return Intl.message('Role', name: 'role', desc: '', args: []);
  }

  /// `Access`
  String get access {
    return Intl.message('Access', name: 'access', desc: '', args: []);
  }

  /// `Actions`
  String get actions {
    return Intl.message('Actions', name: 'actions', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
