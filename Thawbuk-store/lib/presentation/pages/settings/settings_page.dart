import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/theme/theme_cubit.dart';
import '../../widgets/shared/custom_card.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import 'edit_profile_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.tune,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'الإعدادات',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.black,
        elevation: 1,
        shadowColor: Colors.grey.withOpacity(0.3),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'الحساب'),
            _buildAccountCard(context),
            const SizedBox(height: 24),

            _buildSectionTitle(context, 'التطبيق'),
            _buildAppSettingsCard(context),
            const SizedBox(height: 24),

            _buildSectionTitle(context, 'حول ودعم'),
            _buildAboutAndSupportCard(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, right: 8.0, left: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppColors.darkGrey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          // Optionally, show a disabled state or hide the card
          return const SizedBox.shrink();
        }
        return CustomCard(
          child: Column(
            children: [
              _buildSettingTile(
                context,
                'تعديل الملف الشخصي',
                'تغيير الاسم، البريد الإلكتروني...',
                Icons.person_outline,
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditProfilePage(user: state.user),
                    ),
                  );
                },
              ),
              const Divider(),
              _buildSettingTile(
                context,
                'تغيير كلمة المرور',
                'تحديث كلمة المرور الخاصة بك',
                Icons.lock_outline,
                () {
                  _showComingSoonSnackBar(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppSettingsCard(BuildContext context) {
    return CustomCard(
      child: Column(
        children: [
          // الوضع المظلم
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              return SwitchListTile(
                title: const Text('الوضع المظلم'),
                value: themeState.isDarkMode,
                onChanged: (value) {
                  context.read<ThemeCubit>().toggleTheme();
                },
                secondary: Icon(
                  themeState.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: AppColors.primary,
                ),
                contentPadding: EdgeInsets.zero,
              );
            },
          ),
          
          const Divider(),
          
          // الإشعارات
          _buildSettingTile(
            context,
            'الإشعارات',
            'إدارة إشعارات التطبيق',
            Icons.notifications_outlined,
            () {
              _showComingSoonSnackBar(context);
            },
          ),
          
          const Divider(),
          
          // اللغة
          _buildSettingTile(
            context,
            'اللغة',
            'العربية',
            Icons.language_outlined,
            () {
              _showComingSoonSnackBar(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutAndSupportCard(BuildContext context) {
    return CustomCard(
      child: Column(
        children: [
          _buildSettingTile(
            context,
            'عن ثوبك',
            'معلومات عن التطبيق',
            Icons.info_outline,
            () => _showAboutDialog(context),
          ),
          const Divider(),
          _buildSettingTile(
            context,
            'سياسة الخصوصية',
            'كيف نتعامل مع بياناتك',
            Icons.privacy_tip_outlined,
            () => _showPrivacyDialog(context),
          ),
          const Divider(),
          _buildSettingTile(
            context,
            'شروط الاستخدام',
            'قواعد استخدام التطبيق',
            Icons.description_outlined,
            () => _showTermsDialog(context),
          ),
          const Divider(),
          _buildSettingTile(
            context,
            'تواصل مع المطور',
            'ليث الأسكف', // Placeholder
            Icons.code,
            () => _showSupportDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  // دوال إطلاق التطبيقات الخارجية
  void _launchWhatsApp(BuildContext context) async {
    const phoneNumber = '+963982055788';
    const message = 'مرحباً، أريد التواصل معك بخصوص تطبيق ثوبك';
    final url = Uri.parse('https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showErrorDialog(context, 'لا يمكن فتح واتس آب');
      }
    } catch (e) {
      _showErrorDialog(context, 'حدث خطأ أثناء فتح واتس آب');
    }
  }

  void _launchTelegram(BuildContext context) async {
    const username = 'Laith041';
    final url = Uri.parse('https://t.me/$username');
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showErrorDialog(context, 'لا يمكن فتح تليجرام');
      }
    } catch (e) {
      _showErrorDialog(context, 'حدث خطأ أثناء فتح تليجرام');
    }
  }

  void _launchEmail(BuildContext context) async {
    const email = 'laithalskaf@gmail.com';
    const subject = 'استفسار حول تطبيق ثوبك';
    const body = 'مرحباً ليث،\n\nأريد التواصل معك بخصوص تطبيق ثوبك.\n\nشكراً';
    
    final url = Uri.parse('mailto:$email?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}');
    
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        _showErrorDialog(context, 'لا يمكن فتح تطبيق البريد الإلكتروني');
      }
    } catch (e) {
      _showErrorDialog(context, 'حدث خطأ أثناء فتح البريد الإلكتروني');
    }
  }

  // دوال عرض الحوارات
  void _showComingSoonSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('هذه الميزة ستكون متاحة قريباً'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('مسح ذاكرة التخزين المؤقت'),
          content: const Text('هل أنت متأكد من مسح ذاكرة التخزين المؤقت؟\nسيتم إعادة تحميل البيانات في المرة القادمة.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم مسح ذاكرة التخزين المؤقت بنجاح'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text(
                'مسح',
                style: TextStyle(color: AppColors.primary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('سياسة الخصوصية'),
          content: const SingleChildScrollView(
            child: Text(
              'نحن في ثوبك نحترم خصوصيتك ونلتزم بحماية بياناتك الشخصية. '
              'يتم استخدام المعلومات التي تقدمها لنا لتحسين تجربة التسوق وتقديم أفضل خدمة.\n\n'
              'لا نشارك بياناتك الشخصية مع أطراف ثالثة دون موافقتك الصريحة.\n\n'
              'جميع المعاملات محمية بأحدث تقنيات الأمان والتشفير.',
              style: TextStyle(height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('موافق'),
            ),
          ],
        );
      },
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('الشروط والأحكام'),
          content: const SingleChildScrollView(
            child: Text(
              'مرحباً بك في تطبيق ثوبك. باستخدام هذا التطبيق فإنك توافق على الشروط والأحكام التالية:\n\n'
              '1. يجب استخدام التطبيق للأغراض الشخصية والقانونية فقط.\n'
              '2. جميع المنتجات متاحة حسب التوفر.\n'
              '3. نحتفظ بالحق في تعديل الأسعار دون إشعار مسبق.\n'
              '4. سياسة الاستبدال والإرجاع تطبق حسب شروط كل منتج.\n\n'
              'لمزيد من المعلومات، يرجى التواصل معنا.',
              style: TextStyle(height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('موافق'),
            ),
          ],
        );
      },
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('الدعم الفني'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('يمكنك التواصل معنا للدعم الفني من خلال:'),
              const SizedBox(height: 16),
              
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _launchWhatsApp(context);
                },
                icon: const Icon(Icons.phone, color: AppColors.success),
                label: const Text('واتس آب'),
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.zero,
                ),
              ),
              
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _launchTelegram(context);
                },
                icon: const Icon(Icons.telegram, color: AppColors.info),
                label: const Text('تليجرام'),
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.zero,
                ),
              ),
              
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _launchEmail(context);
                },
                icon: const Icon(Icons.email, color: AppColors.error),
                label: const Text('البريد الإلكتروني'),
                style: TextButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('خطأ'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('موافق'),
            ),
          ],
        );
      },
    );
  }
}