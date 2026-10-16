import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce_app_huma_volve/core/errors/app_failure.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/entities/category.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/entities/product.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/repositories/home_repository.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/usecases/get_categories.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/usecases/get_products_by_category.dart';
import 'package:ecommerce_app_huma_volve/features/home/presentation/cubit/home_cubit.dart';
import 'package:ecommerce_app_huma_volve/features/home/presentation/cubit/home_states.dart';

void main() {
  test('appends unique products and stops after a short page', () async {
    final repository = _FakeHomeRepository((categoryId, limit, offset) async {
      if (offset == 0) return _products(1, limit);
      if (offset == 10) return _products(11, limit);
      return [];
    });
    final cubit = _createCubit(repository);
    await _waitForInitialPage(cubit);

    await cubit.loadNextProductsPage();
    expect(
      cubit.state.products.map((product) => product.id),
      List<int>.generate(20, (index) => index + 1),
    );
    expect(repository.requests.last, (categoryId: 1, limit: 10, offset: 10));
    expect((cubit.state as ProductsSuccess).hasMore, true);

    await cubit.loadNextProductsPage();
    expect((cubit.state as ProductsSuccess).products.length, 20);
    expect((cubit.state as ProductsSuccess).hasMore, false);

    await cubit.close();
  });

  test('keeps products on page failure and retries the same offset', () async {
    var shouldFail = true;
    final repository = _FakeHomeRepository((categoryId, limit, offset) async {
      if (offset == 0) return _products(1, limit);
      if (shouldFail) {
        shouldFail = false;
        throw const AppFailure(FailureType.connection);
      }
      return [_product(10), ..._products(11, limit - 1)];
    });
    final cubit = _createCubit(repository);
    await _waitForInitialPage(cubit);

    await cubit.loadNextProductsPage();
    expect(cubit.state.products.length, 10);
    expect((cubit.state as ProductsSuccess).pageError, isNotNull);

    await cubit.retryProducts();
    expect(repository.requests.map((request) => request.offset), [0, 10, 10]);
    expect(cubit.state.products.length, 19);
    expect(
      cubit.state.products.map((product) => product.id).toSet().length,
      19,
    );
    expect((cubit.state as ProductsSuccess).pageError, isNull);

    await cubit.close();
  });

  test('does not start duplicate requests while a page is loading', () async {
    final nextPage = Completer<List<Product>>();
    final repository = _FakeHomeRepository((categoryId, limit, offset) {
      if (offset == 0) return Future.value(_products(1, limit));
      return nextPage.future;
    });
    final cubit = _createCubit(repository);
    await _waitForInitialPage(cubit);

    final firstRequest = cubit.loadNextProductsPage();
    await cubit.loadNextProductsPage();
    expect(
      repository.requests.where((request) => request.offset == 10).length,
      1,
    );

    nextPage.complete(_products(11, 10));
    await firstRequest;
    expect(cubit.state.products.length, 20);
    await cubit.close();
  });

  test('ignores a late result after the category changes', () async {
    final oldCategoryPage = Completer<List<Product>>();
    final repository = _FakeHomeRepository(
      (categoryId, limit, offset) {
        if (categoryId == 1) return oldCategoryPage.future;
        return Future.value(_products(101, limit));
      },
      categories: const [
        Category(id: 1, name: 'Shoes'),
        Category(id: 2, name: 'Electronics'),
      ],
    );
    final cubit = _createCubit(repository);
    for (
      var attempt = 0;
      attempt < 20 && repository.requests.isEmpty;
      attempt++
    ) {
      await Future<void>.delayed(Duration.zero);
    }

    await cubit.selectCategory(2);
    oldCategoryPage.complete(_products(1, 10));
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.selectedCategory?.id, 2);
    expect(cubit.state.products.first.id, 101);
    await cubit.close();
  });
}

HomeCubit _createCubit(_FakeHomeRepository repository) => HomeCubit(
  categoryLoader: GetCategories(repository),
  productLoader: GetProductsByCategory(repository),
);

Future<void> _waitForInitialPage(HomeCubit cubit) async {
  for (var attempt = 0; attempt < 20; attempt++) {
    if (cubit.state is ProductsSuccess || cubit.state is ProductsError) return;
    await Future<void>.delayed(Duration.zero);
  }
  fail('The initial category product page did not finish loading.');
}

List<Product> _products(int firstId, int count) =>
    List<Product>.generate(count, (index) => _product(firstId + index));

Product _product(int id) => Product(
  id: id,
  name: 'Product $id',
  description: 'Description $id',
  price: id.toDouble(),
  imageUrl: '',
);

class _FakeHomeRepository implements HomeRepository {
  final Future<List<Product>> Function(int categoryId, int limit, int offset)
  fetchProducts;
  final List<({int categoryId, int limit, int offset})> requests = [];
  final List<Category> categories;

  _FakeHomeRepository(
    this.fetchProducts, {
    this.categories = const [Category(id: 1, name: 'Shoes')],
  });

  @override
  Future<List<Category>> getCategories() async => categories;

  @override
  Future<List<Product>> getProducts({
    required int limit,
    required int offset,
  }) => fetchProducts(1, limit, offset);

  @override
  Future<Product> getProductById(int productId) async => _product(productId);

  @override
  Future<List<Product>> getProductsByCategory(
    int categoryId, {
    required int limit,
    required int offset,
  }) {
    requests.add((categoryId: categoryId, limit: limit, offset: offset));
    return fetchProducts(categoryId, limit, offset);
  }
}
