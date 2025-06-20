import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import '../pages/legal/privacy_policy_page.dart';
import '../pages/legal/terms_conditions_page.dart';
import '../providers/auth_provider.dart';
import '../config/theme.dart';
import 'auth_layout.dart';
import 'verify.dart';

class SignUpPage extends ConsumerStatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController username = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  Timer? _debounceTimer;
  final RxBool isLoading = false.obs;
  final RxBool isCheckingUsername = false.obs;
  final RxBool isUsernameAvailable = true.obs;
  final RxString usernameError = RxString('');
  bool hasAcceptedTerms = false;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    firstName.dispose();
    lastName.dispose();
    username.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  /// Validates username based on predefined rules:
  /// - At least 4 characters long
  /// - Must start with a letter
  /// - Can only contain alphanumeric characters
  String? validateUsername(String value) {
    if (value.isEmpty) return 'Username is required';
    if (value.length < 4) return 'Username must be at least 4 characters';
    if (!RegExp(r'^[a-zA-Z]').hasMatch(value)) return 'Username must start with a letter';
    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) return 'Username can only contain letters and numbers';
    return null;
  }

  /// Checks username availability in Firestore after a delay (debouncing).
  /// Prevents multiple network requests when user is typing.
  void debouncedUsernameCheck(String value) {
    if (_debounceTimer != null) _debounceTimer!.cancel();

    final validationError = validateUsername(value);
    if (validationError != null) {
      usernameError.value = validationError;
      isUsernameAvailable.value = false;
      return;
    }

    _debounceTimer = Timer(Duration(milliseconds: 500), () async {
      final firestoreService = ref.read(firestoreServiceProvider);

      isCheckingUsername.value = true;
      usernameError.value = '';

      try {
        final exists = await firestoreService.isUsernameExists(value);

        isCheckingUsername.value = false;
        isUsernameAvailable.value = !exists;
        usernameError.value = exists ? 'Username is already taken' : '';

        if (exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Username is already taken"),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        isCheckingUsername.value = false;
        isUsernameAvailable.value = false;
        usernameError.value = 'Error checking username availability';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error checking username availability"),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  /// Handles user signup process:
  /// - Validates input fields
  /// - Ensures username is unique
  /// - Registers user using Firebase Auth via Riverpod
  /// - Stores user details in Firestore
  /// - Sends email verification
  Future<void> signUp() async {
  if (!_formKey.currentState!.validate() || !isUsernameAvailable.value) return;

  final authRepo = ref.read(authRepositoryProvider);
  final firestoreService = ref.read(firestoreServiceProvider);

  isLoading.value = true;

  try {
    final userCredential = await authRepo.signUp(email.text.trim(), password.text);

    if (userCredential?.user != null) {
      final userId = userCredential!.user!.uid;

      //Immediately redirect to email verification page before sending email
      Get.off(() => VerifyEmailPage());

      //Store user profile in Firestore
      await firestoreService.createUserProfile(
        userId: userId,
        data: {
          'firstName': firstName.text.trim(),
          'lastName': lastName.text.trim(),
          'username': username.text.trim().toLowerCase(),
          'email': email.text.trim().toLowerCase(),
          'createdAt': DateTime.now(),
          'acceptedTerms': true, 
        },
      );

      //Initialize default areas for new users
      await firestoreService.initializeDefaultAreas();

      //Try sending verification email, but do not block navigation if it fails
      try {
        await authRepo.sendEmailVerification();
      } catch (e) {
        print("Failed to send verification email: $e");
      }
    }
  } catch (e) {
    //If the user already exists, redirect them to the verification page
    if (e.toString().contains('email-already-in-use')) {
      Get.off(() => VerifyEmailPage());
    } else {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  } finally {
    isLoading.value = false;
  }
} 


  void showTermsDialog(BuildContext context, Function onAccept) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Terms and Conditions'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'By signing up, you agree to our Terms and Conditions and Privacy Policy.',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Get.to(() => TermsConditionsPage()),
                  child: Text(
                    'Read Terms and Conditions',
                    style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                  ),
                ),
                SizedBox(height: 8),
                GestureDetector(
                  onTap: () => Get.to(() => PrivacyPolicyPage()),
                  child: Text(
                    'Read Privacy Policy',
                    style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                onAccept();
                Get.back();
              },
              child: Text('Accept'),
            ),
          ],
        );
      },
    );
  }



  Widget _buildSignupForm() {
    return Container(
      constraints: BoxConstraints(maxWidth: 400),
      padding: EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Create Account',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: GroceryColors.navy,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Sign up to start managing your groceries',
              style: TextStyle(
                fontSize: 16,
                color: GroceryColors.grey400,
              ),
            ),
            SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: firstName,
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: lastName,
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Obx(() => TextFormField(
              controller: username,
              decoration: InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.alternate_email),
                suffixIcon: isCheckingUsername.value
                    ? Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              GroceryColors.teal,
                            ),
                          ),
                        ),
                      )
                    : Icon(
                        isUsernameAvailable.value && usernameError.isEmpty
                            ? Icons.check_circle
                            : Icons.error,
                        color: isUsernameAvailable.value && usernameError.isEmpty
                            ? Colors.green
                            : Colors.red,
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                errorText: usernameError.value.isEmpty ? null : usernameError.value,
                helperText: 'Start with letter, use letters and numbers only',
              ),
              onChanged: debouncedUsernameCheck,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Username is required';
                }
                if (!isUsernameAvailable.value) {
                  return 'Username is not available';
                }
                return null;
              },
            )),
            SizedBox(height: 16),
            TextFormField(
              controller: email,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Email is required';
                }
                if (!GetUtils.isEmail(value)) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: password,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            SizedBox(height: 32),
              Obx(() => ElevatedButton(
                onPressed: isLoading.value
                    ? null
                    : () {
                        if (!hasAcceptedTerms) {
                          showTermsDialog(context, () {
                            setState(() {
                              hasAcceptedTerms = true;
                            });
                          });
                        } else {
                          signUp();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: GroceryColors.teal,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading.value
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              )),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: TextStyle(color: GroceryColors.grey400),
                ),
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('Sign In'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Sign Up',
      child: Center(
        child: SingleChildScrollView(
          child: _buildSignupForm(),
        ),
      ),
    );
  }
}