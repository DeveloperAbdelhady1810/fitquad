import 'package:bloc/bloc.dart';
import 'package:gym_app/core/enums/food_enum.dart';
import 'package:meta/meta.dart';

import '../../data/models/meal_model.dart';
import '../../data/repositories/member_repository.dart';

part 'food_state.dart';

class FoodCubit extends Cubit<FoodState> {
  FoodCubit() : super(FoodInitial());

  FoodCategory selectedCategory = FoodCategory.all;
  List<FoodModel> _foods = [];

  Future<void> loadFoods() async {
    try {
      emit(FoodLoading());
      final data = await MemberRepository.getFoodItems();
      _foods = data.map((j) => FoodModel.fromJson(j as Map<String, dynamic>)).toList();
      emit(_buildLoadedState());
    } catch (_) {
      emit(FoodInitial());
    }
  }

  void changeCategory(FoodCategory category) {
    selectedCategory = category;
    emit(_buildLoadedState());
  }

  Future<void> logFood(String id) async {
    final index = _foods.indexWhere((f) => f.id == id);
    if (index == -1) return;

    _foods[index].isLogged = true;
    emit(_buildLoadedState());

    try {
      await MemberRepository.logMeal(
        foodItemId: int.tryParse(id) ?? 0,
        quantity: 1,
        mealType: _foods[index].category.name,
      );
    } catch (_) {}
  }

  FoodLoaded _buildLoadedState() {
    return FoodLoaded(
      foods: _filteredFoods,
      loggedFoods: _foods.where((e) => e.isLogged).toList(),
    );
  }

  List<FoodModel> get _filteredFoods {
    if (selectedCategory == FoodCategory.all) return List.from(_foods);
    return _foods.where((f) => f.category == selectedCategory).toList();
  }
}
