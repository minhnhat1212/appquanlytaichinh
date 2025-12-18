import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

class TransactionProvider with ChangeNotifier {
  List<TransactionModel> _transactions = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;

  List<TransactionModel> get transactions => _transactions;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;

  // Fetch Categories
  Future<void> fetchCategories(String userId) async {
    try {
      // Send userId in query params
      final uri = Uri.parse(
        ApiConstants.categories,
      ).replace(queryParameters: {'userId': userId});
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          _categories = (data['data'] as List)
              .map((item) => CategoryModel.fromJson(item))
              .toList();
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  // Add Category
  Future<bool> addCategory({
    required String name,
    required String type,
    required String icon,
    required String color,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.categories),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'type': type,
          'icon': icon,
          'color': color,
          'userId': userId,
        }),
      );
      if (response.statusCode == 200) {
        await fetchCategories(userId);
        return true;
      }
    } catch (e) {
      print('Error adding category: $e');
    }
    return false;
  }

  // Delete Category
  Future<bool> deleteCategory(String id, String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.categories}/$id'),
      );
      if (response.statusCode == 200) {
        await fetchCategories(userId);
        return true;
      }
    } catch (e) {
      print('Error deleting category: $e');
    }
    return false;
  }

  // Fetch Transactions
  Future<void> fetchTransactions(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.transactions(userId)),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          _transactions = (data['data'] as List)
              .map((item) => TransactionModel.fromJson(item))
              .toList();
        }
      }
    } catch (e) {
      print('Error fetching transactions: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  // Add Transaction
  Future<bool> addTransaction({
    required String userId,
    required String categoryId,
    required double amount,
    required String type,
    required DateTime date,
    String note = '',
    List<String> tags = const [],
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.addTransaction),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'categoryId': categoryId,
          'amount': amount,
          'type': type,
          'date': date.toIso8601String(),
          'note': note,
          'tags': tags,
        }),
      );

      if (response.statusCode == 200) {
        await fetchTransactions(userId); // Refresh list
        return true;
      }
    } catch (e) {
      print('Error adding transaction: $e');
    }
    return false;
  }

  // Delete Transaction
  Future<bool> deleteTransaction(String id, String userId) async {
    try {
      final response = await http.delete(
        Uri.parse(ApiConstants.deleteTransaction(id)),
      );
      if (response.statusCode == 200) {
        _transactions.removeWhere((t) => t.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Error deleting transaction: $e');
    }
    return false;
  }
}
