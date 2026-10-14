import '../entities/product.dart';
import '../repositories/home_repository.dart';

class GetProductsByCategory {
  final HomeRepository repository;

  const GetProductsByCategory(this.repository);

  Future<List<Product>> call(int categoryId) =>
      repository.getProductsByCategory(categoryId);
}
