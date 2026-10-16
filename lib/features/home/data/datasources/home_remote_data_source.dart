import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';

class HomeRemoteDataSource {
  final Dio dio;

  const HomeRemoteDataSource(this.dio);

  Future<dynamic> getCategories() async =>
      (await dio.get(ApiEndpoints.categories)).data;

  Future<dynamic> getProductById(int productId) async {
    if (productId <= 0) {
      throw ArgumentError.value(productId, 'productId');
    }
    return (await dio.get(ApiEndpoints.productDetails(productId))).data;
  }

  Future<dynamic> getProducts({
    required int limit,
    required int offset,
  }) async => (await dio.get(
    ApiEndpoints.products,
    queryParameters: {'limit': limit, 'offset': offset},
  )).data;

  Future<dynamic> getProductsByCategory(
    int categoryId, {
    required int limit,
    required int offset,
  }) async {
    if (categoryId <= 0) {
      throw ArgumentError.value(categoryId, 'categoryId');
    }
    return (await dio.get(
      ApiEndpoints.categoryProducts(categoryId),
      queryParameters: {'limit': limit, 'offset': offset},
    )).data;
  }
}
