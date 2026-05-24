import 'package:flutter/cupertino.dart';

import '../../generated/l10n.dart';

enum ProductCategory {
  all,
  supplements,
  apparel,
  gear,
  accessories,
}

extension ProductCategoryX on ProductCategory {
  String  title(BuildContext context) {
    switch (this) {
      case ProductCategory.supplements:
        return S.of(context).supplements;
      case ProductCategory.apparel:
        return S.of(context).apparel;
      case ProductCategory.gear:
        return S.of(context).gear;
      case ProductCategory.accessories:
        return S.of(context).accessories;
      default:
        return S.of(context).all;
    }
  }
}
