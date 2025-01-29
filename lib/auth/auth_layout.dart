import 'package:flutter/material.dart';
import '../config/theme.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final bool showBackButton;

  const AuthLayout({
    Key? key,
    required this.child,
    required this.title,
    this.showBackButton = true,
  }) : super(key: key);

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
                child: child,
              ),
            ),
          ],
        ),
      );
    }

    // Mobile Layout
    return Scaffold(
      backgroundColor: GroceryColors.white,
      appBar: showBackButton ? AppBar(
        backgroundColor: GroceryColors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: GroceryColors.navy,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: GroceryColors.navy,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ) : null,
      body: child,
    );
  }
}
