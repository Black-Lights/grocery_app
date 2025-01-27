import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:grocery/services/firestore_service.dart';
import 'dart:async';
import 'verify.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Controllers for text fields
  final TextEditingController firstName = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController username = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // State variables
  bool isLoading = false;
  bool isCheckingUsername = false;
  bool isUsernameAvailable = true;
  String? usernameError;
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  // Username validation function
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
      return 'Username must be alphanumeric only';
    }

    return null;
  }

  // Check username availability in Firestore
  Future<void> checkUsername(String value) async {
    // Basic validation first
    final validationError = validateUsername(value);
    
    if (validationError != null) {
      setState(() {
        usernameError = validationError;
        isUsernameAvailable = false;
      });
      return;
    }

    setState(() {
      isCheckingUsername = true;
      usernameError = null;
    });

    try {
      final snapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: value.toLowerCase())
          .get();

      if (mounted) {
        setState(() {
          isUsernameAvailable = snapshot.docs.isEmpty;
          usernameError = snapshot.docs.isEmpty ? null : 'Username is already taken';
          isCheckingUsername = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isUsernameAvailable = true;
          usernameError = null;
          isCheckingUsername = false;
        });
      }
    }
  }

  // Debounce username check
  void debouncedUsernameCheck(String value) {
    _debounceTimer?.cancel();
    
    if (value.length < 4) {
      setState(() {
        usernameError = value.isEmpty 
            ? 'Username is required' 
            : 'Username must be at least 4 characters';
        isUsernameAvailable = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      checkUsername(value);
    });
  }

  // Sign up function
  Future<void> signUp() async {
    if (isLoading) return;

    // Validate all fields
    if (firstName.text.trim().isEmpty ||
        lastName.text.trim().isEmpty ||
        username.text.trim().isEmpty ||
        email.text.trim().isEmpty ||
        password.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Validate username
    final usernameValidation = validateUsername(username.text.trim());
    if (usernameValidation != null) {
      Get.snackbar(
        'Error',
        usernameValidation,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
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

      Get.offAll(() => VerifyEmailPage());
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'The password provided is too weak';
          break;
        case 'email-already-in-use':
          message = 'An account already exists for this email';
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
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final padding = isTablet ? 32.0 : 16.0;

    return Scaffold(
        appBar: AppBar(
          title: Text("Sign Up"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 600),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.person_add,
                    size: isTablet ? 120 : 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(height: isTablet ? 40 : 20),
                  // First Name
                  TextField(
                    controller: firstName,
                    decoration: InputDecoration(
                      hintText: 'First Name',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabled: !isLoading,
                    ),
                    textCapitalization: TextCapitalization.words,
                    style: TextStyle(fontSize: isTablet ? 18 : 16),
                  ),
                  SizedBox(height: isTablet ? 24 : 16),
                  // Last Name
                  TextField(
                    controller: lastName,
                    decoration: InputDecoration(
                      hintText: 'Last Name',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabled: !isLoading,
                    ),
                    textCapitalization: TextCapitalization.words,
                    style: TextStyle(fontSize: isTablet ? 18 : 16),
                  ),
                  SizedBox(height: isTablet ? 24 : 16),
                  // Username
                       TextField(
                  controller: username,
                  decoration: InputDecoration(
                    hintText: 'Username (min. 4 characters)',
                    prefixIcon: Icon(Icons.alternate_email),
                    suffixIcon: isCheckingUsername
                        ? Padding(
                            padding: EdgeInsets.all(14),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            isUsernameAvailable && usernameError == null
                                ? Icons.check_circle
                                : Icons.error,
                            color: isUsernameAvailable && usernameError == null
                                ? Colors.green
                                : Colors.red,
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabled: !isLoading,
                    errorText: usernameError,
                    helperText: 'Start with letter, use letters and numbers only',
                    helperMaxLines: 2,
                  ),
                  onChanged: debouncedUsernameCheck, // Using the correct function name
                  style: TextStyle(fontSize: isTablet ? 18 : 16),
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  enableSuggestions: false,
                  keyboardType: TextInputType.text,
                ),
                  // Email
                  TextField(
                    controller: email,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabled: !isLoading,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(fontSize: isTablet ? 18 : 16),
                  ),
                  SizedBox(height: isTablet ? 24 : 16),
                  // Password
                  TextField(
                    controller: password,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabled: !isLoading,
                    ),
                    obscureText: true,
                    style: TextStyle(fontSize: isTablet ? 18 : 16),
                  ),
                  SizedBox(height: isTablet ? 32 : 24),
                  // Sign Up Button
                  SizedBox(
                    height: isTablet ? 60 : 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : signUp,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: isTablet ? 24 : 20,
                              width: isTablet ? 24 : 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'Sign Up',
                              style: TextStyle(fontSize: isTablet ? 18 : 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    // );
  }
}
