import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/app_failure.dart';
import '../../home/domain/usecases/get_product_by_id.dart';
import 'product_details_states.dart';

class ProductDetailsCubit extends Cubit<ProductDetailsState> {
  final GetProductById productLoader;
  int _requestNumber = 0;

  ProductDetailsCubit(this.productLoader)
    : super(const ProductDetailsInitial());

  Future<void> loadProduct(int productId) async {
    if (productId <= 0) {
      emit(
        const ProductDetailsError(
          productId: 0,
          message: 'This product link is invalid.',
        ),
      );
      return;
    }

    final requestNumber = ++_requestNumber;
    emit(ProductDetailsLoading(productId));
    try {
      final product = await productLoader(productId);
      if (!isClosed && requestNumber == _requestNumber) {
        emit(ProductDetailsSuccess(product));
      }
    } on AppFailure catch (failure) {
      if (!isClosed && requestNumber == _requestNumber) {
        emit(
          ProductDetailsError(
            productId: productId,
            message: _failureMessage(failure),
          ),
        );
      }
    } catch (_) {
      if (!isClosed && requestNumber == _requestNumber) {
        emit(
          ProductDetailsError(
            productId: productId,
            message: 'Could not load this product. Please try again.',
          ),
        );
      }
    }
  }

  Future<void> retry() async {
    final current = state;
    if (current is ProductDetailsError && current.productId > 0) {
      await loadProduct(current.productId);
    }
  }

  String _failureMessage(AppFailure failure) => switch (failure.type) {
    FailureType.connection =>
      'Unable to connect. Check your internet connection and try again.',
    FailureType.server =>
      'The server is temporarily unavailable. Try again later.',
    FailureType.rejected => 'This product could not be found.',
    _ => 'Could not load this product. Please try again.',
  };
}
