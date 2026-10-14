import '../../domain/entities/product.dart';

class ProductModel {
  final int id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;

  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final id = int.tryParse('${json['id']}');
    final title = json['title'];
    final description = json['description'];
    final price = json['price'];
    if (id == null ||
        id <= 0 ||
        title is! String ||
        description is! String ||
        price is! num) {
      throw const FormatException('Invalid product fields.');
    }

    return ProductModel(
      id: id,
      title: title,
      description: description,
      price: price.toDouble(),
      imageUrl: _firstUsableImageUrl(json['images']),
    );
  }

  static String _firstUsableImageUrl(dynamic images) {
    if (images is! List) return '';
    for (final value in images) {
      if (value is! String || value.trim().isEmpty) continue;
      final uri = Uri.tryParse(value.trim());
      if (uri != null &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.host.isNotEmpty) {
        return uri.toString();
      }
    }
    return '';
  }

  Product toEntity() => Product(
    id: id,
    name: title,
    description: description,
    price: price,
    imageUrl: imageUrl,
  );
}
