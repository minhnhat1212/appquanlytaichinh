import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/user/screens/profile_screen.dart';
import 'features/user/screens/change_password_screen.dart';
import 'features/transaction/providers/transaction_provider.dart';
import 'features/transaction/screens/transaction_list_screen.dart';
import 'features/transaction/screens/add_transaction_screen.dart';
import 'features/transaction/screens/category_list_screen.dart';
import 'features/transaction/screens/add_category_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
      ],
      child: MaterialApp(
        title: 'Quản Lý Tài Chính',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: AppColors.secondary,
            primary: AppColors.primary,
            surface: AppColors.surface,
            error: AppColors.error,
          ),
          fontFamily: 'Inter',
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/forgot-password': (context) => ForgotPasswordScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/change-password': (context) => const ChangePasswordScreen(),

          // Transaction Routes
          '/transactions': (context) => const TransactionListScreen(),
          '/add-transaction': (context) => const AddTransactionScreen(),
          '/categories': (context) => const CategoryListScreen(),
          '/add-category': (context) => const AddCategoryScreen(),
        },
      ),
    );
  }
}
