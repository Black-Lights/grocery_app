import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/shopping_list_page.dart';
import 'providers/app_providers.dart';
import 'services/notification_service.dart';
import 'services/theme_service.dart';
import 'services/shopping_service.dart';
import 'auth/wrapper.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await GetStorage.init();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize GetX services (will be migrated to Riverpod later)
    final themeService = Get.put(ThemeService(), permanent: true);
    final shoppingService = Get.put(ShoppingService(), permanent: true);

    runApp(
      const ProviderScope(
        child: MyApp(),
      ),
    );
  } catch (e) {
    print('Error initializing app: $e');
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize notification service
    ref.read(notificationServiceProvider).initialize();

    return GetMaterialApp(
      title: 'Smart Grocery Manager',
      theme: Get.find<ThemeService>().getThemeData(),
      home: Wrapper(),
      debugShowCheckedModeBanner: false,
      getPages: [
        GetPage(
          name: '/shopping-list',
          page: () => const ShoppingListPage(),
        ),
      ],
    );
  }
}
