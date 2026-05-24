import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../helpers/app_constants.dart';
import '../../helpers/shared_pref_helper.dart';


part 'language_state.dart';

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit() : super(LanguageInitial()) {
    loadSavedLanguage();
  }

  bool? isArabic;
  bool? isFirstLogin;

  Future<void> loadSavedLanguage() async {
    // Check if this is the first time the app is launched
    bool hasLanguagePreference = await SharedPrefHelper.containsKey(
      AppConstants.isArabic,
    );

    if (hasLanguagePreference) {
      // User has previously set a language preference
      isArabic = await SharedPrefHelper.getBool(AppConstants.isArabic);
    } else {
      isArabic = false;
      await SharedPrefHelper.setData(AppConstants.isArabic, false);
    }

    emit(LanguageChanged(isArabic!));
  }

  String get locale => (isArabic ?? true) ? "ar" : "en";
  TextDirection get textDirection => (isArabic ?? true) ? TextDirection.rtl : TextDirection.ltr;


  void toggleLanguage() async {
    isFirstLogin = true;
    isArabic = !isArabic!;
    await SharedPrefHelper.setData(AppConstants.isArabic, isArabic);
    emit(LanguageChanged(isArabic!));
  }

  void setLanguage(bool isArabicLang) async {
    isFirstLogin = true;
    isArabic = isArabicLang;
    await SharedPrefHelper.setData(AppConstants.isArabic, isArabic);
    emit(LanguageChanged(isArabic!));
  }
}
