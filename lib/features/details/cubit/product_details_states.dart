import '../../home/domain/entities/product.dart';

abstract class ProductDetailsState {
  const ProductDetailsState();
}

class ProductDetailsInitial extends ProductDetailsState {
  const ProductDetailsInitial();
}

class ProductDetailsLoading extends ProductDetailsState {
  final int productId;

  const ProductDetailsLoading(this.productId);
}

class ProductDetailsSuccess extends ProductDetailsState {
  final Product product;

  const ProductDetailsSuccess(this.product);
}

class ProductDetailsError extends ProductDetailsState {
  final int productId;
  final String message;

  const ProductDetailsError({required this.productId, required this.message});
}
