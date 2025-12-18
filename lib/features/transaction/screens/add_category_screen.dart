import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/custom_textfield.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/transaction_provider.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({Key? key}) : super(key: key);

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _nameController = TextEditingController();
  String _type = 'expense'; // expense or income
  String _selectedColor = '0xFFEF5350'; // Red
  String _selectedIcon = 'check_circle';
  bool _isLoading = false;

  final List<String> _colors = [
    '0xFFEF5350',
    '0xFFEC407A',
    '0xFFAB47BC',
    '0xFF7E57C2',
    '0xFF5C6BC0',
    '0xFF42A5F5',
    '0xFF29B6F6',
    '0xFF26C6DA',
    '0xFF26A69A',
    '0xFF66BB6A',
    '0xFF9CCC65',
    '0xFFD4E157',
    '0xFFFFEE58',
    '0xFFFFCA28',
    '0xFFFF7043',
    '0xFF8D6E63',
  ];

  final Map<String, IconData> _icons = {
    'restaurant': Icons.restaurant,
    'directions_car': Icons.directions_car,
    'home': Icons.home,
    'movie': Icons.movie,
    'shopping_bag': Icons.shopping_bag,
    'shopping_cart': Icons.shopping_cart,
    'flight': Icons.flight,
    'school': Icons.school,
    'medical_services': Icons.medical_services,
    'sports_soccer': Icons.sports_soccer,
    'pets': Icons.pets,
    'work': Icons.work,
  };

  void _save() async {
    if (_nameController.text.isEmpty) return;

    setState(() => _isLoading = true);
    final user = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    final success = await provider.addCategory(
      name: _nameController.text,
      type: _type,
      icon: _selectedIcon,
      color: _selectedColor,
      userId: user.userId,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Thêm Danh Mục'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type Selector
            Row(
              children: [
                Expanded(
                  child: RadioListTile(
                    title: const Text('Khoản Chi'),
                    value: 'expense',
                    groupValue: _type,
                    onChanged: (v) => setState(() => _type = v.toString()),
                  ),
                ),
                Expanded(
                  child: RadioListTile(
                    title: const Text('Khoản Thu'),
                    value: 'income',
                    groupValue: _type,
                    onChanged: (v) => setState(() => _type = v.toString()),
                  ),
                ),
              ],
            ),

            CustomTextField(
              controller: _nameController,
              labelText: 'Tên danh mục',
            ),
            const SizedBox(height: 20),

            const Text(
              'Chọn Màu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _colors
                  .map(
                    (c) => GestureDetector(
                      onTap: () => setState(() => _selectedColor = c),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(int.parse(c)),
                          shape: BoxShape.circle,
                          border: _selectedColor == c
                              ? Border.all(width: 3, color: Colors.black)
                              : null,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),

            const Text(
              'Chọn Icon',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _icons.entries
                  .map(
                    (e) => GestureDetector(
                      onTap: () => setState(() => _selectedIcon = e.key),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _selectedIcon == e.key
                              ? AppColors.primary.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                          border: _selectedIcon == e.key
                              ? Border.all(color: AppColors.primary)
                              : null,
                        ),
                        child: Icon(e.value, size: 30, color: AppColors.black),
                      ),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 30),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomButton(text: 'Lưu', onPressed: _save),
          ],
        ),
      ),
    );
  }
}
