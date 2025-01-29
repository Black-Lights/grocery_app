import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../config/theme.dart';
import '../services/firestore_service.dart';
import 'auth_layout.dart';
import 'verify.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController username = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final RxBool isLoading = false.obs;
  final RxBool isCheckingUsername = false.obs;
  final RxBool isUsernameAvailable = true.obs;
  final RxString usernameError = RxString('');
  Timer? _debounceTimer;

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
void debouncedUsernameCheck(String value) {
    if (value.isEmpty) {
      usernameError.value = 'Username is required';
      isUsernameAvailable.value = false;
      return;
    }

    // Cancel previous timer if it exists
    _debounceTimer?.cancel();

    // Basic validation first
    final validationError = validateUsername(value);
    if (validationError != null) {
      usernameError.value = validationError;
      isUsernameAvailable.value = false;
      return;
    }

    // Set timer for API call
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      checkUsername(value);
    });
  }

  String? validateUsername(String username) {
    if (username.isEmpty) {
      return 'Username is required';
    }

    if (username.length < 4) {
      return 'Username must be at least 4 characters';
    }

    if (!RegExp(r'^[a-zA-Z]').hasMatch(username)) {
      return 'Username must start with a letter';
    }

    if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(username)) {
      return 'Username can only contain letters and numbers';
    }

    return null;
  }

  Future<void> checkUsername(String value) async {
    isCheckingUsername.value = true;
    usernameError.value = '';

    try {
      final snapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: value.toLowerCase())
          .get();

      isUsernameAvailable.value = snapshot.docs.isEmpty;
      if (!snapshot.docs.isEmpty) {
        usernameError.value = 'Username is already taken';
      }
    } catch (e) {
      usernameError.value = 'Error checking username availability';
      isUsernameAvailable.value = false;
    } finally {
      isCheckingUsername.value = false;
    }
  }

  Future<void> signUp() async {
    if (isLoading.value) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      // Create user in Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text,
      );

      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'firstName': firstName.text.trim(),
        'lastName': lastName.text.trim(),
        'username': username.text.trim().toLowerCase(),
        'email': email.text.trim().toLowerCase(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Initialize default areas
      final firestoreService = FirestoreService();
      await firestoreService.initializeDefaultAreas();

      // Navigate to email verification
      Get.offAll(() => VerifyEmailPage());
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak';
          break;
        case 'email-already-in-use':
          message = 'An account already exists with this email';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
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
              onPressed: isLoading.value ? null : signUp,
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
