import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../config/theme.dart';
import '../widgets/navigation/app_scaffold.dart';
import 'auth_layout.dart';
import 'signup.dart';
import 'forgot_password.dart';
import 'verify.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();
  bool isLoading = false;
  bool isGoogleLoading = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> signIn() async {
    final authRepo = ref.read(authRepositoryProvider);
    final firestoreService = ref.read(firestoreServiceProvider); // Fetch FirestoreService

    if (email.text.trim().isEmpty || password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final userCredential = await authRepo.signIn(email.text.trim(), password.text);

      if (userCredential?.user != null) {
        if (!userCredential!.user!.emailVerified) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => VerifyEmailPage()));
        } else {
          //Fetch user profile from Firestore
          final userData = await firestoreService.getUserData();

          print("User Profile: ${userData['firstName']} ${userData['lastName']} - ${userData['username']}");

          //You can now pass `userData` to another screen if needed.
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AppScaffold()));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> signInWithGoogle() async {
    final authRepo = ref.read(authRepositoryProvider);

    if (isGoogleLoading) return;
    setState(() => isGoogleLoading = true);

    try {
      final userCredential = await authRepo.signInWithGoogle();

      if (userCredential?.user?.emailVerified == false) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => VerifyEmailPage()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AppScaffold()));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => isGoogleLoading = false);
    }
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
            key: Key('emailField'),
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
            key: Key('passwordField'),
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
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ForgotPasswordPage())),
              child: Text('Forgot Password?'),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            key: Key('loginButton'),
            onPressed: isLoading ? null : signIn,
            style: ElevatedButton.styleFrom(
              backgroundColor: GroceryColors.teal,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isLoading
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
          ),
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
          OutlinedButton(
            onPressed: isGoogleLoading ? null : signInWithGoogle,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: GroceryColors.grey200),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isGoogleLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(GroceryColors.teal),
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
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account? ",
                style: TextStyle(color: GroceryColors.grey400),
              ),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SignUpPage())),
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
