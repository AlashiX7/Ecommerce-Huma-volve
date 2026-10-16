import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';

abstract class HomeStates {
  final List<Category> categories;
  final Category? selectedCategory;
  final List<Product> products;

  const HomeStates({
    this.categories = const [],
    this.selectedCategory,
    this.products = const [],
  });
}

class HomeInitial extends HomeStates {
  const HomeInitial();
}

class CategoriesLoading extends HomeStates {
  const CategoriesLoading();
}

class CategoriesSuccess extends HomeStates {
  const CategoriesSuccess({required super.categories, super.selectedCategory});
}

class CategoriesError extends HomeStates {
  final String message;

  const CategoriesError(this.message);
}

class ProductsLoading extends HomeStates {
  const ProductsLoading({
    required super.categories,
    required super.selectedCategory,
    super.products,
  });
}

class ProductsSuccess extends HomeStates {
  final bool hasMore;
  final bool isLoadingMore;
  final String? pageError;

  const ProductsSuccess({
    required super.categories,
    required super.selectedCategory,
    required super.products,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.pageError,
  });
}

class ProductsError extends HomeStates {
  final String message;

  const ProductsError({
    required this.message,
    required super.categories,
    required super.selectedCategory,
    super.products,
  });
}
