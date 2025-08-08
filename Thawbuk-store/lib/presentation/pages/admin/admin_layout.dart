import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/navigation_helper.dart';
import '../../../core/navigation/navigation_service.dart';
import 'admin_dashboard_page.dart';
import 'admin_products_page.dart';
import 'add_product_page.dart';
import 'all_products_page.dart';
import 'admin_profile_page.dart';

class AdminLayout extends StatefulWidget {
  final int initialIndex;
  
  const AdminLayout({
    Key? key,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
  
  // Static method للوصول للـ state من أي مكان
  static _AdminLayoutState? of(BuildContext context) {
    return context.findAncestorStateOfType<_AdminLayoutState>();
  }
}

class _AdminLayoutState extends State<AdminLayout> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
  
  // Public method للوصول من خارج الـ widget
  void navigateToTab(int index) {
    _onItemTapped(index);
  }
  
  // معالجة زر الرجوع
  Future<bool> _onWillPop() async {
    // إذا كان في الصفحة الرئيسية (Dashboard)، اعرض dialog تأكيد
    if (_currentIndex == 0) {
      return await _showExitDialog() ?? false;
    }
    
    // إذا كان في صفحة أخرى، ارجع للـ Dashboard
    _onItemTapped(0);
    return false;
  }
  
  // عرض dialog تأكيد الخروج
  Future<bool?> _showExitDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الخروج من لوحة التحكم'),
        content: const Text('هل تريد الخروج من لوحة التحكم والعودة للمتجر؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              context.go('/home');
            },
            child: const Text('العودة للمتجر'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated || !authState.user.isOwner) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'غير مصرح لك بالوصول لهذه الصفحة',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('العودة للرئيسية'),
                  ),
                ],
              ),
            ),
          );
        }

        return WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
            appBar: _buildAppBar(context, authState.user),
            drawer: _buildDrawer(context, authState.user),
            body: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: const [
                AdminDashboardPage(),
                AdminProductsPage(),
                AddProductPage(),
                AllProductsPage(),
                AdminProfilePage(),
              ],
            ),
            bottomNavigationBar: _buildBottomNavigationBar(),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, user) {
    final titles = [
      'لوحة التحكم',
      'إدارة المنتجات',
      'إضافة منتج',
      'جميع المنتجات',
      'الملف الشخصي',
    ];

    return AppBar(
      title: Text(titles[_currentIndex]),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // TODO: تنفيذ الإشعارات
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'profile':
                context.go('/profile');
                break;
              case 'settings':
                context.go('/settings');
                break;
              case 'logout':
                _showLogoutDialog(context);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person_outline),
                  SizedBox(width: 8),
                  Text('الملف الشخصي'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings_outlined),
                  SizedBox(width: 8),
                  Text('الإعدادات'),
                ],
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: AppColors.error),
                  SizedBox(width: 8),
                  Text('تسجيل الخروج', style: TextStyle(color: AppColors.error)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context, user) {
    return Drawer(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.white,
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 30,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'مدير المتجر',
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(
                  icon: Icons.dashboard_outlined,
                  title: 'لوحة التحكم',
                  isSelected: _currentIndex == 0,
                  onTap: () {
                    Navigator.pop(context);
                    _onItemTapped(0);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.inventory_outlined,
                  title: 'إدارة المنتجات',
                  isSelected: _currentIndex == 1,
                  onTap: () {
                    Navigator.pop(context);
                    _onItemTapped(1);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.add_box_outlined,
                  title: 'إضافة منتج',
                  isSelected: _currentIndex == 2,
                  onTap: () {
                    Navigator.pop(context);
                    _onItemTapped(2);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.store_outlined,
                  title: 'جميع المنتجات',
                  isSelected: _currentIndex == 3,
                  onTap: () {
                    Navigator.pop(context);
                    _onItemTapped(3);
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.analytics_outlined,
                  title: 'إحصائيات المنتجات',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to products analytics page
                    context.nav.pushProductAnalytics();
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.favorite_outline,
                  title: 'إحصائيات المفضلة',
                  onTap: () {
                    Navigator.pop(context);
                    // Show favorites statistics dialog
                    _showFavoritesStatsDialog(context);
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.home_outlined,
                  title: 'عرض المتجر',
                  onTap: () {
                    Navigator.pop(context);
                    // عرض dialog تأكيد للخروج من لوحة التحكم
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('عرض المتجر'),
                        content: const Text('هل تريد الخروج من لوحة التحكم وعرض المتجر؟'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('إلغاء'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.go('/home');
                            },
                            child: const Text('عرض المتجر'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.person_outline,
                  title: 'الملف الشخصي',
                  isSelected: _currentIndex == 4,
                  onTap: () {
                    Navigator.pop(context);
                    _onItemTapped(4);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'إعدادات المتجر',
                  onTap: () {
                    Navigator.pop(context);
                    _showStoreSettingsDialog(context);
                  },
                ),
              ],
            ),
          ),
          
          // Logout
          Container(
            padding: const EdgeInsets.all(16),
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text(
                'تسجيل الخروج',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _showLogoutDialog(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppColors.primary : AppColors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.black,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primary.withOpacity(0.1),
      onTap: onTap,
    );
  }

  Widget _buildBottomNavigationBar() {
    // Only show bottom nav for main tabs (0, 1, 2)
    if (_currentIndex > 2) {
      return const SizedBox.shrink();
    }
    
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          activeIcon: Icon(Icons.dashboard),
          label: 'لوحة التحكم',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_outlined),
          activeIcon: Icon(Icons.inventory),
          label: 'منتجاتي',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_box_outlined),
          activeIcon: Icon(Icons.add_box),
          label: 'إضافة منتج',
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              NavigationHelper.logout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }

  void _showFavoritesStatsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إحصائيات المفضلة'),
        content: const Text('سيتم إضافة إحصائيات تفصيلية للمنتجات المفضلة قريباً'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _onItemTapped(0); // Go to dashboard to see favorites stats
            },
            child: const Text('عرض في لوحة التحكم'),
          ),
        ],
      ),
    );
  }

  void _showStoreSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إعدادات المتجر'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('معلومات المتجر'),
              subtitle: const Text('تعديل اسم ووصف المتجر'),
              onTap: () {
                Navigator.of(context).pop();
                _onItemTapped(4); // Go to profile page
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('إعدادات الإشعارات'),
              subtitle: const Text('إدارة إشعارات المتجر'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('سيتم إضافة إعدادات الإشعارات قريباً')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('الأمان والخصوصية'),
              subtitle: const Text('إعدادات الحساب والأمان'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('سيتم إضافة إعدادات الأمان قريباً')),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}