import '../entities/product.dart';
import '../repositories/home_repository.dart';

class GetProducts {
  final HomeRepository repository;

  const GetProducts(this.repository);

  Future<List<Product>> call() => repository.getProducts();
}
