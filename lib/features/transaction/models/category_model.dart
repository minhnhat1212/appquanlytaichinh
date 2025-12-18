class CategoryModel {
  final String id;
  final String name;
  final String type; // 'income' or 'expense'
  final String icon;
  final String color;
  final bool isDefault;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    this.color = '0xFF000000',
    this.isDefault = false,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'],
      name: json['name'],
      type: json['type'],
      icon: json['icon'],
      color: json['color'] ?? '0xFF000000',
      isDefault: json['isDefault'] ?? false,
    );
  }
}
