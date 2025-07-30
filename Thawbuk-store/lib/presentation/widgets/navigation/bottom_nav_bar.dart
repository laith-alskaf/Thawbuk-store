import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/navigation/navigation_helper.dart';
import '../../../core/guards/auth_guard.dart';
import '../../bloc/auth/auth_bloc.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    context,
                    icon: Icons.home,
                    label: 'الرئيسية',
                    index: 0,
                    isPublic: true,
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.grid_view,
                    label: 'المنتجات',
                    index: 1,
                    isPublic: true,
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.shopping_bag,
                    label: 'السلة',
                    index: 2,
                    feature: 'cart',
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.favorite,
                    label: 'المفضلة',
                    index: 3,
                    feature: 'favorites',
                  ),
                  _buildNavItem(
                    context,
                    icon: Icons.person,
                    label: 'الحساب',
                    index: 4,
                    feature: 'profile',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    bool isPublic = false,
    String? feature,
  }) {
    final isSelected = currentIndex == index;
    final isAuthenticated = AuthGuard.isAuthenticated(context);

    return GestureDetector(
      onTap: () {
        if (isPublic) {
          // الصفحات العامة - يمكن للجميع الوصول إليها
          onTap(index);
        } else {
          // الصفحات المحمية - تحتاج تسجيل دخول
          if (isAuthenticated) {
            onTap(index);
          } else {
            // عرض popup للمستخدم غير المسجل
            AuthGuard.requireAuth(context, feature: feature);
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Icon(
                  icon,
                  color: isSelected 
                      ? AppColors.primary 
                      : (isPublic || isAuthenticated)
                          ? AppColors.grey
                          : AppColors.grey.withOpacity(0.5),
                  size: 24,
                ),
                // إضافة نقطة تحذيرية للصفحات المحمية للمستخدمين غير المسجلين
                if (!isPublic && !isAuthenticated)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected 
                    ? AppColors.primary 
                    : (isPublic || isAuthenticated)
                        ? AppColors.grey
                        : AppColors.grey.withOpacity(0.5),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}