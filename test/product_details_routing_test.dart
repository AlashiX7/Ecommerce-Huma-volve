import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecommerce_app_huma_volve/core/routes/app_routing.dart';
import 'package:ecommerce_app_huma_volve/core/config/product_link_config.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/entities/category.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/entities/product.dart';
import 'package:ecommerce_app_huma_volve/features/home/domain/repositories/home_repository.dart';

void main() {
  test('product share URLs use the product ID and require HTTPS hosting', () {
    expect(
      buildProductShareUri(
        123,
        hostingBaseUrl: 'https://shop.example.test',
      ).toString(),
      'https://shop.example.test/products/123',
    );
    expect(buildProductShareUri(123), isNull);
    expect(
      buildProductShareUri(123, hostingBaseUrl: 'http://shop.example.test'),
      isNull,
    );
  });

  testWidgets('product URL loads its ID and malformed IDs show an error', (
    tester,
  ) async {
    final repository = _FakeHomeRepository();
    appRouter.go('/home');
    await tester.pumpWidget(
      RepositoryProvider<HomeRepository>.value(
        value: repository,
        child: MaterialApp.router(routerConfig: appRouter),
      ),
    );
    await tester.pumpAndSettle();
    appRouter.push('/products/123');
    await tester.pumpAndSettle();

    expect(repository.requestedProductId, 123);
    expect(find.text('Route Product'), findsOneWidget);
    expect(find.byKey(const Key('share-product-button')), findsOneWidget);
    await tester.tap(find.byKey(const Key('share-product-button')));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Product sharing will be available after Hosting is configured.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();
    expect(find.text('Explore'), findsOneWidget);

    // A direct link has no Home route beneath it, so the back arrow should
    // navigate to Home instead of revealing the login route.
    appRouter.go('/products/123');
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
    await tester.pumpAndSettle();
    expect(find.text('Explore'), findsOneWidget);

    appRouter.go('/products/not-a-number');
    await tester.pumpAndSettle();
    expect(find.text('This product link is invalid.'), findsOneWidget);
  });
}

class _FakeHomeRepository implements HomeRepository {
  int? requestedProductId;

  @override
  Future<List<Category>> getCategories() async => const [];

  @override
  Future<Product> getProductById(int productId) async {
    requestedProductId = productId;
    return Product(
      id: productId,
      name: 'Route Product',
      description: 'Loaded from the product route.',
      price: 12,
      imageUrl: '',
    );
  }

  @override
  Future<List<Product>> getProducts({
    required int limit,
    required int offset,
  }) async => const [];

  @override
  Future<List<Product>> getProductsByCategory(
    int categoryId, {
    required int limit,
    required int offset,
  }) async => const [];
}
