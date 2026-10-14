import '../../../core/network/api_client.dart';
import 'models/category_model.dart';
import 'models/product_model.dart';

class HomeService {
  Future<List<CategoryModel>> getCategories() async {
    final response = await ApiClient.dio.get('categories');
    final data = _extractList(response.data, 'categories');

    return data.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('A category had an unexpected format.');
      }
      return CategoryModel.fromJson(item);
    }).toList();
  }

  Future<List<ProductModel>> getProducts(int categoryId) async {
    if (categoryId <= 0) {
      throw ArgumentError.value(categoryId, 'categoryId', 'Must be positive.');
    }

    final response = await ApiClient.dio.get('categories/$categoryId/products');
    final data = _extractList(response.data, 'products');

    return data.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('A product had an unexpected format.');
      }
      return ProductModel.fromJson(item);
    }).toList();
  }

  List<dynamic> _extractList(dynamic data, String resourceName) {
    if (data is List) return data;

    // Some API responses wrap their list in a `value` field and include Count.
    if (data is Map<String, dynamic> && data['value'] is List) {
      return data['value'] as List<dynamic>;
    }

    throw FormatException(
      'The $resourceName response had an unexpected format.',
    );
  }
}
