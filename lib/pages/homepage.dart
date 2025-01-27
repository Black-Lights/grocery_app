import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:grocery/pages/about_page.dart';
import 'package:grocery/pages/area_detail_page.dart';
import 'package:grocery/pages/contact_page.dart';
import 'package:grocery/pages/settings_page.dart';
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
  List<Product> _searchResults = [];
  List<Product> searchResults = [];
  bool _isSearching = false;
  bool isSearching = false;
  bool isInitializing = true;

  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Add listener to handle focus changes
    _searchFocusNode.addListener(() {
      if (_searchFocusNode.hasFocus) {
        print('Search field focused');
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _searchFocusNode.dispose(); // Dispose focus node
    super.dispose();
  }

  // Add method to unfocus
  void _unfocusSearch() {
    _searchFocusNode.unfocus();
  }

  Timer? _debounce;


  Future<void> _searchProducts(String query) async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.trim().length < 2) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
        return;
      }

      setState(() {
        _isSearching = true;
      });

      try {
        final results = await _firestoreService.searchProducts(query);
        if (mounted) {
          setState(() {
            _searchResults = results;
            _isSearching = false;
          });
        }
      } catch (e) {
        print('Error in search: $e');
        if (mounted) {
          setState(() {
            _searchResults = [];
            _isSearching = false;
          });
        }
      }
    });
  }

  Widget _buildSearchBar(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode, // Add focus node
            autofocus: false,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: Icon(Icons.search),
              suffixIcon: _isSearching
                  ? Padding(
                      padding: EdgeInsets.all(14),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchResults = [];
                            });
                          },
                        )
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: _searchProducts,
          ),
          if (_searchResults.isNotEmpty)
            Container(
              margin: EdgeInsets.only(top: 8),
              constraints: BoxConstraints(
                maxHeight: 300,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final product = _searchResults[index];
                  final daysUntilExpiry = product.expiryDate.difference(DateTime.now()).inDays;
                  
                  String expiryText;
                  if (daysUntilExpiry > 365) {
                    final years = (daysUntilExpiry / 365).floor();
                    expiryText = '$years year${years > 1 ? 's' : ''} left';
                  } else if (daysUntilExpiry > 30) {
                    final months = (daysUntilExpiry / 30).floor();
                    expiryText = '$months month${months > 1 ? 's' : ''} left';
                  } else if (daysUntilExpiry > 0) {
                    expiryText = '$daysUntilExpiry day${daysUntilExpiry > 1 ? 's' : ''} left';
                  } else if (daysUntilExpiry == 0) {
                    expiryText = 'Expires today';
                  } else {
                    expiryText = 'Expired';
                  }

                  final expiryColor = daysUntilExpiry < 0
                      ? Colors.red
                      : daysUntilExpiry < 7
                          ? Colors.orange
                          : Colors.green;

                  return ListTile(
                    title: Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<Area?>(
                          future: _firestoreService.getArea(product.areaId),
                          builder: (context, snapshot) {
                            final areaName = snapshot.data?.name ?? 'Unknown Area';
                            return Text('Location: $areaName');
                          },
                        ),
                        Text('Quantity: ${product.quantity} ${product.unit}'),
                        Text(
                          expiryText,
                          style: TextStyle(color: expiryColor),
                        ),
                      ],
                    ),
                    onTap: () async {
                      // Clear search
                      _searchController.clear();
                      setState(() {
                        _searchResults = [];
                      });

                      // Navigate to the area
                      final area = await _firestoreService.getArea(product.areaId);
                      if (area != null) {
                        Get.to(() => AreaDetailPage(area: area));
                      }
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }


  void _showAreaOptions(Area area) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              area.name,
              style: TextStyle(
                fontSize: isTablet ? 24 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Area'),
              onTap: () {
                Get.back();
                _showEditAreaDialog(area);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text(
                'Delete Area',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Get.back();
                _showDeleteConfirmation(area);
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  void _showEditAreaDialog(Area area) {
    final nameController = TextEditingController(text: area.name);
    final descriptionController = TextEditingController(text: area.description);

    Get.dialog(
      AlertDialog(
        title: Text('Edit Area'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Area Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
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
              if (nameController.text.trim().isEmpty) {
                Get.snackbar(
                  'Error',
                  'Area name cannot be empty',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              try {
                final updatedArea = Area(
                  id: area.id,
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                  createdAt: area.createdAt,
                  updatedAt: DateTime.now(),
                );
                
                await _firestoreService.updateArea(updatedArea);
                Get.back();
                Get.snackbar(
                  'Success',
                  'Area updated successfully',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to update area',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Area area) {
    Get.dialog(
      AlertDialog(
        title: Text('Delete Area'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete "${area.name}"?'),
            SizedBox(height: 12),
            StreamBuilder<List<Product>>(
              stream: _firestoreService.getAreaProducts(area.id),
              builder: (context, snapshot) {
                final productCount = snapshot.data?.length ?? 0;
                if (productCount > 0) {
                  return Text(
                    'This area contains $productCount products that will also be deleted.',
                    style: TextStyle(color: Colors.red),
                  );
                }
                return SizedBox.shrink();
              },
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
              try {
                await _firestoreService.deleteArea(area.id);
                Get.back();
                Get.snackbar(
                  'Success',
                  'Area deleted successfully',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to delete area',
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
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
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    
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
            accountEmail: Row(
              children: [
                Text(user?.email ?? ''),
                SizedBox(width: 8),
                Icon(
                  user?.emailVerified ?? false ? Icons.verified : Icons.warning,
                  size: 16,
                  color: user?.emailVerified ?? false ? Colors.white : Colors.orange,
                ),
              ],
            ),
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
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => SettingsPage());
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('About'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => AboutPage());
            },
          ),
          ListTile(
            leading: Icon(Icons.contact_support),
            title: Text('Contact Us'),
            onTap: () {
              Navigator.pop(context);
              Get.to(() => ContactPage());
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
          Get.to(() => AreaDetailPage(area: area));
        },
        onLongPress: () {
          _showAreaOptions(area);
        },
        borderRadius: BorderRadius.circular(12),
        child: StreamBuilder<List<Product>>(
          stream: _firestoreService.getAreaProducts(area.id),
          builder: (context, snapshot) {
            final productCount = snapshot.data?.length ?? 0;
            
            return Padding(
              padding: EdgeInsets.all(16),
              child: Column(
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
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    
  

    return GestureDetector(
      onTap: () {
        // Unfocus when tapping outside of text field
        _unfocusSearch();
      },
      child: Scaffold(
        drawer: _buildNavigationDrawer(),
        appBar: AppBar(
          title: Text(
            'My Grocery Storage',
            style: TextStyle(fontSize: isTablet ? 24 : 20),
          ),
          actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () => Get.to(() => ShoppingListPage()),
          ),
          SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            _buildSearchBar(isTablet),
            Expanded(
              child: _buildAreasList(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _unfocusSearch(); // Unfocus when adding new area
            _showAddAreaDialog();
          },
          child: Icon(Icons.add),
          tooltip: 'Add Storage Area',
        ),
      ),
    );
  }

}
