import 'dart:convert';

class TransferModel {
  final String id;
  final String fromWalletId;
  final String toWalletId;
  final double amount;
  final String note;
  final DateTime createdAt;

  const TransferModel({
    required this.id,
    required this.fromWalletId,
    required this.toWalletId,
    required this.amount,
    this.note = '',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromWalletId': fromWalletId,
      'toWalletId': toWalletId,
      'amount': amount,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TransferModel.fromJson(Map<String, dynamic> json) {
    return TransferModel(
      id: json['id'],
      fromWalletId: json['fromWalletId'],
      toWalletId: json['toWalletId'],
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      note: json['note'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  static List<TransferModel> decodeList(String? value) {
    if (value == null || value.isEmpty) return [];
    final List<dynamic> raw = jsonDecode(value) as List<dynamic>;
    return raw.map((e) => TransferModel.fromJson(e)).toList();
  }

  static String encodeList(List<TransferModel> transfers) {
    return jsonEncode(transfers.map((e) => e.toJson()).toList());
  }
}

