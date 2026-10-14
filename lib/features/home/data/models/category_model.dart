import '../../domain/entities/category.dart';

class CategoryModel {
  final int id;
  final String name;

  const CategoryModel({required this.id, required this.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final id = int.tryParse('${json['id']}');
    final name = json['name'];
    if (id == null || id <= 0 || name is! String || name.trim().isEmpty) {
      throw const FormatException('Invalid category fields.');
    }
    return CategoryModel(id: id, name: name.trim());
  }

  Category toEntity() => Category(id: id, name: name);
}
