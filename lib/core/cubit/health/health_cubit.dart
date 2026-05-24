import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/core/services/health_service.dart';

// ── States ──────────────────────────────────────────────────────────────────

abstract class HealthState {}

class HealthInitial extends HealthState {}

class HealthLoading extends HealthState {}

class HealthLoaded extends HealthState {
  final HealthSnapshot snapshot;
  HealthLoaded(this.snapshot);
}

class HealthPermissionDenied extends HealthState {}

class HealthError extends HealthState {
  final String message;
  HealthError(this.message);
}

// ── Cubit ────────────────────────────────────────────────────────────────────

class HealthCubit extends Cubit<HealthState> {
  HealthCubit() : super(HealthInitial()) {
    _init();
  }

  Future<void> _init() async {
    emit(HealthLoading());
    final granted = await HealthService.requestPermissions();
    if (!granted) {
      emit(HealthPermissionDenied());
      return;
    }
    await refresh();
  }

  Future<void> refresh() async {
    try {
      final snapshot = await HealthService.fetchTodaySnapshot();
      emit(HealthLoaded(snapshot));
    } catch (e) {
      emit(HealthError(e.toString()));
    }
  }
}
