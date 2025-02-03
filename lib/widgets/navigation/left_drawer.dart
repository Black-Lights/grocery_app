import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../config/theme.dart';
import '../../services/firestore_service.dart';
import '../../pages/shopping_list_page.dart';
import '../../pages/settings_page.dart';
import '../../pages/about_page.dart';
import '../../pages/contact_page.dart';
import '../../auth/wrapper.dart';

class LeftDrawer extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = Get.find();

  Future<void> _signOut() async {
    try {
      await GoogleSignIn().signOut();
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

  @override
  Widget build(BuildContext context) {
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
                if (userData['firstName']?.isNotEmpty == true || 
                    userData['lastName']?.isNotEmpty == true) {
                  displayName = '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
                }
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
          // Menu Items
          _buildMenuItem(
            icon: Icons.home,
            title: 'Home',
            isSelected: true,
            onTap: () => Navigator.pop(context),
            isTablet: isTablet,
          ),
          _buildMenuItem(
            icon: Icons.shopping_cart,
            title: 'Shopping List',
            onTap: () {
              Navigator.pop(context);
              Get.to(() => ShoppingListPage());
            },
            isTablet: isTablet,
          ),
          Divider(color: GroceryColors.grey200),
          _buildMenuItem(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {
              Navigator.pop(context);
              Get.to(() => SettingsPage());
            },
            isTablet: isTablet,
          ),
          _buildMenuItem(
            icon: Icons.info,
            title: 'About',
            onTap: () {
              Navigator.pop(context);
              Get.to(() => AboutPage());
            },
            isTablet: isTablet,
          ),
          _buildMenuItem(
            icon: Icons.contact_support,
            title: 'Contact Us',
            onTap: () {
              Navigator.pop(context);
              Get.to(() => ContactPage());
            },
            isTablet: isTablet,
          ),
          Divider(color: GroceryColors.grey200),
          _buildMenuItem(
            icon: Icons.logout,
            title: 'Sign Out',
            onTap: _signOut,
            isError: true,
            isTablet: isTablet,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Function() onTap,
    bool isSelected = false,
    bool isError = false,
    required bool isTablet,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isError ? GroceryColors.error : GroceryColors.navy,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isError ? GroceryColors.error : GroceryColors.navy,
          fontSize: isTablet ? 18 : 16,
        ),
      ),
      selected: isSelected,
      selectedColor: GroceryColors.teal,
      onTap: onTap,
    );
  }
}
