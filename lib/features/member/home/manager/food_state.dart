part of 'food_cubit.dart';

@immutable
sealed class FoodState {}

final class FoodInitial extends FoodState {}

final class FoodLoading extends FoodState {}

class FoodLoaded extends FoodState {
  final List<FoodModel> foods;
  final List<FoodModel> loggedFoods;
  final double caloriesToday;
  final double proteinToday;
  final double carbsToday;
  final double fatToday;
  /// Calories logged today per meal_type (breakfast/lunch/dinner/snacks/dessert).
  final Map<String, double> caloriesByMealType;

  FoodLoaded({
    required this.foods,
    required this.loggedFoods,
    this.caloriesToday = 0,
    this.proteinToday = 0,
    this.carbsToday = 0,
    this.fatToday = 0,
    this.caloriesByMealType = const {},
  });
}
