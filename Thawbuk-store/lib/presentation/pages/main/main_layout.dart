import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thawbuk_store/presentation/pages/products/products_page.dart';

import '../../../core/navigation/navigation_helper.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../widgets/navigation/bottom_nav_bar.dart';
import '../home/home_page.dart';
import '../cart/cart_page.dart';
import '../favorites/favorites_page.dart';
import '../profile/profile_page.dart';

class MainLayout extends StatefulWidget {
  final int initialIndex;

  const MainLayout({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // معالجة تغييرات حالة التسجيل
        if (state is AuthUnauthenticated) {
          // عند تسجيل الخروج، العودة للصفحة الرئيسية
          if (_currentIndex > 1) { // إذا كان في صفحة محمية
            _onTabTapped(0); // العودة للرئيسية
          }
        } else if (state is AuthError) {
          NavigationHelper.handleNavigationError(context, state.message);
        }
      },
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: const [
            HomePage(),                    // 0 - الرئيسية (عامة)
            ProductsPage(),  // 1 - المنتجات (عامة)
            CartPage(),                    // 2 - السلة (محمية)
            FavoritesPage(),               // 3 - المفضلة (محمية)
            ProfilePage(),                 // 4 - الحساب (محمية)
          ],
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
        ),
      ),
    );
  }
}