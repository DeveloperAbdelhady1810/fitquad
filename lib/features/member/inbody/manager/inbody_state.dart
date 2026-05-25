part of 'inbody_cubit.dart';

abstract class InBodyState {
  const InBodyState();
}

class InBodyInitial extends InBodyState {}

class InBodyLoading extends InBodyState {}

class InBodyLoaded extends InBodyState {
  final List<InBodyModel> records;
  const InBodyLoaded(this.records);
}

class InBodySaving extends InBodyState {}

class InBodySaved extends InBodyState {}

class InBodyError extends InBodyState {
  final String message;
  const InBodyError(this.message);
}
