import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Request Camera Permission
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Request Storage Permission (For Image Selection & Saving)
  Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  /// Check if permissions are granted
  Future<bool> checkPermissions() async {
    final camera = await Permission.camera.status;
    final storage = await Permission.storage.status;

    return camera.isGranted && storage.isGranted;
  }
}
