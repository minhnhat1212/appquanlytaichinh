import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/transaction_provider.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({Key? key}) : super(key: key);

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = Provider.of<AuthProvider>(context, listen: false);
      if (user.isLoggedIn) {
        Provider.of<TransactionProvider>(context, listen: false)
          ..fetchTransactions(user.userId)
          ..fetchCategories(user.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final userProvider = Provider.of<AuthProvider>(context);

    // Calculate totals
    double totalIncome = 0;
    double totalExpense = 0;
    for (var t in transactionProvider.transactions) {
      if (t.type == 'income') totalIncome += t.amount;
      if (t.type == 'expense') totalExpense += t.amount;
    }
    double balance = totalIncome - totalExpense;

    return Scaffold(
      extendBodyBehindAppBar: true, // For gradient background
      appBar: AppBar(
        title: const Text('Sổ Thu Chi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<TransactionProvider>(
                context,
                listen: false,
              ).fetchTransactions(userProvider.userId);
            },
          ),
          IconButton(
            icon: const Icon(Icons.category_outlined),
            onPressed: () => Navigator.pushNamed(context, '/categories'),
          ),
          IconButton(
            icon: const CircleAvatar(
              radius: 14,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, size: 18, color: Colors.white),
            ),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Dashboard Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 30),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Số dư hiện tại',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  NumberFormat.currency(
                    locale: 'vi_VN',
                    symbol: '₫',
                  ).format(balance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      'Thu nhập',
                      totalIncome,
                      Icons.arrow_upward,
                      Colors.greenAccent,
                    ),
                    Container(height: 40, width: 1, color: Colors.white24),
                    _buildSummaryItem(
                      'Chi tiêu',
                      totalExpense,
                      Icons.arrow_downward,
                      AppColors.accent,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Transaction List
          Expanded(
            child: transactionProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : transactionProvider.transactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có giao dịch nào',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    itemCount: transactionProvider.transactions.length,
                    itemBuilder: (context, index) {
                      final item = transactionProvider.transactions[index];
                      final isExpense = item.type == 'expense';

                      // Safe color parsing
                      Color categoryColor;
                      try {
                        categoryColor = Color(
                          int.parse(
                            item.category.color.replaceFirst('#', '0xFF'),
                          ),
                        );
                      } catch (e) {
                        categoryColor = isExpense
                            ? AppColors.expense
                            : AppColors.income;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppColors.shadowLight,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onLongPress: () => _confirmDelete(
                              context,
                              item,
                              transactionProvider,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  // Icon Box
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: categoryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _getIconData(item.category.icon),
                                      color: categoryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Content
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.category.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          DateFormat(
                                            'dd/MM/yyyy • HH:mm',
                                          ).format(item.date),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        if (item.note.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4.0,
                                            ),
                                            child: Text(
                                              item.note,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary
                                                    .withOpacity(0.8),
                                                fontStyle: FontStyle.italic,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  // Amount
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${isExpense ? '-' : '+'}${NumberFormat('#,###').format(item.amount)}',
                                        style: TextStyle(
                                          color: isExpense
                                              ? AppColors.expense
                                              : AppColors.income,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      if (item.tags.isNotEmpty)
                                        Container(
                                          margin: const EdgeInsets.only(top: 4),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[100],
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Text(
                                            item.tags.first, // Show first tag
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-transaction');
        },
        backgroundColor: AppColors.primary,
        elevation: 4,
        child: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
          ),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String label,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(color: Colors.white70)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          NumberFormat.compact().format(amount),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _confirmDelete(
    BuildContext context,
    dynamic item,
    TransactionProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa giao dịch?'),
        content: const Text('Bạn có chắc chắn muốn xóa giao dịch này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Hủy',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteTransaction(item.id, '');
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Xóa'),
          ),
        ],
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
