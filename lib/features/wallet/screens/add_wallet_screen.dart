import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../providers/wallet_provider.dart';

class AddWalletScreen extends StatefulWidget {
  const AddWalletScreen({super.key});

  @override
  State<AddWalletScreen> createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends State<AddWalletScreen> {
  final _nameController = TextEditingController();
  final _institutionController = TextEditingController();
  final _accountController = TextEditingController();
  final _balanceController = TextEditingController(text: '0');

  String _type = 'cash';
  bool _makeDefault = false;
  Color _selectedColor = AppColors.primary;
  final _colors = const [
    AppColors.primary,
    AppColors.secondary,
    AppColors.success,
    AppColors.accent,
    Colors.orange,
    Colors.pink,
  ];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _institutionController.dispose();
    _accountController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showBankFields = _type != 'cash';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm ví'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _typeButton('Tiền mặt', 'cash', Icons.payments)),
                const SizedBox(width: 12),
                Expanded(child: _typeButton('Ngân hàng', 'bank', Icons.account_balance)),
                const SizedBox(width: 12),
                Expanded(child: _typeButton('Ví điện tử', 'eWallet', Icons.phone_iphone)),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Tên ví',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _balanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số dư ban đầu',
                suffixText: '₫',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (showBankFields) ...[
              TextField(
                controller: _institutionController,
                decoration: const InputDecoration(
                  labelText: 'Ngân hàng / Nhà cung cấp',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _accountController,
                decoration: const InputDecoration(
                  labelText: 'Số tài khoản / SĐT',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
            ],
            const Text(
              'Màu ví',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _colors
                  .map(
                    (c) => GestureDetector(
                      onTap: () => setState(() => _selectedColor = c),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c,
                          border: Border.all(
                            color: _selectedColor == c
                                ? Colors.black26
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _makeDefault,
              onChanged: (val) => setState(() => _makeDefault = val ?? false),
              title: const Text('Đặt làm ví mặc định'),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Lưu',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeButton(String label, String value, IconData icon) {
    final isSelected = _type == value;
    return InkWell(
      onTap: () => setState(() => _type = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : Colors.grey),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên ví')),
      );
      return;
    }

    final balance = double.tryParse(_balanceController.text.replaceAll(',', '')) ?? 0;

    setState(() => _isSubmitting = true);
    final provider = Provider.of<WalletProvider>(context, listen: false);
    await provider.addWallet(
      name: name,
      type: _type,
      institution: _institutionController.text.trim().isEmpty
          ? null
          : _institutionController.text.trim(),
      accountNumber: _accountController.text.trim().isEmpty
          ? null
          : _accountController.text.trim(),
      initialBalance: balance,
      makeDefault: _makeDefault,
      color: '#${_selectedColor.value.toRadixString(16).substring(2)}',
    );
    setState(() => _isSubmitting = false);
    if (mounted) Navigator.pop(context);
  }
}

