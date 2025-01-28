import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/area.dart';
import '../../../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final Area area;
  final bool isLargeScreen;

  const ProductCard({
    Key? key,
    required this.product,
    required this.area,
    required this.isLargeScreen,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final daysUntilExpiry = product.expiryDate.difference(DateTime.now()).inDays;
    final isExpiringSoon = daysUntilExpiry <= 30;

    return Card(
      color: Color(0xFF4B3F72),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Show product details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isLargeScreen ? 18 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isExpiringSoon)
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFFFC857),
                      size: isLargeScreen ? 24 : 20,
                    ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Area: ${area.name}',
                style: TextStyle(
                  color: Color(0xFF119DA4),
                  fontSize: isLargeScreen ? 14 : 12,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Category: ${product.category}',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: isLargeScreen ? 14 : 12,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Expires: ${DateFormat('MMM dd, yyyy').format(product.expiryDate)}',
                style: TextStyle(
                  color: isExpiringSoon ? Color(0xFFFFC857) : Colors.white70,
                  fontSize: isLargeScreen ? 14 : 12,
                ),
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${product.quantity} ${product.unit}',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isLargeScreen ? 14 : 12,
                    ),
                  ),
                  Text(
                    'Added: ${DateFormat('MMM dd').format(product.createdAt)}',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: isLargeScreen ? 12 : 10,
                    ),
                  ),
                ],
              ),
              if (product.notes != null && product.notes!.isNotEmpty) ...[
                SizedBox(height: 8),
                Text(
                  product.notes!,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: isLargeScreen ? 12 : 10,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
