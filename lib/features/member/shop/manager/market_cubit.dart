import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/categories.dart';
import '../../../member/data/repositories/member_repository.dart';
import '../data/models/product_model.dart';
import 'market_state.dart';

class MarketCubit extends Cubit<MarketState> {
  MarketCubit() : super(MarketInitial());

  List<ProductModel> _allProducts = [];

  Future<void> loadProducts() async {
    emit(MarketLoading());
    try {
      final data = await MemberRepository.getProducts();
      _allProducts = data.map((j) => ProductModel.fromJson(j as Map<String, dynamic>)).toList();
      if (_allProducts.isEmpty) {
        emit(MarketEmpty(ProductCategory.all));
      } else {
        emit(MarketLoaded(products: _allProducts, selectedCategory: ProductCategory.all));
      }
    } catch (_) {
      emit(MarketEmpty(ProductCategory.all));
    }
  }

  void searchProducts(String query) {
    final currentCategory = state is MarketLoaded
        ? (state as MarketLoaded).selectedCategory
        : ProductCategory.all;

    final filtered = _allProducts.where((p) {
      final matchesCategory = currentCategory == ProductCategory.all
          ? true
          : p.category == currentCategory;
      final matchesQuery = query.isEmpty
          ? true
          : p.title?.toLowerCase().contains(query.toLowerCase()) ?? false;
      return matchesCategory && matchesQuery;
    }).toList();

    if (filtered.isEmpty) {
      emit(MarketEmpty(currentCategory));
    } else {
      emit(MarketLoaded(products: filtered, selectedCategory: currentCategory));
    }
  }

  void filterByCategory(ProductCategory category) {
    emit(MarketLoading());

    final List<ProductModel> filtered = category == ProductCategory.all
        ? _allProducts
        : _allProducts.where((p) => p.category == category).toList();

    if (filtered.isEmpty) {
      emit(MarketEmpty(category));
    } else {
      emit(MarketLoaded(products: filtered, selectedCategory: category));
    }
  }
}
