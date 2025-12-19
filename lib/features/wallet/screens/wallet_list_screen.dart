import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../providers/wallet_provider.dart';

class WalletListScreen extends StatefulWidget {
  const WalletListScreen({super.key});

  @override
  State<WalletListScreen> createState() => _WalletListScreenState();
}

class _WalletListScreenState extends State<WalletListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WalletProvider>(context, listen: false).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Ví & Tài khoản'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            onPressed: () => Navigator.pushNamed(context, '/wallet-transfer'),
          ),
        ],
      ),
      body: Consumer<WalletProvider>(
        builder: (context, provider, _) {
          final formatter =
              NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 100, 20, 30),
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tổng số dư',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatter.format(provider.totalBalance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (provider.defaultWallet != null)
                      _defaultWalletCard(
                        provider.defaultWallet!.name,
                        provider.defaultWallet!.type,
                        formatter.format(provider.defaultWallet!.balance),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.wallets.isEmpty
                        ? _emptyState(context)
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: provider.wallets.length,
                            itemBuilder: (context, index) {
                              final wallet = provider.wallets[index];
                              Color color;
                              try {
                                color = Color(
                                  int.parse(wallet.color.replaceFirst('#', '0xFF')),
                                );
                              } catch (_) {
                                color = AppColors.primary;
                              }
                              final isDefault = wallet.isDefault;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: AppColors.shadowLight,
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: color.withOpacity(0.15),
                                    child: Icon(
                                      _typeIcon(wallet.type),
                                      color: color,
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          wallet.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      if (isDefault)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Text(
                                            'Mặc định',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        formatter.format(wallet.balance),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          _typeChip(wallet.type),
                                          if (wallet.institution?.isNotEmpty == true)
                                            Padding(
                                              padding: const EdgeInsets.only(left: 8.0),
                                              child: Text(
                                                wallet.institution!,
                                                style: const TextStyle(
                                                  color: AppColors.textSecondary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      if (wallet.accountNumber?.isNotEmpty == true)
                                        Text(
                                          wallet.accountNumber!,
                                          style: const TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'default') {
                                        Provider.of<WalletProvider>(
                                          context,
                                          listen: false,
                                        ).setDefault(wallet.id);
                                      } else if (value == 'transfer') {
                                        Navigator.pushNamed(
                                          context,
                                          '/wallet-transfer',
                                          arguments: wallet.id,
                                        );
                                      } else if (value == 'delete') {
                                        Provider.of<WalletProvider>(
                                          context,
                                          listen: false,
                                        ).deleteWallet(wallet.id);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      if (!isDefault)
                                        const PopupMenuItem(
                                          value: 'default',
                                          child: Text('Đặt làm mặc định'),
                                        ),
                                      const PopupMenuItem(
                                        value: 'transfer',
                                        child: Text('Chuyển tiền'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Xóa ví'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.pushNamed(context, '/add-wallet'),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _defaultWalletCard(String name, String type, String balance) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _typeLabel(type),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            balance,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.account_balance_wallet_outlined, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          const Text('Chưa có ví nào'),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/add-wallet'),
            icon: const Icon(Icons.add),
            label: const Text('Thêm ví mới'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeChip(String type) {
    final label = _typeLabel(type);
    final color = _typeColor(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'cash':
        return AppColors.success;
      case 'bank':
        return AppColors.primary;
      case 'eWallet':
        return AppColors.secondary;
      default:
        return AppColors.textSecondary;
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'cash':
        return 'Tiền mặt';
      case 'bank':
        return 'Tài khoản ngân hàng';
      case 'eWallet':
        return 'Ví điện tử';
      default:
        return 'Khác';
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'cash':
        return Icons.payments_outlined;
      case 'bank':
        return Icons.account_balance;
      case 'eWallet':
        return Icons.phone_iphone;
      default:
        return Icons.account_balance_wallet_outlined;
    }
  }
}

