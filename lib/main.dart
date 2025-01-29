import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/theme_service.dart';
import 'services/firestore_service.dart';
import 'services/notification_service.dart';
import 'auth/wrapper.dart';

Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize storage
    await GetStorage.init();
    
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize services
    final themeService = Get.put(ThemeService(), permanent: true);
    final firestoreService = Get.put(FirestoreService(), permanent: true);
    final notificationService = Get.put(
      NotificationService(firestoreService: firestoreService),
      permanent: true,
    );
    
    await notificationService.initializeService();

    runApp(const MyApp());
  } catch (e) {
    print('Error initializing app: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Grocery Manager',
      theme: Get.find<ThemeService>().getThemeData(),
      home: Wrapper(),
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Smart Grocery Manager',
          theme: Get.find<ThemeService>().getThemeData(),
          home: child,
        );
      },
    );
  }
}
