import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/theme.dart';
import '../../pages/homepage.dart';
import '../../pages/search_page.dart';
import '../../pages/notifications_page.dart';
import '../product_image_capture/product_image_capture.dart';
import 'bottom_navigation.dart';
import 'left_drawer.dart';

class AppScaffold extends StatefulWidget {
  final int? initialTab;

  const AppScaffold({
    Key? key,
    this.initialTab,
  }) : super(key: key);

  @override
  _AppScaffoldState createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  final RxInt _currentIndex = 0.obs;
  late final PageController _pageController;
  final List<Widget> _pages = [
    HomePage(),
    SearchPage(),
    NotificationsPage(),
    ProductImageCapture(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex.value = widget.initialTab ?? 0;
    _pageController = PageController(
      initialPage: widget.initialTab ?? 0,
      keepPage: true,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    _currentIndex.value = index;
  }

  void _onNavTapped(int index) {
    if (!_pageController.hasClients) return;
    
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: NeverScrollableScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: Obx(() => BottomNavigation(
        currentIndex: _currentIndex.value,
        onTap: _onNavTapped,
      )),
    );
  }
}
