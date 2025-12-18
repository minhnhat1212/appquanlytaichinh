import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appquanlytaichinh/core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get latest auth info
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Profile
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 30),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      image: const DecorationImage(
                        image: AssetImage(
                          'assets/images/avatar_placeholder.png',
                        ),
                        fit: BoxFit.cover,
                      ),
                      color: Colors.white24,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                auth.username.isNotEmpty ? auth.username : 'Người dùng',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                auth.email.isNotEmpty ? auth.email : '---',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Info Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppColors.shadowLight,
                ),
                child: Column(
                  children: [
                    _buildProfileTile(
                      icon: Icons.phone_android,
                      title: 'Số điện thoại',
                      subtitle:
                          auth.phone.isNotEmpty ? auth.phone : 'Chưa cập nhật',
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    _buildProfileTile(
                      icon: Icons.lock_outline,
                      title: 'Đổi mật khẩu',
                      subtitle: 'Cập nhật mật khẩu mới',
                      onTap: () {
                        Navigator.pushNamed(context, '/change-password');
                      },
                      isLink: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Settings Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppColors.shadowLight,
                ),
                child: Column(
                  children: [
                    _buildProfileTile(
                      icon: Icons.settings,
                      title: 'Cài đặt chung',
                      subtitle: 'Ngôn ngữ, thông báo...',
                      onTap: () {}, // Future feature
                      isLink: true,
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    _buildProfileTile(
                      icon: Icons.help_outline,
                      title: 'Trợ giúp & Hỗ trợ',
                      onTap: () {}, // Future feature
                      isLink: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Confirm logout
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Đăng xuất'),
                        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Hủy'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              Provider.of<AuthProvider>(
                                context,
                                listen: false,
                              ).logout();
                              // Navigate back to login
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login',
                                (route) => false,
                              );
                            },
                            child: const Text(
                              'Đăng xuất',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.error,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text('Đăng xuất'),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool isLink = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: subtitle != null
          ? Text(subtitle, style: TextStyle(color: Colors.grey[600]))
          : null,
      trailing: isLink
          ? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)
          : null,
      onTap: onTap,
    );
  }
}
