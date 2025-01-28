import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  final bool isLargeScreen;
  final VoidCallback onCameraPressed;
  final VoidCallback onGalleryPressed;
  final bool processing;

  const HeaderSection({
    Key? key,
    required this.isLargeScreen,
    required this.onCameraPressed,
    required this.onGalleryPressed,
    required this.processing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isLargeScreen ? 32 : 16),
      decoration: BoxDecoration(
        color: Color(0xFF19647E),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Scan New Product',
            style: TextStyle(
              color: Colors.white,
              fontSize: isLargeScreen ? 28 : 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Take a photo or choose from gallery to add a new product',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: isLargeScreen ? 16 : 14,
            ),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildScanButton(
                icon: Icons.camera_alt,
                label: 'Take Photo',
                onTap: processing ? null : onCameraPressed,
                isLargeScreen: isLargeScreen,
              ),
              SizedBox(width: 16),
              _buildScanButton(
                icon: Icons.photo_library,
                label: 'Gallery',
                onTap: processing ? null : onGalleryPressed,
                isLargeScreen: isLargeScreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required bool isLargeScreen,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFFFC857),
        foregroundColor: Color(0xFF1F2041),
        padding: EdgeInsets.symmetric(
          horizontal: isLargeScreen ? 32 : 24,
          vertical: isLargeScreen ? 16 : 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isLargeScreen ? 24 : 20,
          ),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: isLargeScreen ? 16 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
