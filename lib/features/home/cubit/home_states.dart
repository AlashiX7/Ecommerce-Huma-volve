import '../service/models/category_model.dart';
import '../service/models/product_model.dart';

abstract class HomeStates {
  final List<CategoryModel> categories;
  final CategoryModel? selectedCategory;
  final List<ProductModel> products;

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
  const ProductsSuccess({
    required super.categories,
    required super.selectedCategory,
    required super.products,
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
