import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../providers/wallet_provider.dart';

class WalletTransferScreen extends StatefulWidget {
  const WalletTransferScreen({super.key});

  @override
  State<WalletTransferScreen> createState() => _WalletTransferScreenState();
}

class _WalletTransferScreenState extends State<WalletTransferScreen> {
  String? _fromWalletId;
  String? _toWalletId;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is String && _fromWalletId == null) {
      _fromWalletId = arg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WalletProvider>(context);
    final wallets = provider.wallets;
    final currencyFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chuyển tiền giữa ví'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: wallets.isEmpty
          ? const Center(child: Text('Bạn chưa có ví để chuyển'))
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _walletDropdown(
                    label: 'Từ ví',
                    value: _fromWalletId,
                    wallets: wallets,
                    onChanged: (val) => setState(() => _fromWalletId = val),
                  ),
                  const SizedBox(height: 16),
                  _walletDropdown(
                    label: 'Đến ví',
                    value: _toWalletId,
                    wallets: wallets,
                    onChanged: (val) => setState(() => _toWalletId = val),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Số tiền',
                      suffixText: '₫',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Ghi chú (tùy chọn)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const Spacer(),
                  if (_fromWalletId != null)
                    _balanceInfo(
                      'Số dư hiện tại',
                      currencyFormatter.format(
                        provider.getById(_fromWalletId!)?.balance ?? 0,
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : () => _submit(provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Xác nhận chuyển',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _walletDropdown({
    required String label,
    required String? value,
    required List wallets,
    required ValueChanged<String?> onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: wallets
              .map<DropdownMenuItem<String>>(
                (w) => DropdownMenuItem(
                  value: w.id,
                  child: Text('${w.name} • ${_typeLabel(w.type)}'),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _balanceInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'cash':
        return 'Tiền mặt';
      case 'bank':
        return 'Ngân hàng';
      case 'eWallet':
        return 'Ví điện tử';
      default:
        return 'Khác';
    }
  }

  Future<void> _submit(WalletProvider provider) async {
    if (_fromWalletId == null || _toWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chọn ví nguồn và ví đích')),
      );
      return;
    }
    final amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số tiền phải lớn hơn 0')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    final ok = await provider.transfer(
      fromWalletId: _fromWalletId!,
      toWalletId: _toWalletId!,
      amount: amount,
      note: _noteController.text.trim(),
    );
    setState(() => _isSubmitting = false);

    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không hợp lệ (ví trùng nhau hoặc thiếu số dư)')),
      );
      return;
    }
    if (mounted) Navigator.pop(context);
  }
}

