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
  double _caloriesToday = 0;
  double _proteinToday = 0;
  double _carbsToday = 0;
  double _fatToday = 0;

  Future<void> loadFoods() async {
    try {
      emit(FoodLoading());
      final data = await MemberRepository.getFoodItems();
      _foods = data.map((j) => FoodModel.fromJson(j as Map<String, dynamic>)).toList();
      await _refreshTodayLog();
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
      // quantity=100 means "one full listed serving" — the backend computes
      // totals as nutritionValue * quantity / 100, so 100 always yields
      // exactly the food's listed calories/macros for one serving, whether
      // that serving is measured in grams, a piece, or a scoop.
      await MemberRepository.logMeal(
        foodItemId: int.tryParse(id) ?? 0,
        quantity: 100,
        mealType: _foods[index].category.name,
      );
      // Refresh real totals from the server so the daily activity summary
      // (calories/protein progress bars) reflects what was actually saved.
      await _refreshTodayLog();
      emit(_buildLoadedState());
    } catch (_) {
      // Revert the optimistic checkmark — the save actually failed, don't
      // show a false "logged" state.
      _foods[index].isLogged = false;
      emit(_buildLoadedState());
    }
  }

  /// Fetches today's persisted logged meals and totals from the server,
  /// marking any matching food items as logged so state survives cubit
  /// recreation (e.g. reopening the food dialog or navigating back).
  Future<void> _refreshTodayLog() async {
    try {
      final result = await MemberRepository.getLoggedMeals();
      final logs = (result['logs'] as List?) ?? [];
      final loggedIds = logs
          .map((l) => (l as Map<String, dynamic>)['food_item_id']?.toString())
          .whereType<String>()
          .toSet();
      for (final food in _foods) {
        if (loggedIds.contains(food.id)) food.isLogged = true;
      }

      final totals = (result['totals'] as Map<String, dynamic>?) ?? {};
      _caloriesToday = (totals['calories'] as num?)?.toDouble() ?? 0;
      _proteinToday  = (totals['protein']  as num?)?.toDouble() ?? 0;
      _carbsToday    = (totals['carbs']    as num?)?.toDouble() ?? 0;
      _fatToday      = (totals['fat']      as num?)?.toDouble() ?? 0;
    } catch (_) {
      // Keep whatever totals we had; don't block food list loading on this.
    }
  }

  FoodLoaded _buildLoadedState() {
    return FoodLoaded(
      foods: _filteredFoods,
      loggedFoods: _foods.where((e) => e.isLogged).toList(),
      caloriesToday: _caloriesToday,
      proteinToday: _proteinToday,
      carbsToday: _carbsToday,
      fatToday: _fatToday,
    );
  }

  List<FoodModel> get _filteredFoods {
    if (selectedCategory == FoodCategory.all) return List.from(_foods);
    return _foods.where((f) => f.category == selectedCategory).toList();
  }
}
