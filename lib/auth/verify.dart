import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';
import 'auth_layout.dart';
import 'welcome_page.dart';
import 'wrapper.dart';
import '../widgets/navigation/app_scaffold.dart';

class VerifyEmailPage extends ConsumerStatefulWidget {
  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  User? user;
  late Timer _timer;
  final RxBool isLoading = false.obs;
  final RxBool isResending = false.obs;
  final RxInt timeLeft = 60.obs;
  final RxBool canResend = true.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authRepo = ref.read(authRepositoryProvider);
      user = authRepo.getCurrentUser();

      // ✅ Only send verification email if it wasn't already sent in signUp()
      if (!(user?.emailVerified ?? false)) {
        sendVerificationEmail();
      }

      startVerificationCheck();
    });
  }

  void startVerificationCheck() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) async {
      await checkEmailVerified();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> sendVerificationEmail() async {
    if (!canResend.value || isResending.value) return;

    try {
      isResending.value = true;
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.sendEmailVerification();
      
      // Start cooldown timer
      canResend.value = false;
      timeLeft.value = 60;
      
      Timer.periodic(Duration(seconds: 1), (timer) {
        if (timeLeft.value <= 0) {
          timer.cancel();
          canResend.value = true;
        } else {
          timeLeft.value--;
        }
      });

      Get.snackbar(
        'Email Sent',
        'Verification email has been sent to ${user?.email}',
        backgroundColor: GroceryColors.success,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      // Get.snackbar(
      //   'Error',
      //   'Failed to send verification email',
      //   backgroundColor: Colors.red,
      //   colorText: Colors.white,
      //   snackPosition: SnackPosition.BOTTOM,
      // );
    } finally {
      isResending.value = false;
    }
  }

  Future<void> checkEmailVerified() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.reloadUser();
      user = authRepo.getCurrentUser();
      
      if (user?.emailVerified ?? false) {
        _timer.cancel();
        Get.offAll(() => AppScaffold()); // Change HomePage to AppScaffold
      } 
      // else {
      //   Get.snackbar(
      //     'Not Verified',
      //     'Please verify your email first',
      //     backgroundColor: Colors.orange,
      //     colorText: Colors.white,
      //   );
      // }
    } catch (e) {
      print('Error checking email verification: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signOut();
      Get.offAll(() => WelcomePage());
    } catch (e) {
      print('Error signing out: $e');
      Get.snackbar(
        'Error',
        'Failed to sign out',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }


  Widget _buildVerificationContent() {
    return Container(
      constraints: BoxConstraints(maxWidth: 400),
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.mark_email_unread_outlined,
            size: 64,
            color: GroceryColors.teal,
          ),
          SizedBox(height: 32),
          Text(
            'Verify Your Email',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: GroceryColors.navy,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          Text(
            'We\'ve sent a verification email to:',
            style: TextStyle(
              fontSize: 16,
              color: GroceryColors.grey400,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            user?.email ?? '',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: GroceryColors.navy,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 32),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: GroceryColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: GroceryColors.skyBlue.withOpacity(0.5),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: GroceryColors.teal,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Please check your email and click the verification link',
                        style: TextStyle(
                          fontSize: 14,
                          color: GroceryColors.navy,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Obx(() => LinearProgressIndicator(
                  value: isLoading.value ? null : 1,
                  backgroundColor: GroceryColors.skyBlue.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    GroceryColors.teal,
                  ),
                )),
              ],
            ),
          ),
          SizedBox(height: 32),
          Obx(() => ElevatedButton(
            onPressed: canResend.value ? sendVerificationEmail : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: GroceryColors.teal,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isResending.value
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    canResend.value
                        ? 'Resend Verification Email'
                        : 'Resend in ${timeLeft.value}s',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          )),
          SizedBox(height: 16),
          OutlinedButton(
            onPressed: checkEmailVerified,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: GroceryColors.teal),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'I\'ve Verified My Email',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: GroceryColors.teal,
              ),
            ),
          ),
          SizedBox(height: 24),
          TextButton(
            onPressed: signOut,
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Verify Email',
      showBackButton: false,
      child: Center(
        child: SingleChildScrollView(
          child: _buildVerificationContent(),
        ),
      ),
    );
  }
}
