import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appquanlytaichinh/core/constants/app_colors.dart';
import 'package:appquanlytaichinh/widgets/custom_textfield.dart';
import 'package:appquanlytaichinh/widgets/custom_button.dart';
import '../../auth/providers/auth_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  void _changePassword() async {
    final oldPass = _oldPasswordController.text;
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin')),
      );
      return;
    }

    if (newPass != confirmPass) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Mật khẩu mới không khớp')));
      return;
    }

    setState(() => _isLoading = true);

    final user = Provider.of<AuthProvider>(context, listen: false);
    final success = await user.changePassword(oldPass, newPass);

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đổi mật khẩu thành công')),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Mật khẩu cũ không đúng')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Đổi mật khẩu'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.blue.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Mật khẩu mới nên có ít nhất 6 ký tự để đảm bảo an toàn.',
                      style: TextStyle(fontSize: 14, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.shadowLight,
                    ),
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _oldPasswordController,
                          label: 'Mật khẩu hiện tại',
                          hint: 'Nhập mật khẩu cũ',
                          isPassword: true,
                          icon: Icons.lock_open,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _newPasswordController,
                          label: 'Mật khẩu mới',
                          hint: 'Nhập mật khẩu mới',
                          isPassword: true,
                          icon: Icons.lock_outline,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _confirmPasswordController,
                          label: 'Xác nhận mật khẩu',
                          hint: 'Nhập lại mật khẩu mới',
                          isPassword: true,
                          icon: Icons.check_circle_outline,
                        ),
                        const SizedBox(height: 30),
                        CustomButton(
                          text: 'Lưu thay đổi',
                          onPressed: _changePassword,
                          isLoading: _isLoading,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
