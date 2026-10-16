import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_products_by_category.dart';
import 'home_states.dart';

class HomeCubit extends Cubit<HomeStates> {
  static const int pageSize = 10;

  final GetCategories categoryLoader;
  final GetProductsByCategory productLoader;
  int _requestNumber = 0;
  int _nextOffset = 0;
  bool _hasMore = true;
  bool _initialRequestInFlight = false;
  int? _pageRequestForGeneration;
  List<Product> _products = [];

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
      if (!isClosed) emit(CategoriesError(_failureMessage(failure)));
    } catch (_) {
      if (!isClosed) {
        emit(
          const CategoriesError('Could not load categories. Please try again.'),
        );
      }
    }
  }

  Future<void> selectCategory(int categoryId) async {
    if (categoryId <= 0) return;
    final categories = state.categories;
    final category = _findCategory(categories, categoryId);
    if (category == null) return;

    if (state.selectedCategory?.id == categoryId &&
        (state is ProductsLoading || state is ProductsSuccess)) {
      return;
    }

    final requestNumber = ++_requestNumber;
    _nextOffset = 0;
    _hasMore = true;
    _products = [];
    _initialRequestInFlight = true;
    emit(ProductsLoading(categories: categories, selectedCategory: category));

    try {
      final products = await productLoader(
        categoryId,
        limit: pageSize,
        offset: 0,
      );
      if (isClosed || requestNumber != _requestNumber) return;

      _products = _uniqueProducts(products);
      _nextOffset = products.length;
      _hasMore = products.length == pageSize && _products.isNotEmpty;
      emit(_successState(category, categories));
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
    } finally {
      if (requestNumber == _requestNumber) _initialRequestInFlight = false;
    }
  }

  Future<void> loadNextProductsPage({bool retry = false}) async {
    final category = state.selectedCategory;
    final current = state;
    if (category == null ||
        current is! ProductsSuccess ||
        _initialRequestInFlight ||
        !_hasMore ||
        (current.pageError != null && !retry) ||
        _pageRequestForGeneration == _requestNumber) {
      return;
    }

    final requestNumber = _requestNumber;
    final offset = _nextOffset;
    _pageRequestForGeneration = requestNumber;
    emit(_successState(category, current.categories, isLoadingMore: true));

    try {
      final page = await productLoader(
        category.id,
        limit: pageSize,
        offset: offset,
      );
      if (isClosed || requestNumber != _requestNumber) return;

      final oldCount = _products.length;
      _products = _uniqueProducts([..._products, ...page]);
      final addedCount = _products.length - oldCount;
      _nextOffset += page.length;
      _hasMore = page.length == pageSize && addedCount > 0;
      emit(_successState(category, current.categories));
    } on AppFailure catch (failure) {
      if (!isClosed && requestNumber == _requestNumber) {
        emit(
          _successState(
            category,
            current.categories,
            pageError: _failureMessage(failure),
          ),
        );
      }
    } catch (_) {
      if (!isClosed && requestNumber == _requestNumber) {
        emit(
          _successState(
            category,
            current.categories,
            pageError: 'Could not load more products. Please try again.',
          ),
        );
      }
    } finally {
      if (_pageRequestForGeneration == requestNumber) {
        _pageRequestForGeneration = null;
      }
    }
  }

  Future<void> retryProducts() async {
    final current = state;
    if (current is ProductsSuccess && current.pageError != null) {
      await loadNextProductsPage(retry: true);
      return;
    }
    final categoryId = current.selectedCategory?.id;
    if (categoryId != null) await selectCategory(categoryId);
  }

  ProductsSuccess _successState(
    Category category,
    List<Category> categories, {
    bool isLoadingMore = false,
    String? pageError,
  }) => ProductsSuccess(
    categories: categories,
    selectedCategory: category,
    products: List.unmodifiable(_products),
    hasMore: _hasMore,
    isLoadingMore: isLoadingMore,
    pageError: pageError,
  );

  List<Product> _uniqueProducts(Iterable<Product> products) {
    final seenIds = <int>{};
    return products.where((product) => seenIds.add(product.id)).toList();
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
