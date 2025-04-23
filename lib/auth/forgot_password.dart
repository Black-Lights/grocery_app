import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../config/theme.dart';
import 'auth_layout.dart';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController email = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RxBool isLoading = false.obs;
  final RxBool isEmailSent = false.obs;

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  Future<void> resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;
      await _auth.sendPasswordResetEmail(email: email.text.trim());
      isEmailSent.value = true;
      
      // Show success message
      Get.snackbar(
        'Success',
        'Password reset link has been sent to your email',
        backgroundColor: GroceryColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 5),
      );

    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'user-not-found':
          message = 'No user found with this email';
          break;
        default:
          message = e.message ?? 'An error occurred';
      }
      Get.snackbar(
        'Error',
        message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Widget _buildResetForm() {
    return Container(
      constraints: BoxConstraints(maxWidth: 400),
      padding: EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.lock_reset_outlined,
              size: 64,
              color: GroceryColors.teal,
            ),
            SizedBox(height: 32),
            Text(
              'Reset Password',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: GroceryColors.navy,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'Enter your email address and we\'ll send you instructions to reset your password.',
              style: TextStyle(
                fontSize: 16,
                color: GroceryColors.grey400,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            TextFormField(
              controller: email,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email address',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              enabled: !isLoading.value && !isEmailSent.value,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email is required';
                }
                if (!GetUtils.isEmail(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            SizedBox(height: 24),
            Obx(() => ElevatedButton(
              onPressed: (isLoading.value || isEmailSent.value) 
                  ? null 
                  : resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: GroceryColors.teal,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: GroceryColors.grey200,
              ),
              child: isLoading.value
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                  : Text(
                      isEmailSent.value 
                          ? 'Email Sent' 
                          : 'Send Reset Link',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            )),
            SizedBox(height: 16),
            Obx(() => isEmailSent.value
                ? Column(
                    children: [
                      Text(
                        'Check your email',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: GroceryColors.success,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'We\'ve sent instructions to:',
                        style: TextStyle(
                          fontSize: 14,
                          color: GroceryColors.grey400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4),
                      Text(
                        email.text,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: GroceryColors.navy,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : SizedBox.shrink()),
            SizedBox(height: 24),
            TextButton(
              onPressed: () => Get.back(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Back to Login',
                style: TextStyle(
                  fontSize: 16,
                  color: GroceryColors.teal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Reset Password',
      child: Center(
        child: SingleChildScrollView(
          child: _buildResetForm(),
        ),
      ),
    );
  }
}
