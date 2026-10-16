import '../entities/category.dart';
import '../entities/product.dart';

abstract interface class HomeRepository {
  Future<List<Category>> getCategories();

  Future<List<Product>> getProducts({required int limit, required int offset});

  Future<List<Product>> getProductsByCategory(
    int categoryId, {
    required int limit,
    required int offset,
  });
}
