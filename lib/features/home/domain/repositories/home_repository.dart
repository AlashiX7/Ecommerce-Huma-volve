import '../entities/category.dart';
import '../entities/product.dart';

abstract interface class HomeRepository {
  Future<List<Category>> getCategories();

  Future<List<Product>> getProducts();

  Future<List<Product>> getProductsByCategory(int categoryId);
}
