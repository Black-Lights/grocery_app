import 'package:get/get.dart';

class ProductListController extends GetxController {
  final RxString currentSort = 'Category (A-Z)'.obs;

  void updateSort(String sort) {
    currentSort.value = sort;
  }
}
