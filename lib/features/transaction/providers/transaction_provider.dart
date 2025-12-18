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
  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse(ApiConstants.categories));
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
