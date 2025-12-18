import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/category_model.dart';

class CategoryListScreen extends StatefulWidget {
  const CategoryListScreen({Key? key}) : super(key: key);

  @override
  State<CategoryListScreen> createState() => _CategoryListScreenState();
}

class _CategoryListScreenState extends State<CategoryListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final user = Provider.of<AuthProvider>(context, listen: false);

    // Filter lists
    final expenseCats = provider.categories
        .where((c) => c.type == 'expense')
        .toList();
    final incomeCats = provider.categories
        .where((c) => c.type == 'income')
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Quản Lý Danh Mục'),
        backgroundColor: AppColors.primary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'KHOẢN CHI'),
            Tab(text: 'KHOẢN THU'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(expenseCats, user.userId, provider),
          _buildList(incomeCats, user.userId, provider),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        backgroundColor: AppColors.secondary,
        onPressed: () {
          // Navigate to Add Screen
          Navigator.pushNamed(context, '/add-category');
        },
      ),
    );
  }

  Widget _buildList(
    List<CategoryModel> list,
    String userId,
    TransactionProvider provider,
  ) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(int.parse(item.color)),
              child: Icon(_getIconData(item.icon), color: Colors.white),
            ),
            title: Text(item.name),
            trailing: item.isDefault
                ? const Icon(Icons.lock, color: Colors.grey, size: 20)
                : IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      // Delete confirm
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Xóa danh mục?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () {
                                provider.deleteCategory(item.id, userId);
                                Navigator.pop(ctx);
                              },
                              child: const Text('Xóa'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  // Simple Helper to map string to IconData (Mock implementation)
  IconData _getIconData(String name) {
    switch (name) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'home':
        return Icons.home;
      case 'movie':
        return Icons.movie;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'attach_money':
        return Icons.attach_money;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'more_horiz':
        return Icons.more_horiz;
      case 'check_circle':
        return Icons.check_circle; // Default custom
      default:
        return Icons.help_outline;
    }
  }
}
