import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/guards/auth_guard.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../widgets/shared/unified_app_bar.dart';
import '../../widgets/shared/guest_access_widget.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (!AuthGuard.isAuthenticated(context)) {
          return _buildGuestView(context);
        }

        return Scaffold(
          appBar: const UnifiedAppBar(
            title: 'المفضلة',
          ),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 80,
                  color: AppColors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'لا توجد منتجات مفضلة',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppColors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'ابدأ بإضافة منتجات إلى قائمة المفضلة',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Scaffold(
      appBar: const UnifiedAppBar(
        title: 'المفضلة',
      ),
      body: GuestAccessWidget.favorites(),
    );
  }
}