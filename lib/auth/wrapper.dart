import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'welcome_page.dart';
import 'verify.dart';
import '../widgets/navigation/app_scaffold.dart';

class Wrapper extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return WelcomePage();
        } else if (!user.emailVerified) {
          return VerifyEmailPage();
        } else {
          return AppScaffold();
        }
      },
      loading: () => Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => WelcomePage(),
    );
  }
}
