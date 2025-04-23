import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void showPermissionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Permission Required"),
      content: Text("Please enable Camera and Storage permissions in settings."),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        TextButton(
          onPressed: () => openAppSettings(),
          child: Text("Go to Settings"),
        ),
      ],
    ),
  );
}
