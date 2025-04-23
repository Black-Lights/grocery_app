import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../config/theme.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  
  final RxBool _isLoading = false.obs;
  final RxBool _isEditing = false.obs;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _isLoading.value = true;
    try {
      final userData = await _firestoreService.getUserData();
      _firstNameController.text = userData['firstName'] ?? '';
      _lastNameController.text = userData['lastName'] ?? '';
      _usernameController.text = userData['username'] ?? '';
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load profile data',
        backgroundColor: GroceryColors.error,
        colorText: GroceryColors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _updateProfile() async {
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _usernameController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        backgroundColor: GroceryColors.error,
        colorText: GroceryColors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    _isLoading.value = true;

    try {
      await _firestoreService.updateUserProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        username: _usernameController.text.trim(),
      );

      _isEditing.value = false;
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: GroceryColors.success,
        colorText: GroceryColors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile',
        backgroundColor: GroceryColors.error,
        colorText: GroceryColors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Widget _buildProfileHeader(bool isTablet) {
    final user = _auth.currentUser;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      decoration: BoxDecoration(
        color: GroceryColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: GroceryColors.skyBlue.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: GroceryColors.navy.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: isTablet ? 120 : 100,
                height: isTablet ? 120 : 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: GroceryColors.teal.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.person,
                  size: isTablet ? 60 : 50,
                  color: GroceryColors.teal,
                ),
              ),
              if (_isEditing.value)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: GroceryColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: GroceryColors.skyBlue.withOpacity(0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: GroceryColors.navy.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: isTablet ? 24 : 20,
                      color: GroceryColors.teal,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 24),
          Text(
            user?.email ?? '',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.w600,
              color: GroceryColors.navy,
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: (user?.emailVerified ?? false)
                  ? GroceryColors.success.withOpacity(0.1)
                  : GroceryColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: (user?.emailVerified ?? false)
                    ? GroceryColors.success.withOpacity(0.2)
                    : GroceryColors.warning.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  user?.emailVerified ?? false
                      ? Icons.verified
                      : Icons.warning,
                  size: isTablet ? 20 : 18,
                  color: user?.emailVerified ?? false
                      ? GroceryColors.success
                      : GroceryColors.warning,
                ),
                SizedBox(width: 8),
                Text(
                  user?.emailVerified ?? false
                      ? 'Email Verified'
                      : 'Email Not Verified',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w500,
                    color: user?.emailVerified ?? false
                        ? GroceryColors.success
                        : GroceryColors.warning,
                  ),
                ),
              ],
            ),
          ),
          if (!(user?.emailVerified ?? false))
            TextButton.icon(
              onPressed: () async {
                try {
                  await user?.sendEmailVerification();
                  Get.snackbar(
                    'Success',
                    'Verification email sent',
                    backgroundColor: GroceryColors.success,
                    colorText: GroceryColors.white,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                  );
                } catch (e) {
                  Get.snackbar(
                    'Error',
                    'Failed to send verification email',
                    backgroundColor: GroceryColors.error,
                    colorText: GroceryColors.white,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                  );
                }
              },
              icon: Icon(
                Icons.mail,
                color: GroceryColors.teal,
              ),
              label: Text(
                'Resend Verification Email',
                style: TextStyle(
                  color: GroceryColors.teal,
                  fontSize: isTablet ? 14 : 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileForm(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      decoration: BoxDecoration(
        color: GroceryColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: GroceryColors.skyBlue.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: GroceryColors.navy.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.w600,
                  color: GroceryColors.navy,
                ),
              ),
              IconButton(
                onPressed: () => _isEditing.value = !_isEditing.value,
                icon: Icon(
                  _isEditing.value ? Icons.close : Icons.edit,
                  color: GroceryColors.teal,
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          _buildTextField(
            controller: _firstNameController,
            label: 'First Name',
            icon: Icons.person_outline,
            isTablet: isTablet,
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _lastNameController,
            label: 'Last Name',
            icon: Icons.person_outline,
            isTablet: isTablet,
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: _usernameController,
            label: 'Username',
            icon: Icons.alternate_email,
            isTablet: isTablet,
          ),
          if (_isEditing.value) ...[
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: isTablet ? 56 : 48,
              child: ElevatedButton(
                onPressed: _isLoading.value ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: GroceryColors.teal,
                  foregroundColor: GroceryColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading.value
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            GroceryColors.white,
                          ),
                        ),
                      )
                    : Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isTablet,
  }) {
    return TextField(
      controller: controller,
      enabled: _isEditing.value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: _isEditing.value ? GroceryColors.teal : GroceryColors.grey400,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: GroceryColors.grey200,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: GroceryColors.skyBlue.withOpacity(0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: GroceryColors.teal,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: _isEditing.value 
            ? GroceryColors.white 
            : GroceryColors.grey100,
      ),
      style: TextStyle(
        fontSize: isTablet ? 16 : 14,
        color: _isEditing.value 
            ? GroceryColors.navy 
            : GroceryColors.grey400,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final showAppBar = !isTablet || MediaQuery.of(context).size.width <= 1100;

    return Scaffold(
      backgroundColor: GroceryColors.background,
      appBar: showAppBar
          ? AppBar(
              title: Text(
                'Profile',
                style: TextStyle(
                  fontSize: isTablet ? 24 : 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                Obx(() => IconButton(
                  icon: Icon(
                    _isEditing.value ? Icons.close : Icons.edit,
                    color: GroceryColors.white,
                  ),
                  onPressed: () => _isEditing.value = !_isEditing.value,
                )),
              ],
            )
          : null,
      body: Obx(() => _isLoading.value
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(GroceryColors.teal),
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(isTablet ? 32 : 16),
              child: Column(
                children: [
                  _buildProfileHeader(isTablet),
                  SizedBox(height: 24),
                  _buildProfileForm(isTablet),
                ],
              ),
            ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }
}
