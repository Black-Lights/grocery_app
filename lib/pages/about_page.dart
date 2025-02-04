import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme.dart';
import '../../../services/text_recognition_service.dart';

class AboutPage extends StatelessWidget {
  Widget _buildFeatureCard({
    required String title,
    required String description,
    required IconData icon,
    required bool isTablet,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GroceryColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: GroceryColors.skyBlue.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: GroceryColors.navy.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: GroceryColors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: GroceryColors.teal,
              size: isTablet ? 28 : 24,
            ),
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: GroceryColors.navy,
            ),
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: isTablet ? 14 : 13,
              color: GroceryColors.grey400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final showAppBar = !isTablet || MediaQuery.of(context).size.width <= 1100;

    return Scaffold(
      backgroundColor: GroceryColors.background,
      appBar: showAppBar
          ? AppBar(
              title: Text(
                'About Us',
                style: TextStyle(
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 32 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo and Version
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isTablet ? 32 : 24),
              decoration: BoxDecoration(
                color: GroceryColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: GroceryColors.skyBlue.withOpacity(0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: GroceryColors.navy.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: isTablet ? 120 : 100,
                    height: isTablet ? 120 : 100,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: GroceryColors.teal.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/images/main_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Fresh Flow',
                    style: TextStyle(
                      fontSize: isTablet ? 28 : 24,
                      fontWeight: FontWeight.bold,
                      color: GroceryColors.navy,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: GroceryColors.skyBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: GroceryColors.skyBlue.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: GroceryColors.teal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Features Grid
            Text(
              'Key Features',
              style: TextStyle(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: GroceryColors.navy,
              ),
            ),
            SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: isTablet ? 2 : 1,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: isTablet ? 1.5 : 1.3,
              children: [
                _buildFeatureCard(
                  title: 'Storage Management',
                  description: 'Organize your groceries across multiple storage areas with easy tracking and management.',
                  icon: Icons.storage,
                  isTablet: isTablet,
                ),
                _buildFeatureCard(
                  title: 'Scan Feature',
                  description: 'Easily scan barcodes and product labels to fetch details automatically using AI-powered recognition.',
                  icon: Icons.qr_code_scanner,
                  isTablet: isTablet,
                ),
                _buildFeatureCard(
                  title: 'Expiry Tracking',
                  description: 'Never let food go to waste with our smart expiry date tracking and notifications.',
                  icon: Icons.timer,
                  isTablet: isTablet,
                ),
                _buildFeatureCard(
                  title: 'Shopping List',
                  description: 'Create and manage shopping lists with smart suggestions based on your inventory.',
                  icon: Icons.shopping_cart,
                  isTablet: isTablet,
                ),
                _buildFeatureCard(
                  title: 'Real-time Sync',
                  description: 'Access your grocery data across all your devices with real-time synchronization.',
                  icon: Icons.sync,
                  isTablet: isTablet,
                ),
              ],
            ),
            SizedBox(height: 24),

            // Developer Info
            Container(
              padding: EdgeInsets.all(isTablet ? 32 : 24),
              decoration: BoxDecoration(
                color: GroceryColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: GroceryColors.skyBlue.withOpacity(0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Developer',
                    style: TextStyle(
                      fontSize: isTablet ? 24 : 20,
                      fontWeight: FontWeight.bold,
                      color: GroceryColors.navy,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: GroceryColors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.code,
                          color: GroceryColors.teal,
                          size: isTablet ? 28 : 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '[Ammar, Moldir]',
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 16,
                                fontWeight: FontWeight.w600,
                                color: GroceryColors.navy,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Made with ❤️ using Flutter',
                              style: TextStyle(
                                fontSize: isTablet ? 14 : 13,
                                color: GroceryColors.grey400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
