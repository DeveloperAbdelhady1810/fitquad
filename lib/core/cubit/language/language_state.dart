part of 'language_cubit.dart';

sealed class LanguageState {}

final class LanguageInitial extends LanguageState {}


class LanguageChanged extends LanguageState {
  final bool isArabic;
  LanguageChanged(this.isArabic);
}
