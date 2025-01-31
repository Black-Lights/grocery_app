import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../pages/homepage.dart';
import 'welcome_page.dart';  // Import welcome page instead of login
import 'verify.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Check if user is logged in and verified
        if (snapshot.hasData && snapshot.data != null) {
          print('Wrapper: User is logged in. Email verified: ${snapshot.data!.emailVerified}');
          
          if (snapshot.data!.emailVerified) {
            return HomePage();
          }
          return VerifyEmailPage();
        }

        // No user logged in, show welcome page
        print('Wrapper: No user logged in, showing WelcomePage');
        return WelcomePage();
      },
    );
  }
}
