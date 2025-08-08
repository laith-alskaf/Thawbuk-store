import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/navigation_helper.dart';
import '../../../core/navigation/navigation_service.dart';
import 'admin_dashboard_page.dart';

class AdminLayoutImproved extends StatefulWidget {
  final Widget? child; // للصفحات الفرعية
  
  const AdminLayoutImproved({
    super.key,
    this.child,
  });

  @override
  State<AdminLayoutImproved> createState() => _AdminLayoutImprovedState();
  
  // Static method للوصول للـ state من أي مكان
  static _AdminLayoutImprovedState? of(BuildContext context) {
    return context.findAncestorStateOfType<_AdminLayoutImprovedState>();
  }
}

class _AdminLayoutImprovedState extends State<AdminLayoutImproved> {
  String _currentPageTitle = 'لوحة التحكم';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updatePageTitle();
  }

  void _updatePageTitle() {
    final currentRoute = GoRouterState.of(context).fullPath;
    setState(() {
      _currentPageTitle = _getTitleFromRoute(currentRoute);
    });
  }

  String _getTitleFromRoute(String? route) {
    switch (route) {
      case '/admin/dashboard':
        return 'لوحة التحكم';
      case '/admin/products':
        return 'منتجاتي';
      case '/admin/add-product':
        return 'إضافة منتج';
      case '/admin/all-products':
        return 'جميع المنتجات';
      case '/admin/profile':
        return 'الملف الشخصي';
      case '/admin/products-analytics':
        return 'إحصائيات المنتجات';
      case '/admin/edit-product':
        return 'تعديل منتج';
      case '/admin/store-profile':
        return 'ملف المتجر';
      case '/admin/settings':
        return 'الإعدادات';
      default:
        return 'لوحة التحكم';
    }
  }
  
  // معالجة زر الرجوع
  void _onWillPop() async {
    // إذا كان في صفحة فرعية، ارجع للـ Dashboard
    if (widget.child != null) {
      NavigationService.instance.goToAdminDashboard();
      return;
    }
    
    // إذا كان في Dashboard، اعرض dialog تأكيد
    final shouldExit = await _showExitDialog() ?? false;
    if (shouldExit) {
      context.go('/home');
    }
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

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              _onWillPop();
            }
          },
          child: Scaffold(
            appBar: _buildAppBar(context, authState.user),
            drawer: _buildDrawer(context, authState.user),
            body: widget.child ?? const AdminDashboardPage(), // Dashboard كـ default
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, user) {
    return AppBar(
      title: Text(_currentPageTitle),
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
                NavigationService.instance.pushAdminProfile();
                break;
              case 'settings':
                _showStoreSettingsDialog(context);
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
    final currentRoute = GoRouterState.of(context).fullPath;
    
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
                      color: AppColors.white.withValues(alpha: 0.8),
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
                  activeIcon: Icons.dashboard,
                  title: 'لوحة التحكم',
                  isSelected: currentRoute == '/admin' || currentRoute == '/admin/dashboard',
                  onTap: () {
                    Navigator.pop(context);
                    NavigationService.instance.goToAdminDashboard();
                  },
                ),
                const SizedBox(height: 8),
                _buildDrawerItem(
                  icon: Icons.inventory_outlined,
                  activeIcon: Icons.inventory,
                  title: 'منتجاتي',
                  isSelected: currentRoute?.contains('/admin/products') ?? false,
                  onTap: () {
                    Navigator.pop(context);
                    NavigationService.instance.pushAdminProducts();
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.add_box_outlined,
                  activeIcon: Icons.add_box,
                  title: 'إضافة منتج',
                  isSelected: currentRoute?.contains('/admin/add-product') ?? false,
                  onTap: () {
                    Navigator.pop(context);
                    NavigationService.instance.pushAddProduct();
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.store_outlined,
                  activeIcon: Icons.store,
                  title: 'جميع المنتجات',
                  isSelected: currentRoute?.contains('/admin/all-products') ?? false,
                  onTap: () {
                    Navigator.pop(context);
                    NavigationService.instance.pushAllProducts();
                  },
                ),
                const Divider(height: 32),
                _buildDrawerItem(
                  icon: Icons.analytics_outlined,
                  activeIcon: Icons.analytics,
                  title: 'إحصائيات المنتجات',
                  isSelected: currentRoute?.contains('/admin/analytics') ?? false,
                  onTap: () {
                    Navigator.pop(context);
                    NavigationService.instance.pushProductAnalytics();
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.favorite_outline,
                  activeIcon: Icons.favorite,
                  title: 'إحصائيات المفضلة',
                  onTap: () {
                    Navigator.pop(context);
                    _showFavoritesStatsDialog(context);
                  },
                ),
                const Divider(height: 32),
                _buildDrawerItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  title: 'عرض المتجر',
                  onTap: () {
                    Navigator.pop(context);
                    _showStoreViewDialog(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  title: 'الملف الشخصي',
                  isSelected: currentRoute?.contains('/admin/profile') ?? false,
                  onTap: () {
                    Navigator.pop(context);
                    NavigationService.instance.pushAdminProfile();
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
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
    IconData? activeIcon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: ListTile(
        leading: Icon(
          isSelected ? (activeIcon ?? icon) : icon,
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
        selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: onTap,
      ),
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
        title: const Row(
          children: [
            Icon(Icons.favorite, color: AppColors.primary),
            SizedBox(width: 8),
            Text('إحصائيات المفضلة'),
          ],
        ),
        content: const Text('سيتم إضافة إحصائيات تفصيلية للمنتجات المفضلة قريباً'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              NavigationService.instance.goToAdminDashboard();
            },
            child: const Text('عرض في لوحة التحكم'),
          ),
        ],
      ),
    );
  }

  void _showStoreViewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.store, color: AppColors.primary),
            SizedBox(width: 8),
            Text('عرض المتجر'),
          ],
        ),
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
  }

  void _showStoreSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.settings, color: AppColors.primary),
            SizedBox(width: 8),
            Text('إعدادات المتجر'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.store, color: AppColors.primary),
              title: const Text('معلومات المتجر'),
              subtitle: const Text('تعديل اسم ووصف المتجر'),
              onTap: () {
                Navigator.of(context).pop();
                NavigationService.instance.pushAdminProfile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications, color: AppColors.secondary),
              title: const Text('إعدادات الإشعارات'),
              subtitle: const Text('إدارة إشعارات المتجر'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('سيتم إضافة إعدادات الإشعارات قريباً'),
                    backgroundColor: AppColors.info,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.security, color: AppColors.warning),
              title: const Text('الأمان والخصوصية'),
              subtitle: const Text('إعدادات الحساب والأمان'),
              onTap: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('سيتم إضافة إعدادات الأمان قريباً'),
                    backgroundColor: AppColors.warning,
                  ),
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