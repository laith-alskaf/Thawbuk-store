import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../navigation/shells/main_app_shell.dart';
import '../../../core/theme/app_theme.dart';

/// Layout محسن للتطبيق الرئيسي مع shell routing
class MainLayoutImproved extends StatelessWidget {
  final Widget child;

  const MainLayoutImproved({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.path;
    final currentIndex = MainAppTabHelper.getTabIndex(currentLocation);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey,
        backgroundColor: AppColors.surface,
        elevation: 8,
        onTap: (index) => _onTabTapped(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'المنتجات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'السلة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: 'المفضلة',
          ),
        ],
      ),
    );
  }

  void _onTabTapped(BuildContext context, int index) {
    final tabPath = MainAppTabHelper.getTabPath(index);
    context.go(tabPath);
  }
}