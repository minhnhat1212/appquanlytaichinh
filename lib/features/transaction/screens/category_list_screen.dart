import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import 'add_category_screen.dart';

class CategoryListScreen extends StatelessWidget {
  const CategoryListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Danh mục'),
          backgroundColor: AppColors.primary,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Chi phí'),
              Tab(text: 'Thu nhập'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(context, '/add-category');
              },
            ),
          ],
        ),
        body: Consumer2<TransactionProvider, AuthProvider>(
          builder: (context, provider, auth, child) {
            final userId = auth.userId;

            // Filter categories
            final expenseCategories = provider.categories
                .where((c) => c.type == 'expense')
                .toList();
            final incomeCategories = provider.categories
                .where((c) => c.type == 'income')
                .toList();

            return TabBarView(
              children: [
                _buildCategoryList(
                  context,
                  expenseCategories,
                  provider,
                  userId,
                ),
                _buildCategoryList(context, incomeCategories, provider, userId),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryList(
    BuildContext context,
    List<dynamic> categories,
    TransactionProvider provider,
    String userId,
  ) {
    if (categories.isEmpty) {
      return const Center(child: Text('Chưa có danh mục nào'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      separatorBuilder: (ctx, i) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final cat = categories[index];
        final isCustom = !cat.isDefault;

        Color catColor;
        try {
          catColor = Color(int.parse(cat.color.replaceFirst('#', '0xFF')));
        } catch (_) {
          catColor = Colors.grey;
        }

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: AppColors.shadowLight,
          ),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: catColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(_getIconData(cat.icon), color: catColor, size: 20),
            ),
            title: Text(
              cat.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: isCustom
                ? IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                    ),
                    onPressed: () =>
                        _confirmDelete(context, cat, provider, userId),
                  )
                : null,
          ),
        );
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    dynamic cat,
    TransactionProvider provider,
    String userId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa danh mục?'),
        content: Text('Bạn có chắc muốn xóa danh mục "${cat.name}"?'),
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
              provider.deleteCategory(cat.id, userId);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
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
