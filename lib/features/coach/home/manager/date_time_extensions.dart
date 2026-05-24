import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String get timeOnly => DateFormat('hh:mm a').format(this);
}
