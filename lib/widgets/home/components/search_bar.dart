import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/firestore_service.dart';
import '../../../models/product.dart';
import '../../../models/area.dart';
import '../../../pages/area_detail_page.dart';
import '../../../config/theme.dart';

class ProductSearchBar extends StatefulWidget {
  const ProductSearchBar({Key? key}) : super(key: key);

  @override
  _ProductSearchBarState createState() => _ProductSearchBarState();
}

class _ProductSearchBarState extends State<ProductSearchBar> 
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _animation;
  List<Product> _searchResults = [];
  bool _isSearching = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);
    
    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Ensure focus is removed when widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchFocusNode.unfocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_searchFocusNode.hasFocus) {
      _animationController.forward();
    } else {
      _animationController.reverse();
      // Clear search results when focus is lost
      if (_searchResults.isNotEmpty) {
        setState(() {
          _searchResults = [];
        });
      }
    }
  }


  Future<void> _searchProducts(String query) async {
    if (query.trim().length < 2) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      final results = await _firestoreService.searchProducts(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
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
        icon: Icon(Icons.clear, color: GroceryColors.grey300),
        onPressed: () {
          _searchController.clear();
          setState(() => _searchResults = []);
          _searchFocusNode.unfocus();
        },
      );
    }
    return null;
  }

  Widget _buildSearchResults() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: GroceryColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GroceryColors.grey100),
        boxShadow: [
          BoxShadow(
            color: GroceryColors.navy.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _searchResults.length,
        itemBuilder: (context, index) => _buildSearchResultItem(_searchResults[index]),
      ),
    );
  }

  Widget _buildSearchResultItem(Product product) {
    final daysUntilExpiry = product.expiryDate.difference(DateTime.now()).inDays;
    
    String expiryText;
    Color expiryColor;
    
    if (daysUntilExpiry > 365) {
      final years = (daysUntilExpiry / 365).floor();
      expiryText = '$years year${years > 1 ? 's' : ''} left';
      expiryColor = GroceryColors.success;
    } else if (daysUntilExpiry > 30) {
      final months = (daysUntilExpiry / 30).floor();
      expiryText = '$months month${months > 1 ? 's' : ''} left';
      expiryColor = GroceryColors.success;
    } else if (daysUntilExpiry > 7) {
      expiryText = '$daysUntilExpiry days left';
      expiryColor = GroceryColors.success;
    } else if (daysUntilExpiry > 0) {
      expiryText = '$daysUntilExpiry day${daysUntilExpiry > 1 ? 's' : ''} left';
      expiryColor = GroceryColors.warning;
    } else if (daysUntilExpiry == 0) {
      expiryText = 'Expires today';
      expiryColor = GroceryColors.warning;
    } else {
      expiryText = 'Expired';
      expiryColor = GroceryColors.error;
    }

    return ListTile(
      title: Text(
        product.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FutureBuilder<Area?>(
            future: _firestoreService.getArea(product.areaId),
            builder: (context, snapshot) {
              final areaName = snapshot.data?.name ?? 'Unknown Area';
              return Text(
                'Location: $areaName',
                style: TextStyle(color: GroceryColors.grey400),
              );
            },
          ),
          Text(
            'Quantity: ${product.quantity} ${product.unit}',
            style: TextStyle(color: GroceryColors.grey400),
          ),
          Text(
            expiryText,
            style: TextStyle(color: expiryColor, fontWeight: FontWeight.w500),
          ),
        ],
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: GroceryColors.grey300),
      onTap: () async {
        _searchController.clear();
        setState(() => _searchResults = []);
        final area = await _firestoreService.getArea(product.areaId);
        if (area != null) {
          Get.to(() => AreaDetailPage(area: area));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24.0 : 16.0,
          vertical: 8.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: GroceryColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: GroceryColors.grey100),
                    boxShadow: [
                      BoxShadow(
                        color: GroceryColors.navy.withOpacity(0.1 * _animation.value),
                        blurRadius: 8 * _animation.value,
                        offset: Offset(0, 4 * _animation.value),
                      ),
                    ],
                  ),
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      if (!hasFocus) {
                        _searchFocusNode.unfocus();
                      }
                    },
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      autofocus: false,
                      enableInteractiveSelection: true,
                      decoration: InputDecoration(
                        hintText: 'Search products...',
                        hintStyle: TextStyle(color: GroceryColors.grey300),
                        prefixIcon: Icon(Icons.search, color: GroceryColors.grey300),
                        suffixIcon: _buildSuffixIcon(),
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
                        filled: true,
                        fillColor: GroceryColors.surface,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: isTablet ? 16 : 12,
                        ),
                      ),
                      onChanged: _searchProducts,
                      onTap: () {
                        // Do nothing on tap to prevent unwanted focus
                      },
                    ),
                  ),
                );
              },
            ),
            if (_searchResults.isNotEmpty)
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: _buildSearchResults(),
              ),
          ],
        ),
      ),
    );
  }

  
}