import 'package:equatable/equatable.dart';

import '../../../../core/enums/categories.dart';
import '../data/models/product_model.dart';


abstract class MarketState extends Equatable {
  const MarketState();

  @override
  List<Object?> get props => [];
}

class MarketInitial extends MarketState {}

class MarketLoading extends MarketState {}

class MarketLoaded extends MarketState {
  final List<ProductModel> products;
  final ProductCategory selectedCategory;

  const MarketLoaded({
    required this.products,
    required this.selectedCategory,
  });

  @override
  List<Object?> get props => [products, selectedCategory];
}

class MarketEmpty extends MarketState {
  final ProductCategory selectedCategory;

  const MarketEmpty(this.selectedCategory);

  @override
  List<Object?> get props => [selectedCategory];
}

class MarketError extends MarketState {
  final String message;

  const MarketError(this.message);

  @override
  List<Object?> get props => [message];
}
