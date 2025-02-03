import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/firestore_provider.dart';
export 'left_drawer.dart';

class LeftDrawer extends ConsumerWidget {
  const LeftDrawer({Key? key}) : super(key: key);

  Future<void> _signOut(WidgetRef ref, BuildContext context) async {
    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.signOut();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/'); // Using standard navigation for now
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to sign out'),
            backgroundColor: GroceryColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final firestoreService = ref.watch(firestoreProvider);
    final isTablet = MediaQuery.of(context).size.width > 600;
    
    return Drawer(
      backgroundColor: GroceryColors.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          authState.when(
            data: (user) => FutureBuilder<Map<String, dynamic>>(
              future: firestoreService.getUserData(),
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
                      const SizedBox(width: 8),
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
            loading: () => UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: GroceryColors.navy),
              accountName: Text(
                'Loading...',
                style: TextStyle(color: GroceryColors.surface),
              ),
              accountEmail: const Text(''),
            ),
            error: (_, __) => UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: GroceryColors.navy),
              accountName: Text(
                'Error loading user',
                style: TextStyle(color: GroceryColors.surface),
              ),
              accountEmail: const Text(''),
            ),
          ),
          // Menu Items
          _buildMenuItem(
            context: context,
            icon: Icons.home,
            title: 'Home',
            isSelected: true,
            onTap: () => Navigator.pop(context),
            isTablet: isTablet,
          ),
          _buildMenuItem(
            context: context,
            icon: Icons.shopping_cart,
            title: 'Shopping List',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/shopping-list');
            },
            isTablet: isTablet,
          ),
          Divider(color: GroceryColors.grey200),
          _buildMenuItem(
            context: context,
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
            isTablet: isTablet,
          ),
          _buildMenuItem(
            context: context,
            icon: Icons.info,
            title: 'About',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/about');
            },
            isTablet: isTablet,
          ),
          _buildMenuItem(
            context: context,
            icon: Icons.contact_support,
            title: 'Contact Us',
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/contact');
            },
            isTablet: isTablet,
          ),
          Divider(color: GroceryColors.grey200),
          _buildMenuItem(
            context: context,
            icon: Icons.logout,
            title: 'Sign Out',
            onTap: () => _signOut(ref, context),
            isError: true,
            isTablet: isTablet,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
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
