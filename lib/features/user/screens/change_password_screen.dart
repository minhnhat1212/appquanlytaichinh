import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/custom_textfield.dart';
import '../../auth/providers/auth_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _changePassword() async {
    if (_formKey.currentState!.validate()) {
      if (_newPassController.text != _confirmPassController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mật khẩu mới không khớp')),
        );
        return;
      }

      setState(() => _isLoading = true);
      final success = await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).changePassword(_oldPassController.text, _newPassController.text);

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đổi mật khẩu thành công')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đổi mật khẩu thất bại')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Đổi mật khẩu'),
        backgroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.black),
        titleTextStyle: const TextStyle(
          color: AppColors.black,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _oldPassController,
                labelText: 'Mật khẩu hiện tại',
                obscureText: true,
                validator: (v) => v!.isEmpty ? 'Nhập mật khẩu cũ' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _newPassController,
                labelText: 'Mật khẩu mới',
                obscureText: true,
                validator: (v) =>
                    v!.length < 6 ? 'Mật khẩu mới > 6 ký tự' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _confirmPassController,
                labelText: 'Xác nhận mật khẩu mới',
                obscureText: true,
                validator: (v) => v!.isEmpty ? 'Xác nhận mật khẩu' : null,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : CustomButton(
                      text: 'Lưu thay đổi',
                      onPressed: _changePassword,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
