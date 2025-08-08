import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/theme/theme_cubit.dart';
import '../../widgets/shared/custom_card.dart';
import '../../widgets/shared/custom_app_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({Key? key}) : super(key: key);

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _orderNotifications = true;
  bool _productNotifications = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'إعدادات المتجر',
        showBackButton: true,
        onBackPressed: () => context.pop(),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated || !authState.user.isOwner) {
            return const Center(
              child: Text('غير مصرح لك بالوصول لهذه الصفحة'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // إعدادات الإشعارات
                _buildNotificationSettings(),
                
                const SizedBox(height: 24),
                
                // إعدادات المظهر
                _buildAppearanceSettings(),
                
                const SizedBox(height: 24),
                
                // إعدادات المتجر
                _buildStoreSettings(),
                
                const SizedBox(height: 24),
                
                // إعدادات الحساب
                _buildAccountSettings(),
                
                const SizedBox(height: 24),
                
                // معلومات التطبيق
                _buildAppInfo(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'إعدادات الإشعارات',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildSwitchTile(
            'تفعيل الإشعارات',
            'استقبال إشعارات التطبيق',
            _notificationsEnabled,
            (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          
          const Divider(),
          
          _buildSwitchTile(
            'إشعارات البريد الإلكتروني',
            'استقبال إشعارات عبر البريد الإلكتروني',
            _emailNotifications,
            (value) {
              setState(() {
                _emailNotifications = value;
              });
            },
            enabled: _notificationsEnabled,
          ),
          
          const Divider(),
          
          _buildSwitchTile(
            'إشعارات الطلبات',
            'إشعار عند وصول طلبات جديدة',
            _orderNotifications,
            (value) {
              setState(() {
                _orderNotifications = value;
              });
            },
            enabled: _notificationsEnabled,
          ),
          
          const Divider(),
          
          _buildSwitchTile(
            'إشعارات المنتجات',
            'إشعار عند تفاعل العملاء مع المنتجات',
            _productNotifications,
            (value) {
              setState(() {
                _productNotifications = value;
              });
            },
            enabled: _notificationsEnabled,
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSettings() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.palette_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'إعدادات المظهر',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              return _buildSettingTile(
                'المظهر',
                themeState.isDarkMode ? 'المظهر الداكن' : 'المظهر الفاتح',
                Icons.brightness_6_outlined,
                () => _showThemeDialog(),
              );
            },
          ),
          
          const Divider(),
          
          _buildSettingTile(
            'اللغة',
            'العربية',
            Icons.language_outlined,
            () => _showLanguageDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreSettings() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.store_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'إعدادات المتجر',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildSettingTile(
            'معلومات المتجر',
            'تحديث معلومات المتجر الأساسية',
            Icons.info_outline,
            () => context.go('/admin/profile'),
          ),
          
          const Divider(),
          
          _buildSettingTile(
            'سياسة الإرجاع',
            'إدارة سياسة الإرجاع والاستبدال',
            Icons.assignment_return_outlined,
            () => _showReturnPolicyDialog(),
          ),
          
          const Divider(),
          
          _buildSettingTile(
            'طرق الدفع',
            'إدارة طرق الدفع المقبولة',
            Icons.payment_outlined,
            () => _showPaymentMethodsDialog(),
          ),
          
          const Divider(),
          
          _buildSettingTile(
            'الشحن والتوصيل',
            'إعدادات الشحن والتوصيل',
            Icons.local_shipping_outlined,
            () => _showShippingDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_circle_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'إعدادات الحساب',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildSettingTile(
            'تغيير كلمة المرور',
            'تحديث كلمة مرور الحساب',
            Icons.lock_outline,
            () => _changePassword(),
          ),
          
          const Divider(),
          
          _buildSettingTile(
            'الأمان والخصوصية',
            'إعدادات الأمان والخصوصية',
            Icons.security_outlined,
            () => _showSecurityDialog(),
          ),
          
          const Divider(),
          
          _buildSettingTile(
            'نسخ احتياطي للبيانات',
            'إنشاء نسخة احتياطية من بيانات المتجر',
            Icons.backup_outlined,
            () => _createBackup(),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfo() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'معلومات التطبيق',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildSettingTile(
            'الإصدار',
            '1.0.0',
            Icons.info,
            null,
          ),
          
          const Divider(),
          
          _buildSettingTile(
            'الشروط والأحكام',
            'اطلع على شروط الاستخدام',
            Icons.description_outlined,
            () => _showTermsDialog(),
          ),
          
          const Divider(),
          
          _buildSettingTile(
            'سياسة الخصوصية',
            'اطلع على سياسة الخصوصية',
            Icons.privacy_tip_outlined,
            () => _showPrivacyDialog(),
          ),
          
          const Divider(),
          
          _buildSettingTile(
            'تواصل معنا',
            'للدعم والاستفسارات',
            Icons.contact_support_outlined,
            () => _contactSupport(),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged, {
    bool enabled = true,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          color: enabled ? null : AppColors.grey,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: enabled ? AppColors.grey : AppColors.grey.withOpacity(0.5),
        ),
      ),
      trailing: Switch(
        value: enabled ? value : false,
        onChanged: enabled ? onChanged : null,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.grey),
      ),
      trailing: onTap != null
          ? const Icon(Icons.arrow_forward_ios, size: 16)
          : null,
      onTap: onTap,
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر المظهر'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('المظهر الفاتح'),
              leading: const Icon(Icons.light_mode),
              onTap: () {
                context.read<ThemeCubit>().setLightTheme();
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('المظهر الداكن'),
              leading: const Icon(Icons.dark_mode),
              onTap: () {
                context.read<ThemeCubit>().setDarkTheme();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم إضافة دعم اللغات المتعددة قريباً')),
    );
  }

  void _showReturnPolicyDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم إضافة إعدادات سياسة الإرجاع قريباً')),
    );
  }

  void _showPaymentMethodsDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم إضافة إعدادات طرق الدفع قريباً')),
    );
  }

  void _showShippingDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم إضافة إعدادات الشحن قريباً')),
    );
  }

  void _changePassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم إضافة صفحة تغيير كلمة المرور قريباً')),
    );
  }

  void _showSecurityDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم إضافة إعدادات الأمان قريباً')),
    );
  }

  void _createBackup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('نسخ احتياطي'),
        content: const Text('هل تريد إنشاء نسخة احتياطية من بيانات متجرك؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('سيتم إضافة النسخ الاحتياطي قريباً')),
              );
            },
            child: const Text('إنشاء'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الشروط والأحكام'),
        content: const SingleChildScrollView(
          child: Text(
            'هنا ستكون الشروط والأحكام الخاصة بالتطبيق...\n\n'
            '1. شروط الاستخدام\n'
            '2. حقوق والتزامات المستخدم\n'
            '3. سياسة المحتوى\n'
            '4. إخلاء المسؤولية\n\n'
            'لمزيد من المعلومات، يرجى زيارة موقعنا الإلكتروني.',
          ),
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

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('سياسة الخصوصية'),
        content: const SingleChildScrollView(
          child: Text(
            'هنا ستكون سياسة الخصوصية الخاصة بالتطبيق...\n\n'
            'نحن نحترم خصوصيتك ونلتزم بحماية بياناتك الشخصية.\n\n'
            '• جمع البيانات\n'
            '• استخدام البيانات\n'
            '• مشاركة البيانات\n'
            '• حماية البيانات\n\n'
            'لمزيد من المعلومات، يرجى زيارة موقعنا الإلكتروني.',
          ),
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

  void _contactSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تواصل معنا'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('يمكنك التواصل معنا عبر:'),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.email, color: AppColors.primary),
                SizedBox(width: 8),
                Text('support@thawbuk.com'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, color: AppColors.primary),
                SizedBox(width: 8),
                Text('+966 50 123 4567'),
              ],
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