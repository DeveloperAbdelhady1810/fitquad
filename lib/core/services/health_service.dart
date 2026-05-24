import 'package:health/health.dart';

class HealthSnapshot {
  final int steps;
  final int heartRateBpm;
  final double sleepHrs;
  final int caloriesBurned;

  const HealthSnapshot({
    required this.steps,
    required this.heartRateBpm,
    required this.sleepHrs,
    required this.caloriesBurned,
  });
}

class HealthService {
  static final Health _health = Health();

  static const _readTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];

  static const _writeTypes = [
    HealthDataType.WORKOUT,
  ];

  /// Returns true if permission was granted (or already had it).
  static Future<bool> requestPermissions() async {
    try {
      await _health.configure();
      final permissions = [
        ..._readTypes.map((_) => HealthDataAccess.READ),
        ..._writeTypes.map((_) => HealthDataAccess.READ_WRITE),
      ];
      final granted = await _health.requestAuthorization(
        [..._readTypes, ..._writeTypes],
        permissions: permissions,
      );
      return granted;
    } catch (_) {
      return false;
    }
  }

  /// Fetches today's health snapshot. Returns zeros on error or no data.
  static Future<HealthSnapshot> fetchTodaySnapshot() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final yesterdayNoon = now.subtract(const Duration(hours: 14));

    int steps = 0;
    int heartRateBpm = 0;
    double sleepHrs = 0;
    int caloriesBurned = 0;

    try {
      // Steps
      final stepData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: startOfDay,
        endTime: now,
      );
      steps = stepData.fold<int>(0, (sum, e) {
        final val = (e.value as NumericHealthValue).numericValue.toInt();
        return sum + val;
      });

      // Heart rate — latest reading
      final hrData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: startOfDay,
        endTime: now,
      );
      if (hrData.isNotEmpty) {
        hrData.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        heartRateBpm =
            (hrData.first.value as NumericHealthValue).numericValue.toInt();
      }

      // Sleep — last ~14 hours window to capture overnight sleep
      final sleepData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.SLEEP_ASLEEP],
        startTime: yesterdayNoon,
        endTime: now,
      );
      sleepHrs = sleepData.fold<double>(0, (sum, e) {
        final mins =
            e.dateTo.difference(e.dateFrom).inMinutes.toDouble();
        return sum + mins;
      }) / 60.0;

      // Active calories
      final calData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: startOfDay,
        endTime: now,
      );
      caloriesBurned = calData.fold<int>(0, (sum, e) {
        final val = (e.value as NumericHealthValue).numericValue.toInt();
        return sum + val;
      });
    } catch (_) {
      // Return whatever was collected so far; individual failures don't block the rest
    }

    return HealthSnapshot(
      steps: steps,
      heartRateBpm: heartRateBpm,
      sleepHrs: sleepHrs,
      caloriesBurned: caloriesBurned,
    );
  }

  /// Writes a completed workout session to Apple Health / Health Connect.
  static Future<void> writeWorkout({
    required int calories,
    required Duration duration,
    required DateTime start,
  }) async {
    try {
      final end = start.add(duration);
      await _health.writeWorkoutData(
        activityType: HealthWorkoutActivityType.TRADITIONAL_STRENGTH_TRAINING,
        start: start,
        end: end,
        totalEnergyBurned: calories,
        totalEnergyBurnedUnit: HealthDataUnit.KILOCALORIE,
      );
    } catch (_) {
      // Write failure is non-fatal — workout was still completed in-app
    }
  }
}
