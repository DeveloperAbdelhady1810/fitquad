import 'package:flutter/material.dart';

bool isArabicLocale(BuildContext context) {
  return Localizations.localeOf(context).languageCode == 'ar';
}
