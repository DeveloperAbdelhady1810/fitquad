import 'package:flutter/cupertino.dart';

import '../../generated/l10n.dart';

enum FoodCategory {
  all,
  breakfast,
  lunch,
  dinner,
  snacks,
  dessert,
}

extension FoodCategoryX on FoodCategory {
  String label (BuildContext context){
    switch (this) {
      case FoodCategory.all:
        return S.of(context).all;
      case FoodCategory.breakfast:
        return S.of(context).breakfast;
      case FoodCategory.lunch:
        return S.of(context).lunch;
      case FoodCategory.dinner:
        return S.of(context).dinner;
      case FoodCategory.snacks:
        return S.of(context).snack;
      case FoodCategory.dessert:
        return S.of(context).dessert;
    }
  }
}
