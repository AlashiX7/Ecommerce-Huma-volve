import '../entities/product.dart';
import '../repositories/home_repository.dart';

class GetProductById {
  final HomeRepository repository;

  const GetProductById(this.repository);

  Future<Product> call(int productId) => repository.getProductById(productId);
}
