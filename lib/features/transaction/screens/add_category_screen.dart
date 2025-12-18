import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/transaction_provider.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({Key? key}) : super(key: key);

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _nameController = TextEditingController();
  String _selectedType = 'expense';
  String _selectedIcon = 'category';
  Color _selectedColor = Colors.blue;
  bool _isLoading = false;

  final List<String> _icons = [
    'food',
    'shopping',
    'transport',
    'bills',
    'entertainment',
    'category',
    'gift',
    'salary',
  ];

  final List<Color> _colors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.brown,
  ];

  void _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên danh mục')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = Provider.of<AuthProvider>(context, listen: false);
    final hexColor = '#${_selectedColor.value.toRadixString(16).substring(2)}';

    final success =
        await Provider.of<TransactionProvider>(
          context,
          listen: false,
        ).addCategory(
          userId: user.userId,
          name: name,
          type: _selectedType,
          icon: _selectedIcon,
          color: hexColor,
        );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) Navigator.pop(context);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Có lỗi xảy ra')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm danh mục'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview Circle
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: _selectedColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: _selectedColor, width: 2),
                ),
                child: Icon(
                  _getIconData(_selectedIcon),
                  size: 40,
                  color: _selectedColor,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Name Input
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Tên danh mục',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Type Selector
            Row(
              children: [
                Expanded(
                  child: _buildTypeButton(
                    'Chi phí',
                    'expense',
                    AppColors.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTypeButton(
                    'Thu nhập',
                    'income',
                    AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Color Picker
            const Text(
              'Màu sắc',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _colors
                  .map(
                    (color) => GestureDetector(
                      onTap: () => setState(() => _selectedColor = color),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: _selectedColor == color
                              ? Border.all(color: Colors.black54, width: 3)
                              : null,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 24),

            // Icon Picker
            const Text(
              'Biểu tượng',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _icons
                  .map(
                    (icon) => GestureDetector(
                      onTap: () => setState(() => _selectedIcon = icon),
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: _selectedIcon == icon
                              ? Border.all(color: AppColors.primary, width: 2)
                              : null,
                        ),
                        child: Icon(
                          _getIconData(icon),
                          color: _selectedIcon == icon
                              ? AppColors.primary
                              : Colors.grey,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Lưu danh mục',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String label, String value, Color activeColor) {
    final isSelected = _selectedType == value;
    return InkWell(
      onTap: () => setState(() => _selectedType = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: activeColor, width: 2) : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? activeColor : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'food':
        return Icons.fastfood;
      case 'shopping':
        return Icons.shopping_bag;
      case 'transport':
        return Icons.directions_car;
      case 'bills':
        return Icons.receipt;
      case 'entertainment':
        return Icons.movie;
      case 'salary':
        return Icons.attach_money;
      case 'gift':
        return Icons.card_giftcard;
      default:
        return Icons.category;
    }
  }
}
