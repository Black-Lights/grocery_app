import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:grocery/pages/area_detail_page.dart';
import '../services/firestore_service.dart';
import '../services/shopping_service.dart';
import '../models/area.dart';
import '../models/product.dart';
import '../models/shopping_item.dart';
import '../auth/wrapper.dart';
import 'shopping_list_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final ShoppingService _shoppingService = ShoppingService();
  final TextEditingController _searchController = TextEditingController();
  List<Product> searchResults = [];
  bool isSearching = false;
  bool isInitializing = true;

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
    } finally {
      if (mounted) {
        setState(() {
          isInitializing = false;
        });
      }
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
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showAddAreaDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        title: Text('Add Storage Area'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Area Name',
                hintText: 'e.g., Refrigerator, Freezer',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Optional description',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
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
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationDrawer() {
    final user = _auth.currentUser;
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                size: 50,
                color: Theme.of(context).primaryColor,
              ),
            ),
            accountName: Text(user?.displayName ?? 'User'),
            accountEmail: Text(user?.email ?? ''),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            selected: true,
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Shopping List'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => ShoppingListPage());
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Sign Out'),
            onTap: _signOut,
          ),
        ],
      ),
    );
  }

  Widget _buildAreaCard(Area area) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Get.to(
            () => AreaDetailPage(area: area),
            transition: Transition.rightToLeft,
            duration: Duration(milliseconds: 300),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: StreamBuilder<List<Product>>(
          stream: _firestoreService.getAreaProducts(area.id),
          builder: (context, snapshot) {
            final productCount = snapshot.data?.length ?? 0;
            
            return Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getAreaIcon(area.name),
                    size: 40,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(height: 12),
                  Text(
                    area.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    area.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$productCount items',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _getAreaIcon(String areaName) {
    switch (areaName.toLowerCase()) {
      case 'refrigerator':
        return Icons.kitchen;
      case 'freezer':
        return Icons.ac_unit;
      case 'pantry':
        return Icons.kitchen_outlined;
      case 'cabinet':
        return Icons.door_sliding;
      case 'counter':
        return Icons.countertops;
      default:
        return Icons.storage;
    }
  }

  Widget _buildAreasList() {
    return StreamBuilder<List<Area>>(
      stream: _firestoreService.getAreas(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error loading areas'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        final areas = snapshot.data ?? [];
        
        if (areas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.storage,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No storage areas yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,  // Make cards square
          ),
          itemCount: areas.length,
          itemBuilder: (context, index) {
            return _buildAreaCard(areas[index]);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildNavigationDrawer(),
      appBar: AppBar(
        title: Text('My Grocery Storage'),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () => Get.to(() => ShoppingListPage()),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: _buildAreasList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAreaDialog,
        child: Icon(Icons.add),
        tooltip: 'Add Storage Area',
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
