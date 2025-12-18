import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../../../../widgets/custom_button.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _tagController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedType = 'expense'; // 'income' or 'expense'
  String? _selectedCategoryId;
  List<String> _tags = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Ensure categories are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false);
      if (user.isLoggedIn) {
        Provider.of<TransactionProvider>(
          context,
          listen: false,
        ).fetchCategories(user.userId);
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addTag() {
    final text = _tagController.text.trim();
    if (text.isNotEmpty && !_tags.contains(text)) {
      setState(() {
        _tags.add(text);
        _tagController.clear();
      });
    }
  }

  void _submit() async {
    final amountText = _amountController.text.replaceAll(',', '');
    if (amountText.isEmpty || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền và chọn danh mục')),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null) return;

    setState(() => _isLoading = true);

    final user = Provider.of<AuthProvider>(context, listen: false);
    final success =
        await Provider.of<TransactionProvider>(
          context,
          listen: false,
        ).addTransaction(
          userId: user.userId,
          categoryId: _selectedCategoryId!,
          amount: amount,
          type: _selectedType,
          date: _selectedDate,
          note: _noteController.text,
          tags: _tags,
        );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) Navigator.pop(context);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra, vui lòng thử lại')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);

    // Filter categories based on selected type (income/expense)
    final categories = transactionProvider.categories
        .where((c) => c.type == _selectedType)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Giao Dịch'),
        backgroundColor: _selectedType == 'expense'
            ? AppColors.accent
            : AppColors.success,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Type Selector Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: _selectedType == 'expense'
                  ? AppColors.accent
                  : AppColors.success,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTypeButton('Chi phí', 'expense'),
                    const SizedBox(width: 16),
                    _buildTypeButton('Thu nhập', 'income'),
                  ],
                ),
                const SizedBox(height: 20),
                // Amount Input (Large)
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    hintText: '0',
                    hintStyle: TextStyle(color: Colors.white60),
                    border: InputBorder.none,
                    suffixText: '₫',
                    suffixStyle: TextStyle(color: Colors.white70, fontSize: 24),
                  ),
                  onChanged: (val) {
                    // Simple formatting logic could go here
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Picker
                  InkWell(
                    onTap: () => _selectDate(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('dd/MM/yyyy').format(_selectedDate),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Spacer(),
                          const Icon(Icons.chevron_right, color: Colors.grey),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category Selector
                  const Text(
                    'Danh mục',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  categories.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: TextButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Tạo danh mục mới'),
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/categories'),
                            ),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                childAspectRatio: 0.8,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemCount: categories.length + 1, // +1 for add button
                          itemBuilder: (context, index) {
                            if (index == categories.length) {
                              return InkWell(
                                onTap: () =>
                                    Navigator.pushNamed(context, '/categories'),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[200],
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Khác',
                                      style: TextStyle(fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            }

                            final cat = categories[index];
                            final isSelected = _selectedCategoryId == cat.id;

                            return InkWell(
                              onTap: () =>
                                  setState(() => _selectedCategoryId = cat.id),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color:
                                          (cat.color != null
                                                  ? Color(
                                                      int.parse(
                                                        cat.color!.replaceFirst(
                                                          '#',
                                                          '0xFF',
                                                        ),
                                                      ),
                                                    )
                                                  : (_selectedType == 'expense'
                                                        ? AppColors.expense
                                                        : AppColors.income))
                                              .withOpacity(0.1),
                                      shape: BoxShape.circle,
                                      border: isSelected
                                          ? Border.all(
                                              color: (cat.color != null
                                                  ? Color(
                                                      int.parse(
                                                        cat.color!.replaceFirst(
                                                          '#',
                                                          '0xFF',
                                                        ),
                                                      ),
                                                    )
                                                  : (_selectedType == 'expense'
                                                        ? AppColors.expense
                                                        : AppColors.income)),
                                              width: 2,
                                            )
                                          : null,
                                    ),
                                    child: Icon(
                                      _getIconData(cat.icon),
                                      color: cat.color != null
                                          ? Color(
                                              int.parse(
                                                cat.color!.replaceFirst(
                                                  '#',
                                                  '0xFF',
                                                ),
                                              ),
                                            )
                                          : (_selectedType == 'expense'
                                                ? AppColors.expense
                                                : AppColors.income),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    cat.name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                  const SizedBox(height: 20),

                  // Note Input
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      labelText: 'Ghi chú',
                      prefixIcon: const Icon(Icons.notes),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tags Input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _tagController,
                          decoration: InputDecoration(
                            labelText: 'Thêm thẻ (Tags)',
                            prefixIcon: const Icon(Icons.local_offer_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onSubmitted: (_) => _addTag(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: _addTag,
                        icon: const Icon(
                          Icons.add_circle,
                          size: 32,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  if (_tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Wrap(
                        spacing: 8,
                        children: _tags
                            .map(
                              (tag) => Chip(
                                label: Text(tag),
                                deleteIcon: const Icon(Icons.close, size: 18),
                                onDeleted: () =>
                                    setState(() => _tags.remove(tag)),
                                backgroundColor: AppColors.primary.withOpacity(
                                  0.1,
                                ),
                                labelStyle: const TextStyle(
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),

                  const SizedBox(height: 30),
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
                              'Lưu giao dịch',
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
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(String title, String type) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white24,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? (type == 'expense' ? AppColors.accent : AppColors.success)
                : Colors.white,
            fontWeight: FontWeight.bold,
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
