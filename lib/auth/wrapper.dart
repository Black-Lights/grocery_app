import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../pages/homepage.dart';
import 'login.dart';
import 'verify.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});
  
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          print('Wrapper: User is logged in. Email verified: ${snapshot.data!.emailVerified}');
          if (snapshot.data!.emailVerified) {
            return HomePage();
          }
          return VerifyEmailPage();
        }

        print('Wrapper: No user logged in, showing LoginPage');
        return LoginPage();
      },
    );
  }
}
