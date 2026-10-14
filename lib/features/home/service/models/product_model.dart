import 'package:flutter/material.dart';

import '../../../../core/dummy_data.dart';

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
    final images = json['images'];

    if (id == null ||
        title is! String ||
        description is! String ||
        price is! num) {
      throw const FormatException('A product had missing or invalid fields.');
    }

    final imageUrl = _firstUsableImageUrl(images);

    return ProductModel(
      id: id,
      title: title,
      description: description,
      price: price.toDouble(),
      imageUrl: imageUrl,
    );
  }

  static String _firstUsableImageUrl(dynamic images) {
    if (images is! List) return '';

    for (final image in images) {
      if (image is! String || image.trim().isEmpty) continue;

      final uri = Uri.tryParse(image.trim());
      if (uri != null &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.host.isNotEmpty) {
        return uri.toString();
      }
    }

    return '';
  }

  // ProductCard and the existing details screen use the app's Product type.
  // The API has no color or size fields, so the details screen gets neutral defaults.
  Product toProduct() => Product(
    id: '$id',
    name: title,
    description: description,
    price: price,
    imageUrl: imageUrl,
    colors: const [Colors.black],
    sizes: const ['One Size'],
  );
}
