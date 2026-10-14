class CategoryModel {
  final int id;
  final String name;

  const CategoryModel({required this.id, required this.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final id = int.tryParse('${json['id']}');
    final name = json['name'];

    if (id == null || id <= 0 || name is! String || name.trim().isEmpty) {
      throw const FormatException('A category is missing its ID or name.');
    }

    return CategoryModel(id: id, name: name.trim());
  }

  String get displayName => name.toLowerCase() == 'clothes' ? 'Clothing' : name;
}
