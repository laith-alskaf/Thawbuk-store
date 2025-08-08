import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../widgets/shared/custom_card.dart';
import '../../widgets/shared/custom_button.dart';
import '../../widgets/shared/loading_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/shared/unified_app_bar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UnifiedAppBar(
        title: 'الملف الشخصي',
        showBackButton: true,
        customActions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'تعديل الملف الشخصي',
                  onPressed: () {
                    // TODO: تنفيذ تعديل الملف الشخصي
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('سيتم إضافة تعديل الملف الشخصي قريباً'),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const LoadingWidget();
          }
          
          if (state is AuthGuest) {
            return _buildGuestProfile(context);
          }
          
          if (state is! AuthAuthenticated) {
            return _buildGuestProfile(context);
          }
          
          return _buildProfileContent(context, state.user);
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          // بطاقة المعلومات الشخصية
          _buildUserInfoCard(context, user),
          
          const SizedBox(height: 24),
          
          // بطاقة الإحصائيات
          _buildStatsCard(context, user),
          
          const SizedBox(height: 24),
          
          // خيارات الملف الشخصي
          _buildProfileOptions(context, user),
          
          const SizedBox(height: 24),
          
          // إعدادات التطبيق
          _buildAppSettings(context),
          
          const SizedBox(height: 24),
          
          // زر تسجيل الخروج
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(BuildContext context, user) {
    return CustomCard(
      child: Column(
        children: [
          // صورة المستخدم
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: user.profileImage != null
              ? ClipOval(
                  child: Image.network(
                    user.profileImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultAvatar(user.name);
                    },
                  ),
                )
              : _buildDefaultAvatar(user.name),
          ),
          
          const SizedBox(height: 16),
          
          // اسم المستخدم
          Text(
            user.name,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // البريد الإلكتروني
          Text(
            user.email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.grey,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // نوع الحساب
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: user.isOwner 
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.isOwner ? 'صاحب متجر' : 'عميل',
              style: TextStyle(
                color: user.isOwner ? AppColors.primary : AppColors.secondary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          
          if (user.phone != null) ...[
            const SizedBox(height: 8),
            Text(
              user.phone!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, user) {
    if (!user.isOwner) {
      // إحصائيات العميل
      return CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إحصائياتي',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'الطلبات',
                    '0',
                    Icons.receipt_long,
                    AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'المفضلة',
                    '0',
                    Icons.favorite,
                    AppColors.secondary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'التقييمات',
                    '0',
                    Icons.star,
                    AppColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      // إحصائيات المالك
      return CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إحصائيات المتجر',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'المنتجات',
                    '0',
                    Icons.inventory,
                    AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'الطلبات',
                    '0',
                    Icons.shopping_bag,
                    AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'المبيعات',
                    '0 ل.س',
                    Icons.monetization_on,
                    AppColors.success,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'العملاء',
                    '0',
                    Icons.people,
                    AppColors.info,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  Widget _buildStatItem(BuildContext context, String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileOptions(BuildContext context, user) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'خيارات الملف الشخصي',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          
          _buildOptionTile(
            context,
            'تعديل المعلومات الشخصية',
            Icons.edit,
            () {
              // TODO: تنفيذ تعديل المعلومات
            },
          ),
          
          _buildOptionTile(
            context,
            'تغيير كلمة المرور',
            Icons.lock,
            () {
              // TODO: تنفيذ تغيير كلمة المرور
            },
          ),
          
          if (!user.isOwner) ...[
            _buildOptionTile(
              context,
              'عناوين التوصيل',
              Icons.location_on,
              () {
                // TODO: تنفيذ إدارة العناوين
              },
            ),
            
            _buildOptionTile(
              context,
              'المفضلة',
              Icons.favorite,
              () {
                // TODO: تنفيذ المفضلة
              },
            ),
          ],
          
          if (user.isOwner) ...[
            _buildOptionTile(
              context,
              'معلومات المتجر',
              Icons.store,
              () {
                // TODO: تنفيذ تعديل معلومات المتجر
              },
            ),
            
            _buildOptionTile(
              context,
              'التقارير',
              Icons.analytics,
              () {
                // TODO: تنفيذ التقارير
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAppSettings(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إعدادات التطبيق',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          
          _buildOptionTile(
            context,
            'الإشعارات',
            Icons.notifications,
            () {
              // TODO: تنفيذ إعدادات الإشعارات
            },
          ),
          
          _buildOptionTile(
            context,
            'اللغة',
            Icons.language,
            () {
              // TODO: تنفيذ تغيير اللغة
            },
          ),
          
          _buildOptionTile(
            context,
            'الوضع المظلم',
            Icons.dark_mode,
            () {
              // TODO: تنفيذ تبديل الوضع المظلم
            },
          ),
          
          _buildOptionTile(
            context,
            'الإعدادات',
            Icons.settings,
            () {
              context.push('/settings');
            },
          ),
          
          _buildOptionTile(
            context,
            'حول التطبيق',
            Icons.info,
            () {
              _showAboutDialog(context);
            },
          ),
          
          _buildOptionTile(
            context,
            'اتصل بنا',
            Icons.contact_support,
            () {
              // TODO: تنفيذ الاتصال
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return CustomButton(
      text: 'تسجيل الخروج',
      // type: ButtonType.outline,
      isOutlined: true,
      // isFullWidth: true,
      icon: Icons.logout,
      onPressed: () => _showLogoutDialog(context),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تسجيل الخروج'),
          content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(LogoutEvent());
                context.go('/login');
              },
              child: const Text(
                'تسجيل خروج',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.storefront,
          color: AppColors.white,
          size: 30,
        ),
      ),
      children: [
        const Text(
          'متجر الألبسة التقليدية والعصرية في سوريا',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          'تم تطوير هذا التطبيق لتوفير تجربة تسوق مميزة للألبسة التقليدية والعصرية.',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// واجهة خاصة للزوار
  Widget _buildGuestProfile(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          // أيقونة زائر
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.grey.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.grey.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person_outline,
              size: 60,
              color: AppColors.grey,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // رسالة ترحيب للزائر
          Text(
            'مرحباً زائرنا العزيز!',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          Text(
            'أنت تتصفح المتجر كزائر.\nسجل دخولك أو أنشئ حساباً جديداً للاستمتاع بالمزايا الحصرية!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.grey,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 40),
          
          // مزايا التسجيل
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.stars, color: AppColors.primary, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'مزايا التسجيل',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                _buildBenefitItem(Icons.favorite, 'إضافة المنتجات للمفضلة'),
                _buildBenefitItem(Icons.shopping_cart, 'حفظ عربة التسوق'),
                _buildBenefitItem(Icons.history, 'تتبع تاريخ الطلبات'),
                _buildBenefitItem(Icons.notifications, 'تلقي الإشعارات والعروض'),
                _buildBenefitItem(Icons.support_agent, 'دعم فني مخصص'),
                _buildBenefitItem(Icons.local_offer, 'خصومات وعروض حصرية'),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // أزرار العمل
          Column(
            children: [
              // زر إنشاء حساب
              CustomButton(
                text: 'إنشاء حساب جديد',
                icon: Icons.person_add,
                onPressed: () => context.push('/auth/register'),
              ),
              
              const SizedBox(height: 16),
              
              // زر تسجيل الدخول
              CustomButton(
                text: 'تسجيل الدخول',
                icon: Icons.login,
                isOutlined: true,
                onPressed: () => context.push('/auth/login'),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // إعدادات عامة للزائر
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الإعدادات العامة',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildOptionTile(
                  context,
                  'اللغة',
                  Icons.language,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('سيتم إضافة تغيير اللغة قريباً'),
                        backgroundColor: AppColors.info,
                      ),
                    );
                  },
                ),
                
                _buildOptionTile(
                  context,
                  'الوضع المظلم',
                  Icons.dark_mode,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('سيتم إضافة الوضع المظلم قريباً'),
                        backgroundColor: AppColors.info,
                      ),
                    );
                  },
                ),
                
                _buildOptionTile(
                  context,
                  'حول التطبيق',
                  Icons.info,
                  () => _showAboutDialog(context),
                ),
                
                _buildOptionTile(
                  context,
                  'اتصل بنا',
                  Icons.contact_support,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('يمكنك التواصل معنا عبر البريد الإلكتروني'),
                        backgroundColor: AppColors.info,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// عنصر ميزة في قائمة المزايا
  Widget _buildBenefitItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}