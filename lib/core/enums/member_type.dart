import 'package:flutter/material.dart';

import '../../generated/l10n.dart';

enum MemberType {
  all,
  fit,
  loss,
  low,
  neww

}


extension MemberTypeX on MemberType {
  String label (BuildContext context){
    switch (this) {
      case MemberType.all :
        return S.of(context).all;
      case MemberType.fit :
        return S.of(context).fit;
      case MemberType.loss :
        return S.of(context).fat_loss;
      case MemberType.low:
        return S.of(context).low_activity;
      case MemberType.neww :
        return S.of(context).neww;

    }
  }
}
