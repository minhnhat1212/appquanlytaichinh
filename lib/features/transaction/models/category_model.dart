class CategoryModel {
  final String id;
  final String name;
  final String type; // 'income' or 'expense'
  final String icon;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'],
      name: json['name'],
      type: json['type'],
      icon: json['icon'],
    );
  }
}
