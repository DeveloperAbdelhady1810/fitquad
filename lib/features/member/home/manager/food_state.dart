part of 'food_cubit.dart';

@immutable
sealed class FoodState {}

final class FoodInitial extends FoodState {}

final class FoodLoading extends FoodState {}

class FoodLoaded extends FoodState {
  final List<FoodModel> foods;
  final List<FoodModel> loggedFoods;

  FoodLoaded({required this.foods,required this.loggedFoods});
}
