class Category {
  final int id;
  final String name;

  const Category({required this.id, required this.name});

  String get displayName => name.toLowerCase() == 'clothes' ? 'Clothing' : name;
}
