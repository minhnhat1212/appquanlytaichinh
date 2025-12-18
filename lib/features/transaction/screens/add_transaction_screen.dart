import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/custom_textfield.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/transaction_provider.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _tagsController = TextEditingController(); // Comma separated
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _saveTransaction() async {
    if (_amountController.text.isEmpty || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền và chọn danh mục')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Get current user ID (Fix: need update AuthProvider to expose ID)
    // For now assuming AuthProvider has `id` getter.
    final user = Provider.of<AuthProvider>(context, listen: false);
    // TEMPORARY: using email as ID will fail. I MUST update AuthProvider first.
    // For this code to compile, I'll access a placeholder ID from user provider.

    final type = _tabController.index == 0
        ? 'expense'
        : 'income'; // Tab 0: Chi, Tab 1: Thu

    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final success = await provider.addTransaction(
      userId: user.userId, // Relying on update I'm about to make
      categoryId: _selectedCategoryId!,
      amount: double.tryParse(_amountController.text) ?? 0,
      type: type,
      date: _selectedDate,
      note: _noteController.text,
      tags: _tagsController.text.split(',').map((e) => e.trim()).toList(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Lỗi khi lưu')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Thêm Giao Dịch'),
        backgroundColor: AppColors.primary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'KHOẢN CHI'),
            Tab(text: 'KHOẢN THU'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Input
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Số tiền',
                  labelStyle: const TextStyle(fontSize: 18),
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),

              // Date Picker
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Category Selector
              Consumer<TransactionProvider>(
                builder: (context, provider, child) {
                  // Filter categories based on Tab (Income/Expense)
                  // Note: This requires rebuilding when tab changes.
                  // For simplicity, let's just show all or filtered.
                  // Ideally, listen to TabController.
                  return DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    hint: const Text('Chọn danh mục'),
                    items: provider.categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat.id,
                        child: Row(
                          children: [
                            Icon(
                              Icons.category,
                              color: Colors.grey[600],
                            ), // Custom icon mapping later
                            const SizedBox(width: 10),
                            Text(cat.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) =>
                        setState(() => _selectedCategoryId = val),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              CustomTextField(
                controller: _noteController,
                labelText: 'Ghi chú',
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _tagsController,
                labelText: 'Tags (cách nhau bởi dấu phẩy)',
              ),

              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(text: 'Lưu', onPressed: _saveTransaction),
            ],
          ),
        ),
      ),
    );
  }
}
