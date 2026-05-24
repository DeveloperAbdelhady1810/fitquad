enum DayStatus {
  past,
  today,
  future,
}

DayStatus getDayStatus(DateTime dayDate) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(dayDate.year, dayDate.month, dayDate.day);

  if (day.isBefore(today)) return DayStatus.past;
  if (day.isAfter(today)) return DayStatus.future;
  return DayStatus.today;
}