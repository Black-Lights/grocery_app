import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'wrapper.dart';

class VerifyEmailPage extends StatefulWidget {
  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? user;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    sendVerificationEmail();
  }

  Future<void> sendVerificationEmail() async {
    try {
      await user?.sendEmailVerification();
      Get.snackbar(
        'Email Sent',
        'Verification email has been sent to ${user?.email}',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  Future<void> checkEmailVerified() async {
    try {
      await user?.reload();
      user = _auth.currentUser;
      
      if (user?.emailVerified ?? false) {
        Get.offAll(() => Wrapper());
      } else {
        Get.snackbar(
          'Not Verified',
          'Please verify your email first',
          backgroundColor: Colors.orange,
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Email'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 32.0 : 16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mark_email_unread,
                  size: isTablet ? 150 : 100,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(height: isTablet ? 40 : 20),
                Text(
                  'Verification email has been sent to:',
                  style: TextStyle(fontSize: isTablet ? 20 : 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isTablet ? 20 : 10),
                Text(
                  '${user?.email}',
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isTablet ? 40 : 20),
                SizedBox(
                  height: isTablet ? 60 : 50,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: checkEmailVerified,
                    icon: Icon(Icons.refresh, size: isTablet ? 24 : 20),
                    label: Text(
                      'Reload',
                      style: TextStyle(fontSize: isTablet ? 18 : 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isTablet ? 24 : 16),
                TextButton(
                  onPressed: sendVerificationEmail,
                  child: Text(
                    'Resend Verification Email',
                    style: TextStyle(fontSize: isTablet ? 16 : 14),
                  ),
                ),
                SizedBox(height: isTablet ? 24 : 16),
                TextButton(
                  onPressed: () async {
                    await _auth.signOut();
                    Get.offAll(() => Wrapper());
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
