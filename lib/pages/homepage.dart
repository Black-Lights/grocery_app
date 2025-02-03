import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/navigation/left_drawer.dart';
import '../widgets/home/components/storage_grid.dart';
import '../config/theme.dart';
import '../providers/firestore_provider.dart';

// Provider for edit mode state
final isEditingProvider = StateProvider<bool>((ref) => false);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with AutomaticKeepAliveClientMixin {
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
      final firestoreService = ref.read(firestoreProvider);
      await firestoreService.initializeDefaultAreas();
    } catch (e) {
      print('Error checking/initializing areas: $e');
    }
  }

  Widget _buildHeader() {
    final isEditing = ref.watch(isEditingProvider);
    return Container(
      padding: const EdgeInsets.all(16),
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
          IconButton(
            icon: Icon(
              isEditing ? Icons.done : Icons.edit,
              color: GroceryColors.teal,
            ),
            onPressed: () => ref.read(isEditingProvider.notifier).state = !isEditing,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isTablet = MediaQuery.of(context).size.width > 600;
    final isEditing = ref.watch(isEditingProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: GroceryColors.background,
        drawer: const LeftDrawer(),
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
              onPressed: () => Navigator.pushNamed(context, '/shopping-list'),
              tooltip: 'Shopping List',
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _checkAndInitializeAreas,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(),
                ),
                SliverFillRemaining(
                  hasScrollBody: true,
                  child: StorageGrid(
                    isEditing: isEditing,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
