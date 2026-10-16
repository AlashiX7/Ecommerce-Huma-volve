import '../entities/product.dart';
import '../repositories/home_repository.dart';

class GetProducts {
  final HomeRepository repository;

  const GetProducts(this.repository);

  Future<List<Product>> call({required int limit, required int offset}) =>
      repository.getProducts(limit: limit, offset: offset);
}
