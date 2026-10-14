import 'package:dio/dio.dart';

import '../../../../core/errors/app_failure.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  const HomeRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Category>> getCategories() async {
    try {
      return _asList(
        await remoteDataSource.getCategories(),
        'categories',
      ).map((json) => CategoryModel.fromJson(json).toEntity()).toList();
    } on DioException catch (error) {
      throw _mapDioFailure(error);
    } on FormatException {
      throw const AppFailure(FailureType.unexpected);
    }
  }

  @override
  Future<List<Product>> getProducts() async {
    try {
      return _asList(
        await remoteDataSource.getProducts(),
        'products',
      ).map((json) => ProductModel.fromJson(json).toEntity()).toList();
    } on DioException catch (error) {
      throw _mapDioFailure(error);
    } on FormatException {
      throw const AppFailure(FailureType.unexpected);
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(int categoryId) async {
    try {
      return _asList(
        await remoteDataSource.getProductsByCategory(categoryId),
        'products',
      ).map((json) => ProductModel.fromJson(json).toEntity()).toList();
    } on DioException catch (error) {
      throw _mapDioFailure(error);
    } on FormatException {
      throw const AppFailure(FailureType.unexpected);
    }
  }

  List<Map<String, dynamic>> _asList(dynamic response, String label) {
    dynamic value = response;
    if (value is Map<String, dynamic> && value['value'] is List) {
      value = value['value'];
    }
    if (value is! List) {
      throw FormatException('Unexpected $label response format.');
    }
    return value.map((item) {
      if (item is! Map) throw FormatException('Invalid $label item.');
      return Map<String, dynamic>.from(item);
    }).toList();
  }

  AppFailure _mapDioFailure(DioException error) {
    final status = error.response?.statusCode;
    if (status == null) return const AppFailure(FailureType.connection);
    if (status >= 500) return const AppFailure(FailureType.server);
    return const AppFailure(FailureType.rejected);
  }
}
