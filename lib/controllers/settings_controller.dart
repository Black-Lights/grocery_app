import 'package:get/get.dart';
import 'package:flutter/material.dart';

class SettingsController extends GetxController {
  final RxInt selectedIndex = (-1).obs;
  final RxString selectedTitle = ''.obs;

  void selectSetting(int index, String title) {
    selectedIndex.value = index;
    selectedTitle.value = title;
  }

  void clearSelection() {
    selectedIndex.value = -1;
    selectedTitle.value = '';
  }
}
