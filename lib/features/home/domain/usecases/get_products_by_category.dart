import '../entities/product.dart';
import '../repositories/home_repository.dart';

class GetProductsByCategory {
  final HomeRepository repository;

  const GetProductsByCategory(this.repository);

  Future<List<Product>> call(
    int categoryId, {
    required int limit,
    required int offset,
  }) => repository.getProductsByCategory(
    categoryId,
    limit: limit,
    offset: offset,
  );
}
