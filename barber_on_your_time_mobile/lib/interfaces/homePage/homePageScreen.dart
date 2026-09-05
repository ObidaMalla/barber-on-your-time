import 'package:flutter/material.dart';

import '../../core/color/colors.dart';
import '../../token/token_customer.dart';
import '../login/loginScreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _tempLogout(BuildContext context) async {
    await TokenStorage.removeToken();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.barberRed,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: AppColors.textSecondary),
            onPressed: () => _tempLogout(context),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: Container(
        color: AppColors.backgroundColor,
        child: Center(
          child: Text(
            'Home',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
