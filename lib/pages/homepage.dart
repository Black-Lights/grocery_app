import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../services/theme_service.dart';
import '../widgets/home/components/search_bar.dart';
import '../widgets/home/components/storage_grid.dart';
import '../widgets/home/components/home_banners.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';
import '../config/theme.dart';
import 'shopping_list_page.dart';
import 'settings_page.dart';
import 'about_page.dart';
import 'contact_page.dart';
import '../auth/wrapper.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = Get.find();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _checkAndInitializeAreas();
  }

  Future<void> _checkAndInitializeAreas() async {
    try {
      if (_auth.currentUser == null) {
        print('No authenticated user found');
        Get.offAll(() => Wrapper());
        return;
      }
      await _firestoreService.initializeDefaultAreas();
    } catch (e) {
      print('Error checking/initializing areas: $e');
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      Get.offAll(() => Wrapper());
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign out',
        backgroundColor: GroceryColors.error,
        colorText: GroceryColors.surface,
      );
    }
  }

  Widget _buildNavigationDrawer() {
    final user = _auth.currentUser;
    final isTablet = MediaQuery.of(context).size.width > 600;
    
    return Drawer(
      backgroundColor: GroceryColors.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future: _firestoreService.getUserData(),
            builder: (context, snapshot) {
              String displayName = 'User';
              
              if (snapshot.hasData && snapshot.data != null) {
                final userData = snapshot.data!;
                // Try to get full name first
                if (userData['firstName']?.isNotEmpty == true || 
                    userData['lastName']?.isNotEmpty == true) {
                  displayName = '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
                }
                // If no full name, use username
                else if (userData['username']?.isNotEmpty == true) {
                  displayName = userData['username'];
                }
              }

              return UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: GroceryColors.navy,
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: GroceryColors.surface,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: GroceryColors.navy,
                  ),
                ),
                accountName: Text(
                  displayName,
                  style: TextStyle(
                    color: GroceryColors.surface,
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Row(
                  children: [
                    Expanded(
                      child: Text(
                        user?.email ?? '',
                        style: TextStyle(
                          color: GroceryColors.surface,
                          fontSize: isTablet ? 16 : 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      user?.emailVerified ?? false ? Icons.verified : Icons.warning,
                      size: isTablet ? 20 : 16,
                      color: user?.emailVerified ?? false 
                        ? GroceryColors.success 
                        : GroceryColors.warning,
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.home, color: GroceryColors.navy),
            title: Text(
              'Home',
              style: TextStyle(
                color: GroceryColors.navy,
                fontSize: isTablet ? 18 : 16,
              ),
            ),
            selected: true,
            selectedColor: GroceryColors.teal,
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart, color: GroceryColors.navy),
            title: Text(
              'Shopping List',
              style: TextStyle(
                color: GroceryColors.navy,
                fontSize: isTablet ? 18 : 16,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => ShoppingListPage());
            },
          ),
          Divider(color: GroceryColors.grey200),
          ListTile(
            leading: Icon(Icons.settings, color: GroceryColors.navy),
            title: Text(
              'Settings',
              style: TextStyle(
                color: GroceryColors.navy,
                fontSize: isTablet ? 18 : 16,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => SettingsPage());
            },
          ),
          ListTile(
            leading: Icon(Icons.info, color: GroceryColors.navy),
            title: Text(
              'About',
              style: TextStyle(
                color: GroceryColors.navy,
                fontSize: isTablet ? 18 : 16,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => AboutPage());
            },
          ),
          ListTile(
            leading: Icon(Icons.contact_support, color: GroceryColors.navy),
            title: Text(
              'Contact Us',
              style: TextStyle(
                color: GroceryColors.navy,
                fontSize: isTablet ? 18 : 16,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => ContactPage());
            },
          ),
          Divider(color: GroceryColors.grey200),
          ListTile(
            leading: Icon(Icons.logout, color: GroceryColors.error),
            title: Text(
              'Sign Out',
              style: TextStyle(
                color: GroceryColors.error,
                fontSize: isTablet ? 18 : 16,
              ),
            ),
            onTap: _signOut,
          ),
        ],
      ),
    );
  }

  void _showAddAreaDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final isTablet = MediaQuery.of(context).size.width > 600;
    
    Get.dialog(
      AlertDialog(
        title: Text(
          'Add Storage Area',
          style: TextStyle(
            color: GroceryColors.navy,
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Area Name',
                labelStyle: TextStyle(color: GroceryColors.grey400),
                hintText: 'e.g., Refrigerator, Freezer',
                hintStyle: TextStyle(color: GroceryColors.grey300),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: GroceryColors.grey200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: GroceryColors.grey200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: GroceryColors.teal, width: 2),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: GroceryColors.grey400),
                hintText: 'Optional description',
                hintStyle: TextStyle(color: GroceryColors.grey300),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: GroceryColors.grey200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: GroceryColors.grey200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: GroceryColors.teal, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: GroceryColors.grey400,
                fontSize: isTablet ? 16 : 14,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isNotEmpty) {
                try {
                  await _firestoreService.addArea(
                    nameController.text.trim(),
                    descriptionController.text.trim(),
                  );
                  Get.back();
                } catch (e) {
                  Get.snackbar(
                    'Error',
                    'Failed to add area',
                    backgroundColor: GroceryColors.error,
                    colorText: GroceryColors.surface,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: GroceryColors.navy,
              foregroundColor: GroceryColors.surface,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : 24,
                vertical: isTablet ? 16 : 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Add',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isTablet = MediaQuery.of(context).size.width > 600;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: GroceryColors.background,
        drawer: _buildNavigationDrawer(),
        appBar: AppBar(
          backgroundColor: GroceryColors.navy,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.menu, color: GroceryColors.surface),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          title: Text(
            'My Grocery Storage',
            style: TextStyle(
              color: GroceryColors.surface,
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.shopping_cart, color: GroceryColors.surface),
              onPressed: () => Get.to(() => ShoppingListPage()),
            ),
            SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await _checkAndInitializeAreas();
              final notificationService = Get.find<NotificationService>();
              await notificationService.initializeService();
            },
            child: CustomScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ProductSearchBar(),
                      HomeBanners(),
                    ],
                  ),
                ),
                SliverFillRemaining(
                  hasScrollBody: true,
                  child: StorageGrid(),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddAreaDialog(),
          backgroundColor: GroceryColors.teal,
          child: Icon(Icons.add, color: GroceryColors.surface),
          tooltip: 'Add Storage Area',
        ),
      ),
    );
  }
}