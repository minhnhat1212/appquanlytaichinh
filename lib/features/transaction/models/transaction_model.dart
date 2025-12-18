import 'category_model.dart';

class TransactionModel {
  final String id;
  final String userId;
  final CategoryModel category;
  final double amount;
  final String type; // 'income' or 'expense'
  final DateTime date;
  final String note;
  final List<String> tags;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.amount,
    required this.type,
    required this.date,
    this.note = '',
    this.tags = const [],
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['_id'],
      userId: json['user'],
      category: CategoryModel.fromJson(json['category']),
      amount: (json['amount'] as num).toDouble(),
      type: json['type'],
      date: DateTime.parse(json['date']),
      note: json['note'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}
