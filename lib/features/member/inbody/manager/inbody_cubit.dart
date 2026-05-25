import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_app/features/member/data/repositories/member_repository.dart';
import 'package:gym_app/features/member/inbody/models/inbody_model.dart';

part 'inbody_state.dart';

class InBodyCubit extends Cubit<InBodyState> {
  InBodyCubit() : super(InBodyInitial());

  Future<void> load() async {
    emit(InBodyLoading());
    try {
      final data = await MemberRepository.getInBodyRecords();
      final records = data
          .map((j) => InBodyModel.fromJson(j as Map<String, dynamic>))
          .toList();
      emit(InBodyLoaded(records));
    } catch (e) {
      emit(InBodyError(e.toString()));
    }
  }

  Future<void> save(InBodyModel record) async {
    emit(InBodySaving());
    try {
      await MemberRepository.saveInBodyRecord(record.toJson());
      emit(InBodySaved());
      await load();
    } catch (e) {
      emit(InBodyError(e.toString()));
    }
  }
}
