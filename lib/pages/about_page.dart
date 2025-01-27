import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About Us',
          style: TextStyle(fontSize: isTablet ? 24 : 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isTablet ? 32 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Grocery Management App',
              style: TextStyle(
                fontSize: isTablet ? 28 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'About',
              style: TextStyle(
                fontSize: isTablet ? 22 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'The Grocery Management App helps you keep track of your groceries across different storage areas. Monitor expiry dates, manage inventory, and create shopping lists with ease.',
              style: TextStyle(fontSize: isTablet ? 16 : 14),
            ),
            SizedBox(height: 24),
            Text(
              'Features',
              style: TextStyle(
                fontSize: isTablet ? 22 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            _buildFeatureItem('Multiple storage areas management'),
            _buildFeatureItem('Product expiry tracking'),
            _buildFeatureItem('Shopping list with smart suggestions'),
            _buildFeatureItem('Real-time inventory updates'),
            _buildFeatureItem('Search functionality'),
            SizedBox(height: 24),
            Text(
              'Developer',
              style: TextStyle(
                fontSize: isTablet ? 22 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Created by [Your Name/Company]',
              style: TextStyle(fontSize: isTablet ? 16 : 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}
