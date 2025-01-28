import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/firestore_service.dart';
import '../../../models/product.dart';
import '../../../models/area.dart';
import '../../area_detail_page.dart';

class SearchBar extends StatefulWidget {
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final FocusNode _searchFocusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _animation;
  List<Product> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _searchFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_searchFocusNode.hasFocus) {
      _animationController.forward();
    } else if (!_searchFocusNode.hasFocus && _searchController.text.isEmpty) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Container(
      margin: EdgeInsets.all(isTablet ? 24.0 : 16.0),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1 * _animation.value),
                      blurRadius: 8 * _animation.value,
                      offset: Offset(0, 4 * _animation.value),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: _buildSuffixIcon(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: _searchProducts,
                ),
              );
            },
          ),
          if (_searchResults.isNotEmpty)
            _buildSearchResults(),
        ],
      ),
    );
  }

  Widget? _buildSuffixIcon() {
    if (_isSearching) {
      return Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
        ),
      );
    }
    if (_searchController.text.isNotEmpty) {
      return IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          _searchController.clear();
          setState(() => _searchResults = []);
        },
      );
    }
    return null;
  }

  Widget _buildSearchResults() {
    return Container(
      margin: EdgeInsets.only(top: 8),
      constraints: BoxConstraints(maxHeight: 300),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 4),
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
    return ListTile(
      title: Text(
        product.name,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: FutureBuilder<Area?>(
        future: _firestoreService.getArea(product.areaId),
        builder: (context, snapshot) {
          final areaName = snapshot.data?.name ?? 'Unknown Area';
          return Text('Location: $areaName');
        },
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
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
}
