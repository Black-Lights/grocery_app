import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Policy'),
        backgroundColor: GroceryColors.navy,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy Policy',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: GroceryColors.navy,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Last Updated: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: GroceryColors.grey400,
                ),
              ),
              SizedBox(height: 20),

              // Section 1: Data Collection
              _buildSectionTitle('1. Data Collection'),
              _buildSectionContent(
                  'We collect only the minimum personal data necessary for account creation, authentication, '
                  'and security purposes. This may include:\n\n'
                  '- Your name and email address\n'
                  '- Username and password\n'
                  '- Profile preferences and settings\n'
                  '- Any other data you voluntarily provide'),
              SizedBox(height: 16),

              // Section 2: Data Usage
              _buildSectionTitle('2. Data Usage'),
              _buildSectionContent(
                  'Your personal data is used solely for providing app functionalities, including but not limited to:\n\n'
                  '- Managing your user profile\n'
                  '- Storing your grocery-related data\n'
                  '- Enhancing user experience with personalized recommendations\n'
                  '- Ensuring account security and authentication\n\n'
                  '🚨 We do not sell or share your personal data with third-party advertisers or marketers.'),
              SizedBox(height: 16),

              // Section 3: User Rights
              _buildSectionTitle('3. User Rights (GDPR & Italian Law)'),
              _buildSectionContent(
                  'As per the **General Data Protection Regulation (GDPR)** and **Italian data protection laws**, you have the right to:\n\n'
                  '  Request access to your data\n'
                  '  Modify or update incorrect personal information\n'
                  '  Request deletion of your account and associated data\n'
                  '  Restrict or object to certain types of data processing\n'
                  '  Receive a copy of your data in a structured, readable format (data portability)\n'
                  '  Withdraw consent at any time\n\n'
                  'To exercise your rights, please contact our support team.'),
              SizedBox(height: 16),

              // Section 4: Third-Party Services
              _buildSectionTitle('4. Third-Party Services'),
              _buildSectionContent(
                  'Some features rely on third-party services such as Firebase. These services have their own privacy policies, '
                  'and we recommend reviewing them to understand how your data is handled:\n\n'
                  '- [Google Firebase Privacy Policy](https://firebase.google.com/support/privacy)\n'
                  '- [Google Analytics Terms](https://policies.google.com/technologies/partner-sites)\n'
                  '- [Apple Privacy Policy](https://www.apple.com/legal/privacy/en-ww/)'),
              SizedBox(height: 16),

              // Section 5: Data Security
              _buildSectionTitle('5. Data Security'),
              _buildSectionContent(
                  'We implement industry-standard security measures to protect your data from unauthorized access, loss, or misuse. '
                  'Some of the key security features include:\n\n'
                  '- **End-to-end encryption** for sensitive information\n'
                  '- **Regular security audits** to detect vulnerabilities\n'
                  '- **Multi-factor authentication (MFA)** for account protection\n'
                  '- **Strict access control policies** for database management\n\n'
                  '⚠️ However, while we strive to protect your data, no method of transmission over the internet is 100% secure. '
                  'We advise you to use strong passwords and enable additional security settings when available.'),
              SizedBox(height: 16),

              // Section 6: Policy Changes
              _buildSectionTitle('6. Policy Changes'),
              _buildSectionContent(
                  'We may update this Privacy Policy periodically to reflect new legal requirements or app functionalities. '
                  'You will be notified of major changes through in-app notifications or via email.\n\n'
                  '📅 The last update to this policy was on: **${DateTime.now().toLocal().toString().split(' ')[0]}**\n\n'
                  'We encourage you to review this page regularly to stay informed about how we protect your privacy.'),
              SizedBox(height: 16),

              // Section 7: Contact Information
              _buildSectionTitle('7. Contact Us'),
              _buildSectionContent(
                  'If you have any questions or concerns regarding your privacy, please contact us:\n\n'
                  '📧 **Email**: mohammadammarmughees@gmail.com\n'
                  '🌍 **Website**: Under Planning\n'
                  '🏢 **Address**: Polimi, Milan, Italy'),
              SizedBox(height: 16),

              // Back Button
              Center(
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GroceryColors.teal,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Back'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to create section titles
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: GroceryColors.navy,
      ),
    );
  }

  // Helper function to create section content
  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: TextStyle(fontSize: 16, color: Colors.black87),
    );
  }
}
