import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/theme.dart';
import 'login.dart';
import 'signup.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  bool _isLargeScreen(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    return size.width > 900 || (size.width > 600 && isLandscape);
  }

  Widget _buildLogo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/main_logo.png',
          width: 200,
          height: 200,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 24),
        Text(
          'Grocery Manager',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: GroceryColors.navy,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Manage your household groceries efficiently',
          style: TextStyle(
            fontSize: 16,
            color: GroceryColors.grey400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAuthButtons(BuildContext context, {bool isCompact = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: isCompact ? double.infinity : 300,
          height: 50,
          child: ElevatedButton(
            onPressed: () => Get.to(() => LoginPage()),
            style: ElevatedButton.styleFrom(
              backgroundColor: GroceryColors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Sign In',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        SizedBox(
          width: isCompact ? double.infinity : 300,
          height: 50,
          child: OutlinedButton(
            onPressed: () => Get.to(() => SignUpPage()),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: GroceryColors.teal),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Create Account',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: GroceryColors.teal,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = _isLargeScreen(context);

    if (isLargeScreen) {
      return Scaffold(
        body: Row(
          children: [
            // Left Panel (Static)
            Expanded(
              flex: 5,
              child: Container(
                color: GroceryColors.background,
                padding: EdgeInsets.all(32),
                child: Center(
                  child: _buildLogo(),
                ),
              ),
            ),
            // Right Panel (Dynamic)
            Expanded(
              flex: 7,
              child: Container(
                color: GroceryColors.white,
                padding: EdgeInsets.all(32),
                child: Center(
                  child: _buildAuthButtons(context),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Mobile/Portrait Layout
    return Scaffold(
      backgroundColor: GroceryColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Center(
                  child: _buildLogo(),
                ),
              ),
              _buildAuthButtons(context, isCompact: true),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
