import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/firestore_service.dart';
import '../models/product.dart';
import '../models/area.dart';
import '../config/theme.dart';
import 'area_detail_page.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> 
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FirestoreService _firestoreService = Get.find<FirestoreService>();
  final FocusNode _searchFocusNode = FocusNode();
  
  late AnimationController _animationController;
  late Animation<double> _searchBarAnimation;
  late Animation<double> _fadeAnimation;
  
  List<Product> _searchResults = [];
  bool _isSearching = false;
  RxBool _showRecentSearches = true.obs;
  RxList<String> _recentSearches = <String>[].obs;
  final int _maxRecentSearches = 5;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadRecentSearches();
    _searchFocusNode.requestFocus(); // Auto-focus search bar
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _searchBarAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.3, 1, curve: Curves.easeInOut),
      ),
    );

    _animationController.forward();
  }

  Future<void> _loadRecentSearches() async {
    // In a real app, load from local storage
    _recentSearches.value = ['Milk', 'Bread', 'Eggs', 'Cheese'];
  }

  void _addToRecentSearches(String query) {
    if (query.trim().isEmpty) return;
    
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    
    if (_recentSearches.length > _maxRecentSearches) {
      _recentSearches.removeLast();
    }
    // In a real app, save to local storage
  }

  Future<void> _searchProducts(String query) async {
    if (query.trim().length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _showRecentSearches.value = true;
      });
      return;
    }

    setState(() => _isSearching = true);
    _showRecentSearches.value = false;

    try {
      final results = await _firestoreService.searchProducts(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
        _addToRecentSearches(query);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    }
  }

  Widget _buildSearchBar() {
    return AnimatedBuilder(
      animation: _searchBarAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -50 * (1 - _searchBarAnimation.value)),
          child: Opacity(
            opacity: _searchBarAnimation.value,
            child: Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: GroceryColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: GroceryColors.navy.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: Icon(Icons.search, color: GroceryColors.teal),
                  suffixIcon: _buildSuffixIcon(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: GroceryColors.surface,
                ),
                onChanged: _searchProducts,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget? _buildSuffixIcon() {
    if (_isSearching) {
      return Padding(
        padding: const EdgeInsets.all(14),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(GroceryColors.teal),
          ),
        ),
      );
    }
    if (_searchController.text.isNotEmpty) {
      return IconButton(
        icon: Icon(Icons.clear, color: GroceryColors.grey400),
        onPressed: () {
          _searchController.clear();
          setState(() => _searchResults = []);
          _showRecentSearches.value = true;
        },
      );
    }
    return null;
  }

  Widget _buildRecentSearches() {
    return Obx(() {
      if (!_showRecentSearches.value || _recentSearches.isEmpty) return SizedBox();
      
      return FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Searches',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: GroceryColors.navy,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _recentSearches.clear(),
                    child: Text(
                      'Clear All',
                      style: TextStyle(color: GroceryColors.teal),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _recentSearches.map((search) => 
                  _buildRecentSearchChip(search)
                ).toList(),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildRecentSearchChip(String search) {
    return InkWell(
      onTap: () {
        _searchController.text = search;
        _searchProducts(search);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: GroceryColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: GroceryColors.grey200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 16, color: GroceryColors.grey400),
            SizedBox(width: 8),
            Text(
              search,
              style: TextStyle(color: GroceryColors.navy),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) return SizedBox();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) => 
          _buildSearchResultItem(_searchResults[index]),
      ),
    );
  }

  Widget _buildSearchResultItem(Product product) {
    final daysUntilExpiry = product.expiryDate.difference(DateTime.now()).inDays;
    
    return Hero(
      tag: 'product-${product.id}',
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final area = await _firestoreService.getArea(product.areaId);
            if (area != null) {
              Get.to(() => AreaDetailPage(area: area));
            }
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildExpiryBadge(daysUntilExpiry),
                  ],
                ),
                SizedBox(height: 8),
                FutureBuilder<Area?>(
                  future: _firestoreService.getArea(product.areaId),
                  builder: (context, snapshot) {
                    return Text(
                      'Location: ${snapshot.data?.name ?? 'Unknown Area'}',
                      style: TextStyle(color: GroceryColors.grey400),
                    );
                  },
                ),
                SizedBox(height: 4),
                Text(
                  'Quantity: ${product.quantity} ${product.unit}',
                  style: TextStyle(color: GroceryColors.grey400),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpiryBadge(int daysUntilExpiry) {
    String text;
    Color color;
    
    if (daysUntilExpiry > 30) {
      text = '${(daysUntilExpiry / 30).floor()}m';
      color = GroceryColors.success;
    } else if (daysUntilExpiry > 0) {
      text = '${daysUntilExpiry}d';
      color = GroceryColors.warning;
    } else {
      text = 'EXP';
      color = GroceryColors.error;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GroceryColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildRecentSearches(),
                    _buildSearchResults(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
