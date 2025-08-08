import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/guards/auth_guard.dart';
import '../../../core/navigation/navigation_helper.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/cart/cart_bloc.dart';

/// AppBar موحد وثابت لجميع صفحات التطبيق
class UnifiedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? customActions;
  final bool showBackButton;
  final bool showCartIcon;
  final bool showProfileMenu;
  final VoidCallback? onBackPressed;

  const UnifiedAppBar({
    super.key,
    required this.title,
    this.customActions,
    this.showBackButton = false,
    this.showCartIcon = true,
    this.showProfileMenu = true,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          // Logo App
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.store,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // اسم الصفحة
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.black,
      elevation: 2,
      shadowColor: AppColors.grey.withValues(alpha: 0.3),
      centerTitle: false,
      leading: showBackButton 
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      automaticallyImplyLeading: showBackButton,
      actions: [
        // Custom Actions أولاً
        if (customActions != null) ...customActions!,
        
        // Cart Icon - يظهر للجميع لكن يعمل حسب الحالة
        if (showCartIcon) _buildCartIcon(context),
        
        // Profile Menu - يظهر للجميع لكن يختلف المحتوى
        if (showProfileMenu) _buildProfileMenu(context),
        
        const SizedBox(width: 8),
      ],
    );
  }

  /// أيقونة السلة مع العدد
  Widget _buildCartIcon(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        // عرض أيقونة السلة فقط للمستخدمين المسجلين
        if (authState is! AuthAuthenticated) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              tooltip: 'سلة التسوق',
              onPressed: () => NavigationHelper.goToCart(context),
            ),
          );
        }

        // للمستخدمين المسجلين - عرض العدد
        return BlocBuilder<CartBloc, CartState>(
          builder: (context, cartState) {
            int itemCount = 0;
            
            if (cartState is CartLoaded) {
              itemCount = cartState.cart.itemsCount;
            }

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Badge(
                label: Text(itemCount.toString()),
                isLabelVisible: itemCount > 0,
                child: IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  tooltip: 'سلة التسوق',
                  onPressed: () => NavigationHelper.goToCart(context),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// قائمة الملف الشخصي
  Widget _buildProfileMenu(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is AuthAuthenticated) {
          return _buildAuthenticatedMenu(context, authState);
        } else if (authState is AuthGuest) {
          return _buildGuestMenu(context);
        } else {
          return _buildAnonymousMenu(context);
        }
      },
    );
  }

  /// قائمة المستخدم المسجل
  Widget _buildAuthenticatedMenu(BuildContext context, AuthAuthenticated authState) {
    return PopupMenuButton<String>(
      icon: CircleAvatar(
        radius: 16,
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        child: authState.user.profileImage != null
            ? ClipOval(
                child: Image.network(
                  authState.user.profileImage!,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.person,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              )
            : const Icon(
                Icons.person,
                size: 18,
                color: AppColors.primary,
              ),
      ),
      tooltip: 'الملف الشخصي',
      onSelected: (value) => _handleMenuAction(context, value),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: _buildMenuItem(Icons.person_outline, 'الملف الشخصي'),
        ),
        PopupMenuItem(
          value: 'orders',
          child: _buildMenuItem(Icons.history, 'طلباتي'),
        ),
        PopupMenuItem(
          value: 'favorites',
          child: _buildMenuItem(Icons.favorite_outline, 'المفضلة'),
        ),
        const PopupMenuDivider(),
        if (authState.user.isOwner)
          PopupMenuItem(
            value: 'admin',
            child: _buildMenuItem(Icons.admin_panel_settings, 'لوحة الإدارة'),
          ),
        PopupMenuItem(
          value: 'settings',
          child: _buildMenuItem(Icons.settings_outlined, 'الإعدادات'),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: _buildMenuItem(
            Icons.logout,
            'تسجيل الخروج',
            color: AppColors.error,
          ),
        ),
      ],
    );
  }

  /// قائمة الزائر
  Widget _buildGuestMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const CircleAvatar(
        radius: 16,
        backgroundColor: AppColors.grey,
        child: Icon(
          Icons.person_outline,
          size: 18,
          color: AppColors.white,
        ),
      ),
      tooltip: 'خيارات الزائر',
      onSelected: (value) => _handleMenuAction(context, value),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'login',
          child: _buildMenuItem(Icons.login, 'تسجيل الدخول'),
        ),
        PopupMenuItem(
          value: 'register',
          child: _buildMenuItem(Icons.person_add, 'إنشاء حساب'),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'about',
          child: _buildMenuItem(Icons.info_outline, 'حول التطبيق'),
        ),
        PopupMenuItem(
          value: 'contact',
          child: _buildMenuItem(Icons.contact_support, 'اتصل بنا'),
        ),
      ],
    );
  }

  /// قائمة المستخدم غير المسجل
  Widget _buildAnonymousMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.person_outline),
      tooltip: 'خيارات الضيف',
      onSelected: (value) => _handleMenuAction(context, value),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'login',
          child: _buildMenuItem(Icons.login, 'تسجيل الدخول'),
        ),
        PopupMenuItem(
          value: 'register',
          child: _buildMenuItem(Icons.person_add, 'إنشاء حساب'),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'about',
          child: _buildMenuItem(Icons.info_outline, 'حول التطبيق'),
        ),
        PopupMenuItem(
          value: 'contact',
          child: _buildMenuItem(Icons.contact_support, 'اتصل بنا'),
        ),
      ],
    );
  }

  /// بناء عنصر القائمة
  Widget _buildMenuItem(IconData icon, String title, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? AppColors.grey),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            color: color ?? AppColors.black,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  /// معالجة أحداث القائمة
  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'profile':
        context.push('/app/profile');
        break;
      case 'orders':
        context.push('/app/orders');
        break;
      case 'favorites':
        context.push('/app/favorites');
        break;
      case 'admin':
        context.push('/admin/dashboard');
        break;
      case 'settings':
        context.push('/app/settings');
        break;
      case 'logout':
        _showLogoutDialog(context);
        break;
      case 'login':
        context.go('/auth/login');
        break;
      case 'register':
        context.go('/auth/register');
        break;
      case 'about':
        _showAboutDialog(context);
        break;
      case 'contact':
        _showContactInfo(context);
        break;
    }
  }

  /// حوار تسجيل الخروج
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(LogoutEvent());
              context.pushReplacement('/auth/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text(
              'تسجيل خروج',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// حوار حول التطبيق
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'ثوبك',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.store,
          color: AppColors.white,
          size: 30,
        ),
      ),
      children: const [
        Text(
          'متجر الألبسة التقليدية والعصرية في سوريا',
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Text(
          'تم تطوير هذا التطبيق لتوفير تجربة تسوق مميزة للألبسة التقليدية والعصرية.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// معلومات الاتصال
  void _showContactInfo(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('يمكنك التواصل معنا عبر البريد الإلكتروني: support@thawbuk.com'),
        backgroundColor: AppColors.info,
        duration: Duration(seconds: 4),
      ),
    );
  }
}