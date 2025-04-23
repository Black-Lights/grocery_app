import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms and Conditions'),
        backgroundColor: GroceryColors.navy,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Terms and Conditions',
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

              // Section 1: Acceptance of Terms
              _buildSectionTitle('1. Acceptance of Terms'),
              _buildSectionContent(
                  'By accessing or using this application ("Fresh Flow"), you agree to be bound by these Terms and Conditions. '
                  'If you do not agree with any part of these terms, you must discontinue the use of this app immediately.'),
              SizedBox(height: 16),

              // Section 2: User Responsibilities
              _buildSectionTitle('2. User Responsibilities'),
              _buildSectionContent(
                  'You agree to:\n\n'
                  '  Provide accurate and up-to-date information.\n'
                  '  Use the app only for its intended purpose.\n'
                  '  Respect the rights of other users.\n'
                  '  Comply with applicable laws and regulations.\n\n'
                  '🚫 You may not:\n'
                  '❌ Use the app for fraudulent or illegal activities.\n'
                  '❌ Attempt to access unauthorized parts of the system.\n'
                  '❌ Share your account details with others.\n'
                  '❌ Upload harmful or offensive content.'),
              SizedBox(height: 16),

              // Section 3: GDPR Compliance
              _buildSectionTitle('3. GDPR Compliance & User Rights'),
              _buildSectionContent(
                  'As per the **General Data Protection Regulation (GDPR)** and **Italian privacy laws**, you have the right to:\n\n'
                  '🔹 Access your personal data\n'
                  '🔹 Correct or update incorrect information\n'
                  '🔹 Request deletion of your account and associated data\n'
                  '🔹 Object to certain types of data processing\n'
                  '🔹 Receive a copy of your data in a structured format (data portability)\n'
                  '🔹 Withdraw consent at any time\n\n'
                  '📌 To exercise these rights, please contact our support team at: support@yourapp.com'),
              SizedBox(height: 16),

              // Section 4: Account Suspension & Termination
              _buildSectionTitle('4. Account Suspension & Termination'),
              _buildSectionContent(
                  'We reserve the right to suspend or terminate your account under the following conditions:\n\n'
                  '- Violation of these Terms and Conditions.\n'
                  '- Engaging in fraudulent or malicious activities.\n'
                  '- Breach of privacy laws or regulations.\n'
                  '- Unauthorized attempts to access or modify the app.\n\n'
                  '📌 Users who wish to appeal a suspension can contact support within **7 days** of receiving a suspension notice.'),
              SizedBox(height: 16),

              // Section 5: Limitation of Liability
              _buildSectionTitle('5. Limitation of Liability'),
              _buildSectionContent(
                  'Fresh Flow is provided **"as is"** without any warranties. We do not guarantee that the app will always be available, '
                  'error-free, or free from security breaches. In no event shall we be liable for:\n\n'
                  '- Data loss due to technical failures.\n'
                  '- Unauthorized access caused by user negligence.\n'
                  '- Any indirect, incidental, or consequential damages arising from the use of this app.'),
              SizedBox(height: 16),

              // Section 6: Changes to Terms
              _buildSectionTitle('6. Changes to Terms'),
              _buildSectionContent(
                  'We may modify these Terms and Conditions at any time. Users will be notified of major changes through in-app notifications or email.\n\n'
                  '📅 The last update to these terms was on: **${DateTime.now().toLocal().toString().split(' ')[0]}**.\n\n'
                  'Continued use of the app after changes constitutes acceptance of the new terms.'),
              SizedBox(height: 16),

              // Section 7: Governing Law
              _buildSectionTitle('7. Governing Law & Jurisdiction'),
              _buildSectionContent(
                  'These Terms and Conditions are governed by the laws of **Italy and the European Union**. Any disputes arising from '
                  'the use of the app shall be settled in the competent courts of **Rome, Italy**.\n\n'
                  'If any provision of these Terms is found to be unenforceable, the remaining provisions shall remain in effect.'),
              SizedBox(height: 16),

              // Section 8: Contact Information
              _buildSectionTitle('8. Contact Us'),
              _buildSectionContent(
                  'For any questions or concerns regarding these Terms, you can reach out to us:\n\n'
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
