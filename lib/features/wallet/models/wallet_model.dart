import 'dart:convert';

class WalletModel {
  final String id;
  final String name;
  final String type; // cash | bank | eWallet
  final String? institution;
  final String? accountNumber;
  final double balance;
  final String currency;
  final bool isDefault;
  final String color; // hex string e.g. #4285F4
  final DateTime createdAt;

  const WalletModel({
    required this.id,
    required this.name,
    required this.type,
    this.institution,
    this.accountNumber,
    this.balance = 0,
    this.currency = 'VND',
    this.isDefault = false,
    this.color = '#4285F4',
    required this.createdAt,
  });

  WalletModel copyWith({
    String? id,
    String? name,
    String? type,
    String? institution,
    String? accountNumber,
    double? balance,
    String? currency,
    bool? isDefault,
    String? color,
    DateTime? createdAt,
  }) {
    return WalletModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      institution: institution ?? this.institution,
      accountNumber: accountNumber ?? this.accountNumber,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      isDefault: isDefault ?? this.isDefault,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'institution': institution,
      'accountNumber': accountNumber,
      'balance': balance,
      'currency': currency,
      'isDefault': isDefault,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      institution: json['institution'],
      accountNumber: json['accountNumber'],
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] ?? 'VND',
      isDefault: json['isDefault'] ?? false,
      color: json['color'] ?? '#4285F4',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  static List<WalletModel> decodeList(String? value) {
    if (value == null || value.isEmpty) return [];
    final List<dynamic> raw = jsonDecode(value) as List<dynamic>;
    return raw.map((e) => WalletModel.fromJson(e)).toList();
  }

  static String encodeList(List<WalletModel> wallets) {
    return jsonEncode(wallets.map((e) => e.toJson()).toList());
  }
}

