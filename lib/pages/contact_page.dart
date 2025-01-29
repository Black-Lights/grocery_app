import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/theme.dart';
import '../services/firestore_service.dart';
import '../models/contact_message.dart';

class ContactPage extends StatefulWidget {
  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final RxBool _isSending = false.obs;
  final _formKey = GlobalKey<FormState>();

  Widget _buildContactInfo({
    required String title,
    required String value,
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
      ),
      child: Row(
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
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: GroceryColors.navy,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
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
    );
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;

    _isSending.value = true;

    try {
      await _firestoreService.addContactMessage(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        message: _messageController.text.trim(),
      );

      _nameController.clear();
      _emailController.clear();
      _messageController.clear();

      Get.snackbar(
        'Success',
        'Message sent successfully',
        backgroundColor: GroceryColors.success,
        colorText: GroceryColors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send message',
        backgroundColor: GroceryColors.error,
        colorText: GroceryColors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      _isSending.value = false;
    }
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
                'Contact Us',
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
            // Contact Form
            Container(
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get in Touch',
                      style: TextStyle(
                        fontSize: isTablet ? 28 : 24,
                        fontWeight: FontWeight.bold,
                        color: GroceryColors.navy,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'We\'d love to hear from you. Send us a message and we\'ll respond as soon as possible.',
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: GroceryColors.grey400,
                      ),
                    ),
                    SizedBox(height: 32),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!GetUtils.isEmail(value.trim())) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _messageController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Message',
                        alignLabelWithHint: true,
                        prefixIcon: Padding(
                          padding: EdgeInsets.only(bottom: 80),
                          child: Icon(Icons.message_outlined),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your message';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: isTablet ? 56 : 48,
                      child: Obx(() => ElevatedButton(
                        onPressed: _isSending.value ? null : _sendMessage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GroceryColors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isSending.value
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    GroceryColors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Send Message',
                                style: TextStyle(
                                  fontSize: isTablet ? 16 : 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      )),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Contact Information
            Text(
              'Other Ways to Reach Us',
              style: TextStyle(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
                color: GroceryColors.navy,
              ),
            ),
            SizedBox(height: 16),
            _buildContactInfo(
              title: 'Email',
              value: 'support@yourdomain.com',
              icon: Icons.email_outlined,
              isTablet: isTablet,
            ),
            SizedBox(height: 12),
            _buildContactInfo(
              title: 'Phone',
              value: '+1 234 567 890',
              icon: Icons.phone_outlined,
              isTablet: isTablet,
            ),
            SizedBox(height: 12),
            _buildContactInfo(
              title: 'Address',
              value: '123 Main Street, City, State 12345',
              icon: Icons.location_on_outlined,
              isTablet: isTablet,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
