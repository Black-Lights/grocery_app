import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'pages/shopping_list_page.dart';
import 'services/shopping_service.dart';
import 'services/theme_service.dart';
import 'services/firestore_service.dart';
import 'services/notification_service.dart';
import 'auth/wrapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // Initialize storage
    await GetStorage.init();

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    print('Firebase initialized successfully');

    // Add Firebase Auth state listener for debugging
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out');
      } else {
        print('User is signed in - UID: ${user.uid}');
      }
    });

    // Initialize services using GetX
    final themeService = Get.put(ThemeService(), permanent: true);
    final firestoreService = Get.put(FirestoreService(), permanent: true);
    final shoppingService = Get.put(ShoppingService(), permanent: true);
    final notificationService = Get.put(
      NotificationService(firestoreService: firestoreService),
      permanent: true,
    );

    await notificationService.initializeService();

    // Wrap the app with Riverpod
    runApp(ProviderScope(child: MyApp()));
  } catch (e) {
    print('Error initializing app: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Fresh Flow',
      theme: Get.find<ThemeService>().getThemeData(),
      home: Wrapper(),
      debugShowCheckedModeBanner: false,
      getPages: [
        GetPage(
          name: '/shopping-list',
          page: () => ShoppingListPage(),
        ),
      ],
    );
  }
}
