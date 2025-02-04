import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/firestore_service.dart';
import '../widgets/home/components/storage_grid.dart';
import '../config/theme.dart';
import '../widgets/navigation/left_drawer.dart';
import 'shopping_list_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  final FirestoreService _firestoreService = Get.find();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final RxBool _isEditing = false.obs;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _checkAndInitializeAreas();
  }

  Future<void> _checkAndInitializeAreas() async {
    try {
      await _firestoreService.initializeDefaultAreas();
    } catch (e) {
      log('Error checking/initializing areas: $e');
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'My Storage Areas',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: GroceryColors.navy,
            ),
          ),
          Obx(() => IconButton(
            icon: Icon(
              _isEditing.value ? Icons.done : Icons.edit,
              color: GroceryColors.teal,
            ),
            onPressed: () => _isEditing.toggle(),
          )),
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
        drawer: LeftDrawer(),
        appBar: AppBar(
          backgroundColor: GroceryColors.navy,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.menu, color: GroceryColors.surface),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          title: Text(
            'Fresh Flow',
            style: TextStyle(
              color: GroceryColors.surface,
              fontSize: isTablet ? 24 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.shopping_cart_outlined,
                color: GroceryColors.surface,
                size: isTablet ? 28 : 24,
              ),
              onPressed: () => Get.to(() => ShoppingListPage()),
              tooltip: 'Shopping List',
            ),
            SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await _checkAndInitializeAreas();
            },
            child: CustomScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(),
                ),
                SliverFillRemaining(
                  hasScrollBody: true,
                  child: Obx(() => StorageGrid(
                    isEditing: _isEditing.value,
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}