import 'package:flutter/material.dart';
import 'package:appquanlytaichinh/core/constants/app_colors.dart';
import 'package:appquanlytaichinh/widgets/custom_textfield.dart';
import 'package:appquanlytaichinh/widgets/custom_button.dart';

class ForgotPasswordScreen extends StatelessWidget {
  ForgotPasswordScreen({Key? key}) : super(key: key);

  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Quên mật khẩu'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Đừng lo lắng!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Nhập email đã đăng ký của bạn để nhận hướng dẫn khôi phục mật khẩu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 48),

                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppColors.shadowMedium,
                  ),
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'user@example.com',
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Gửi yêu cầu',
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tính năng đang phát triển'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
