import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/v4.dart';

import '../models/transfer_model.dart';
import '../models/wallet_model.dart';

class WalletProvider with ChangeNotifier {
  static const _prefsWalletsKey = 'wallets';
  static const _prefsTransfersKey = 'walletTransfers';

  final _uuid = const UuidV4();

  List<WalletModel> _wallets = [];
  List<TransferModel> _transfers = [];
  bool _isLoading = false;

  List<WalletModel> get wallets => _wallets;
  List<TransferModel> get transfers => _transfers;
  bool get isLoading => _isLoading;

  WalletModel? get defaultWallet {
    if (_wallets.isEmpty) return null;
    return _wallets.firstWhere(
      (w) => w.isDefault,
      orElse: () => _wallets.first,
    );
  }

  double get totalBalance =>
      _wallets.fold(0, (prev, w) => prev + (w.balance));

  WalletProvider() {
    load();
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    _wallets = WalletModel.decodeList(prefs.getString(_prefsWalletsKey));
    _transfers = TransferModel.decodeList(prefs.getString(_prefsTransfersKey));

    // Ensure there is always a default wallet if list is not empty
    if (_wallets.isNotEmpty && !_wallets.any((w) => w.isDefault)) {
      _wallets[0] = _wallets[0].copyWith(isDefault: true);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsWalletsKey, WalletModel.encodeList(_wallets));
    await prefs.setString(
      _prefsTransfersKey,
      TransferModel.encodeList(_transfers),
    );
  }

  Future<void> addWallet({
    required String name,
    required String type,
    String? institution,
    String? accountNumber,
    double initialBalance = 0,
    String currency = 'VND',
    bool makeDefault = false,
    String color = '#4285F4',
  }) async {
    final now = DateTime.now();
    final wallet = WalletModel(
      id: _uuid.generate(),
      name: name,
      type: type,
      institution: institution,
      accountNumber: accountNumber,
      balance: initialBalance,
      currency: currency,
      isDefault: false,
      color: color,
      createdAt: now,
    );

    if (makeDefault || _wallets.isEmpty) {
      _wallets = _wallets.map((w) => w.copyWith(isDefault: false)).toList();
      _wallets.add(wallet.copyWith(isDefault: true));
    } else {
      _wallets.add(wallet);
    }

    await _persist();
    notifyListeners();
  }

  Future<void> setDefault(String walletId) async {
    _wallets = _wallets
        .map(
          (w) => w.copyWith(isDefault: w.id == walletId),
        )
        .toList();
    await _persist();
    notifyListeners();
  }

  WalletModel? getById(String id) {
    try {
      return _wallets.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> transfer({
    required String fromWalletId,
    required String toWalletId,
    required double amount,
    String note = '',
  }) async {
    if (fromWalletId == toWalletId) return false;
    if (amount <= 0) return false;

    final fromIndex = _wallets.indexWhere((w) => w.id == fromWalletId);
    final toIndex = _wallets.indexWhere((w) => w.id == toWalletId);
    if (fromIndex == -1 || toIndex == -1) return false;

    final fromWallet = _wallets[fromIndex];
    final toWallet = _wallets[toIndex];

    if (fromWallet.balance < amount) return false;

    _wallets[fromIndex] =
        fromWallet.copyWith(balance: fromWallet.balance - amount);
    _wallets[toIndex] = toWallet.copyWith(balance: toWallet.balance + amount);

    _transfers = [
      TransferModel(
        id: _uuid.generate(),
        fromWalletId: fromWalletId,
        toWalletId: toWalletId,
        amount: amount,
        note: note,
        createdAt: DateTime.now(),
      ),
      ..._transfers,
    ];

    await _persist();
    notifyListeners();
    return true;
  }

  Future<void> deleteWallet(String walletId) async {
    _wallets.removeWhere((w) => w.id == walletId);
    // Also remove related transfers for cleanliness
    _transfers.removeWhere(
      (t) => t.fromWalletId == walletId || t.toWalletId == walletId,
    );

    if (_wallets.isNotEmpty && !_wallets.any((w) => w.isDefault)) {
      _wallets[0] = _wallets[0].copyWith(isDefault: true);
    }

    await _persist();
    notifyListeners();
  }
}

