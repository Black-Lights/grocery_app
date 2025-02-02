import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/theme.dart';
import '../../../models/area.dart';
import '../../../models/product.dart';
import '../../../services/firestore_service.dart';
import 'recent_product_card.dart';
import 'empty_state.dart';

class RecentProductsSection extends StatelessWidget {
  final String? areaId;
  final bool isLargeScreen;
  final FirestoreService firestoreService;
  final VoidCallback onAddProduct;

  const RecentProductsSection({
    Key? key,
    required this.areaId,
    required this.isLargeScreen,
    required this.firestoreService,
    required this.onAddProduct,
  }) : super(key: key);

  Stream<List<Product>> _combineProductStreams(List<Area> areas) {
    if (areas.isEmpty) {
      return Stream.value([]);
    }

    final streams = areas.map((area) => 
      firestoreService.getAreaProducts(area.id)
    ).toList();

    return Stream.periodic(Duration(milliseconds: 100)).asyncMap((_) async {
      final results = await Future.wait(
        streams.map((stream) => stream.first)
      );
      
      final allProducts = results.expand((products) => products).toList();
      allProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return allProducts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Area>>(
      stream: firestoreService.getAreas(),
      builder: (context, areasSnapshot) {
        if (areasSnapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingState();
        }

        if (!areasSnapshot.hasData || areasSnapshot.data!.isEmpty) {
          return EmptyState(
            isLargeScreen: isLargeScreen,
            onAddProduct: onAddProduct,
          );
        }

        return StreamBuilder<List<Product>>(
          stream: areaId != null 
            ? firestoreService.getAreaProducts(areaId!)
            : _combineProductStreams(areasSnapshot.data!),
          builder: (context, productsSnapshot) {
            if (productsSnapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }

            if (!productsSnapshot.hasData || productsSnapshot.data!.isEmpty) {
              return EmptyState(
                isLargeScreen: isLargeScreen,
                onAddProduct: onAddProduct,
              );
            }

            final products = productsSnapshot.data!;
            products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
            final recentProducts = products.take(20).toList();

            return Column(
              children: [
                _buildHeader(products.length > 20),
                Expanded(
                  child: _buildProductGrid(
                    recentProducts,
                    areasSnapshot.data!,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: isLargeScreen ? 48 : 40,
            height: isLargeScreen ? 48 : 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                GroceryColors.teal,
              ),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Loading products...',
            style: TextStyle(
              fontSize: isLargeScreen ? 16 : 14,
              color: GroceryColors.grey400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool showViewAll) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
      decoration: BoxDecoration(
        color: GroceryColors.white,
        border: Border(
          bottom: BorderSide(
            color: GroceryColors.skyBlue.withOpacity(0.5),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: GroceryColors.navy.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: GroceryColors.teal,
                size: isLargeScreen ? 24 : 20,
              ),
              SizedBox(width: 12),
              Text(
                'Recent Products',
                style: TextStyle(
                  fontSize: isLargeScreen ? 20 : 18,
                  fontWeight: FontWeight.w600,
                  color: GroceryColors.navy,
                ),
              ),
            ],
          ),
          if (showViewAll)
            TextButton.icon(
              onPressed: () {
                // Navigate to all products
                // You can implement this functionality
              },
              icon: Icon(
                Icons.view_list_outlined,
                size: isLargeScreen ? 20 : 18,
                color: GroceryColors.teal,
              ),
              label: Text(
                'View All',
                style: TextStyle(
                  fontSize: isLargeScreen ? 16 : 14,
                  color: GroceryColors.teal,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductGrid(List<Product> products, List<Area> areas) {
    return Container(
      color: GroceryColors.background,
      child: GridView.builder(
        padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isLargeScreen ? 4 : 2, // Increased columns for large screen
          childAspectRatio: isLargeScreen ? 0.7 : 0.65, // Adjusted ratios
          crossAxisSpacing: isLargeScreen ? 24 : 16,
          mainAxisSpacing: isLargeScreen ? 24 : 16,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final area = areas.firstWhere(
            (area) => area.id == product.areaId,
            orElse: () => Area(
              id: '',
              name: 'Unknown Area',
              description: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          );

          return ProductCard(
            product: product,
            area: area,
            isLargeScreen: isLargeScreen,
          );
        },
      ),
    );
  }

  // Widget _buildProductGrid(List<Product> products, List<Area> areas) {
  //   return Container(
  //     color: GroceryColors.background,
  //     child: GridView.builder(
  //       padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
  //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //         crossAxisCount: isLargeScreen ? 3 : 2,
  //         // Adjust the aspect ratio based on screen size
  //         childAspectRatio: isLargeScreen ? 1.3 : 0.85,
  //         crossAxisSpacing: isLargeScreen ? 24 : 16,
  //         mainAxisSpacing: isLargeScreen ? 24 : 16,
  //       ),
  //       itemCount: products.length,
  //       itemBuilder: (context, index) {
  //         final product = products[index];
  //         final area = areas.firstWhere(
  //           (area) => area.id == product.areaId,
  //           orElse: () => Area(
  //             id: '',
  //             name: 'Unknown Area',
  //             description: '',
  //             createdAt: DateTime.now(),
  //             updatedAt: DateTime.now(),
  //           ),
  //         );

  //         return ProductCard(
  //           product: product,
  //           area: area,
  //           isLargeScreen: isLargeScreen,
  //           onTap: () {
  //             // You can implement product detail view here
  //             // Get.to(() => ProductDetailPage(product: product));
  //           },
  //         );
  //       },
  //     ),
  //   );
  // }
}