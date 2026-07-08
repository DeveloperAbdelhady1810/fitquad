import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_app/core/helpers/shared_pref_helper.dart';
import 'package:gym_app/core/theme/app_colors.dart';
import 'package:gym_app/core/theme/app_text_styles.dart';

/// One-time AI data-sharing consent, required for App Store compliance
/// (Apple Guideline 5.1.1(i) / 5.1.2(i)).
///
/// Any feature that sends member data to a third-party AI service (currently
/// Google Gemini) must call [AiConsent.ensure] first and bail out if the
/// member declines.
class AiConsent {
  AiConsent._();

  static const _consentKey = 'ai_consent_v1';

  /// Whether the member has already granted consent.
  static Future<bool> hasConsented() async {
    final value = await SharedPrefHelper.getBool(_consentKey);
    return value as bool;
  }

  static Future<void> setConsent(bool value) =>
      SharedPrefHelper.setData(_consentKey, value);

  /// Ensures the member has consented to AI data sharing before an AI call is
  /// made. Shows a one-time explanatory dialog if consent hasn't been
  /// recorded yet. Returns `true` if the caller may proceed with the AI
  /// request, `false` if the member declined (caller must skip the AI call).
  static Future<bool> ensure(BuildContext context) async {
    if (await hasConsented()) return true;
    if (!context.mounted) return false;

    final allowed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('AI Features & Your Data', style: AppTextStyles.font16WhiteBold),
        content: SingleChildScrollView(
          child: Text(
            'FitQuad uses Google Gemini AI to analyze your fitness data '
            '(weight, body-composition metrics, goals, and activity) and to '
            'generate workout/nutrition plans and answer your questions.\n\n'
            'This data is sent to Google (Gemini) for processing. Only your '
            'first name is used for personalization — your email address is '
            'never sent.\n\n'
            'You can turn this off any time; declining will simply disable AI '
            'features.',
            style: AppTextStyles.font14GreyRegular,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Not now', style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Allow',
                style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    final result = allowed ?? false;
    if (result) await setConsent(true);
    return result;
  }
}
