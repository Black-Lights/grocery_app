import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/area.dart';
import '../../../models/product.dart';
import '../../../services/firestore_service.dart';
import '../../area_detail_page.dart';
import 'storage_card.dart';

class StorageGrid extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return StreamBuilder<List<Area>>(
      stream: _firestoreService.getAreas(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error loading areas'));
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
                Icon(Icons.storage, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No storage areas yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isTablet ? 3 : 2,
            crossAxisSpacing: isTablet ? 24 : 16,
            mainAxisSpacing: isTablet ? 24 : 16,
            childAspectRatio: isTablet ? 1.2 : 1,
          ),
          itemCount: areas.length,
          itemBuilder: (context, index) => StorageCard(area: areas[index]),
        );
      },
    );
  }
}
