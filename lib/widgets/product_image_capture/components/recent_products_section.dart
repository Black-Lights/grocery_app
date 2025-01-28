import 'package:flutter/material.dart';
import '../../../models/area.dart';
import '../../../models/product.dart';
import '../../../services/firestore_service.dart';
import 'product_card.dart';
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
          return Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFFC857),
            ),
          );
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
              return Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFFC857),
                ),
              );
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(products.length > 20),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isLargeScreen ? 3 : 2,
                      childAspectRatio: isLargeScreen ? 1.5 : 1.2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: recentProducts.length,
                    itemBuilder: (context, index) {
                      final product = recentProducts[index];
                      final area = areasSnapshot.data!.firstWhere(
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
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(bool showViewAll) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Recently Added Products',
            style: TextStyle(
              color: Colors.white,
              fontSize: isLargeScreen ? 22 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showViewAll)
            TextButton.icon(
              onPressed: () {
                // Navigate to all products
              },
              icon: Icon(Icons.view_list, color: Color(0xFFFFC857)),
              label: Text(
                'View All',
                style: TextStyle(
                  color: Color(0xFFFFC857),
                  fontSize: isLargeScreen ? 16 : 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
