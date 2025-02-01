import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';  // Add this for PlatformException
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Add this for FieldValue
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../config/theme.dart';
import '../services/firestore_service.dart';
import '../widgets/navigation/app_scaffold.dart';
import 'auth_layout.dart';
import 'signup.dart';
import 'forgot_password.dart';
import 'verify.dart';
import '../pages/homepage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn();
  final RxBool isLoading = false.obs;
  final RxBool isGoogleLoading = false.obs;

  Future<void> signInWithGoogle() async {
    if (isLoading.value || isGoogleLoading.value) return;

    try {
      isGoogleLoading.value = true;

      // Initialize GoogleSignIn
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
        ],
        signInOption: SignInOption.standard,
      );

      // Sign out first to ensure clean state
      await googleSignIn.signOut();
      
      // Start sign in flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the sign-in flow
        print('User canceled Google Sign In');
        return;
      }

      try {
        // Get auth details
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        // Create credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase
        final UserCredential userCredential = 
            await FirebaseAuth.instance.signInWithCredential(credential);

        final user = userCredential.user;
        if (user == null) throw Exception('Failed to sign in with Google');

        // Check if this is a new user
        if (userCredential.additionalUserInfo?.isNewUser ?? false) {
          await _createUserDocument(user, googleUser);
        }

        // Navigate to HomePage
        Get.offAll(() => HomePage());

      } catch (e) {
        print('Error during Google authentication: $e');
        throw Exception('Failed to authenticate with Google');
      }

    } catch (e) {
      print('Error during Google Sign In: $e');
      String message = 'Failed to sign in with Google. Please try again.';
      
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'account-exists-with-different-credential':
            message = 'An account already exists with this email';
            break;
          case 'invalid-credential':
            message = 'Invalid credentials. Please try again';
            break;
          case 'operation-not-allowed':
            message = 'Google sign in is not enabled';
            break;
          case 'user-disabled':
            message = 'This account has been disabled';
            break;
          case 'user-not-found':
            message = 'No account found with this email';
            break;
        }
      }

      Get.snackbar(
        'Sign In Failed',
        message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 5),
      );
    } finally {
      isGoogleLoading.value = false;
    }
  }

  Future<void> _createUserDocument(User user, GoogleSignInAccount googleUser) async {
    try {
      final firestoreService = Get.find<FirestoreService>();
      
      // Split display name into first and last name
      final nameParts = googleUser.displayName?.split(' ') ?? ['', ''];
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1 ? nameParts.last : '';
      
      // Create user document
      await firestoreService.createUserProfile(
        userId: user.uid,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': googleUser.email,
          'photoURL': googleUser.photoUrl,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'provider': 'google',
        },
      );

      // Initialize default areas
      await firestoreService.initializeDefaultAreas();
    } catch (e) {
      print('Error creating user document: $e');
      // Continue anyway as the auth was successful
    }
  }

  Future<void> signIn() async {
    if (isLoading.value || isGoogleLoading.value) return;

    // Validate inputs
    if (email.text.trim().isEmpty || password.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      
      print('Attempting to sign in with email: ${email.text.trim()}');
      
      // Attempt sign in
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text,
      );

      final user = userCredential.user;
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user found with this email',
        );
      }

      print('Successfully signed in user: ${user.uid}');

      // Check email verification
      if (!user.emailVerified) {
        Get.off(() => VerifyEmailPage()); // Use Get.off to prevent back navigation
      } else {
        // Clear all previous routes and go to HomePage
        Get.offAll(() => AppScaffold());
      }
      
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException during login: ${e.code} - ${e.message}');
      
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found with this email';
          break;
        case 'wrong-password':
          message = 'Incorrect password';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'user-disabled':
          message = 'This account has been disabled';
          break;
        case 'too-many-requests':
          message = 'Too many attempts. Please try again later';
          break;
        case 'network-request-failed':
          message = 'Network error. Please check your connection';
          break;
        case 'invalid-credential':
          message = 'Invalid login credentials';
          break;
        default:
          message = e.message ?? 'An error occurred during sign in';
      }
      
      Get.snackbar(
        'Sign In Failed',
        message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 5),
        icon: Icon(Icons.error_outline, color: Colors.white),
      );
    } catch (e) {
      print('Unexpected error during sign in: $e');
      
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 5),
        icon: Icon(Icons.error_outline, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }
  Widget _buildLoginForm() {
    return Container(
      constraints: BoxConstraints(maxWidth: 400),
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome Back',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: GroceryColors.navy,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Sign in to continue managing your groceries',
            style: TextStyle(
              fontSize: 16,
              color: GroceryColors.grey400,
            ),
          ),
          SizedBox(height: 32),
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
          ),
          SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Get.to(() => ForgotPasswordPage()),
              child: Text('Forgot Password?'),
            ),
          ),
          SizedBox(height: 24),
          Obx(() => ElevatedButton(
            onPressed: isLoading.value || isGoogleLoading.value ? null : signIn,
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
                    'Sign In',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          )),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: GroceryColors.grey400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(child: Divider()),
            ],
          ),
          SizedBox(height: 16),
          Obx(() => OutlinedButton(
            onPressed: isLoading.value || isGoogleLoading.value 
                ? null 
                : signInWithGoogle,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: GroceryColors.grey200),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isGoogleLoading.value
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        GroceryColors.teal,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/google_logo.png',
                        height: 24,
                        width: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Sign in with Google',
                        style: TextStyle(
                          color: GroceryColors.navy,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          )),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: TextStyle(color: GroceryColors.grey400),
              ),
              TextButton(
                onPressed: () => Get.to(() => SignUpPage()),
                child: Text('Sign Up'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Sign In',
      child: Center(
        child: SingleChildScrollView(
          child: _buildLoginForm(),
        ),
      ),
    );
  }
}
