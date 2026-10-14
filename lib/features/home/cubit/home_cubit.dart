import 'package:flutter_bloc/flutter_bloc.dart';

import '../service/home_service.dart';
import '../service/models/category_model.dart';
import '../service/models/product_model.dart';
import 'home_states.dart';

class HomeCubit extends Cubit<HomeStates> {
  final HomeService _homeService;
  final Map<int, List<ProductModel>> _productsByCategory = {};
  int _requestNumber = 0;

  HomeCubit({HomeService? homeService})
    : _homeService = homeService ?? HomeService(),
      super(const HomeInitial()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    _requestNumber++;
    emit(const CategoriesLoading());

    try {
      final categories = await _homeService.getCategories();
      if (isClosed) return;

      if (categories.isEmpty) {
        emit(const CategoriesSuccess(categories: []));
        return;
      }

      emit(CategoriesSuccess(categories: categories));
      final initialCategory = categories.firstWhere(
        (category) => const {
          'shoes',
          'clothing',
          'accessories',
          'electronics',
        }.contains(category.displayName.toLowerCase()),
        orElse: () => categories.first,
      );
      await selectCategory(initialCategory.id);
    } catch (_) {
      if (!isClosed) {
        emit(
          const CategoriesError('Could not load categories. Please try again.'),
        );
      }
    }
  }

  Future<void> selectCategory(int categoryId) async {
    final current = state;
    final categories = current.categories;
    final category = _findCategory(categories, categoryId);

    if (category == null) return;

    if (current is ProductsSuccess &&
        current.selectedCategory?.id == categoryId) {
      return;
    }
    if (current is ProductsLoading &&
        current.selectedCategory?.id == categoryId) {
      return;
    }

    final cachedProducts = _productsByCategory[categoryId];
    if (cachedProducts != null) {
      _requestNumber++;
      emit(
        ProductsSuccess(
          categories: categories,
          selectedCategory: category,
          products: cachedProducts,
        ),
      );
      return;
    }

    final requestNumber = ++_requestNumber;
    emit(ProductsLoading(categories: categories, selectedCategory: category));

    try {
      final products = await _homeService.getProducts(categoryId);
      if (isClosed || requestNumber != _requestNumber) return;

      _productsByCategory[categoryId] = products;
      emit(
        ProductsSuccess(
          categories: categories,
          selectedCategory: category,
          products: products,
        ),
      );
    } catch (_) {
      if (!isClosed && requestNumber == _requestNumber) {
        emit(
          ProductsError(
            message: 'Could not load products. Please try again.',
            categories: categories,
            selectedCategory: category,
          ),
        );
      }
    }
  }

  Future<void> retryProducts() async {
    final categoryId = state.selectedCategory?.id;
    if (categoryId == null) return;
    _productsByCategory.remove(categoryId);
    await selectCategory(categoryId);
  }

  CategoryModel? _findCategory(List<CategoryModel> categories, int id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }
}
