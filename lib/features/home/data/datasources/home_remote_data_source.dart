import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';

class HomeRemoteDataSource {
  final Dio dio;

  const HomeRemoteDataSource(this.dio);

  Future<dynamic> getCategories() async =>
      (await dio.get(ApiEndpoints.categories)).data;

  Future<dynamic> getProducts() async =>
      (await dio.get(ApiEndpoints.products)).data;

  Future<dynamic> getProductsByCategory(int categoryId) async {
    if (categoryId <= 0) {
      throw ArgumentError.value(categoryId, 'categoryId');
    }
    return (await dio.get(ApiEndpoints.categoryProducts(categoryId))).data;
  }
}
