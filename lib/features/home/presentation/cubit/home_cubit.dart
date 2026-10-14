import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_products_by_category.dart';
import 'home_states.dart';

class HomeCubit extends Cubit<HomeStates> {
  final GetCategories categoryLoader;
  final GetProductsByCategory productLoader;
  final Map<int, List<Product>> _productsByCategory = {};
  int _requestNumber = 0;

  HomeCubit({required this.categoryLoader, required this.productLoader})
    : super(const HomeInitial()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    _requestNumber++;
    emit(const CategoriesLoading());

    try {
      final categories = await categoryLoader();
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
    } on AppFailure catch (failure) {
      if (!isClosed) {
        emit(CategoriesError(_failureMessage(failure)));
      }
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
      final products = await productLoader(categoryId);
      if (isClosed || requestNumber != _requestNumber) return;

      _productsByCategory[categoryId] = products;
      emit(
        ProductsSuccess(
          categories: categories,
          selectedCategory: category,
          products: products,
        ),
      );
    } on AppFailure catch (failure) {
      if (!isClosed && requestNumber == _requestNumber) {
        emit(
          ProductsError(
            message: _failureMessage(failure),
            categories: categories,
            selectedCategory: category,
          ),
        );
      }
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

  Category? _findCategory(List<Category> categories, int id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  String _failureMessage(AppFailure failure) => switch (failure.type) {
    FailureType.connection =>
      'Unable to connect. Check your internet connection and try again.',
    FailureType.server =>
      'The server is temporarily unavailable. Try again later.',
    _ => 'The request could not be completed. Please try again.',
  };
}
