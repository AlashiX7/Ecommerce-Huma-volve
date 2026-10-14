import '../entities/category.dart';
import '../repositories/home_repository.dart';

class GetCategories {
  final HomeRepository repository;

  const GetCategories(this.repository);

  Future<List<Category>> call() => repository.getCategories();
}
