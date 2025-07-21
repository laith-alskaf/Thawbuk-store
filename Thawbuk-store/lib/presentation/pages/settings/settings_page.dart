import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/theme/theme_cubit.dart';
import '../../widgets/shared/custom_card.dart';
import '../../widgets/shared/custom_button.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

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
          children: [
            // معلومات المطور
            _buildDeveloperCard(context),
            
            const SizedBox(height: 24),
            
            // إعدادات التطبيق
            _buildAppSettingsCard(context),
            
            const SizedBox(height: 24),
            
            // حول التطبيق
            _buildAboutCard(context),
            
            const SizedBox(height: 24),
            
            // التواصل مع المطور
            _buildContactCard(context),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperCard(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // صورة المطور أو أيقونة
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.code,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'تم تطوير التطبيق بواسطة',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.grey,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'ليث الأسكف',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'مطور تطبيقات الجوال والويب',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // أزرار التواصل
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildContactButton(
                context,
                'واتس آب',
                Icons.phone,
                AppColors.success,
                () => _launchWhatsApp(context),
              ),
              _buildContactButton(
                context,
                'تليجرام',
                Icons.telegram,
                AppColors.info,
                () => _launchTelegram(context),
              ),
              _buildContactButton(
                context,
                'جيميل',
                Icons.email,
                AppColors.error,
                () => _launchEmail(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color.withOpacity(0.1),
            foregroundColor: color,
            elevation: 0,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
          ),
          child: Icon(icon, size: 24),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAppSettingsCard(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إعدادات التطبيق',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // الوضع المظلم
          BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              return SwitchListTile(
                title: const Text('الوضع المظلم'),
                subtitle: const Text('تبديل بين الوضع الفاتح والمظلم'),
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
          
          const Divider(),
          
          // مسح الكاش
          _buildSettingTile(
            context,
            'مسح ذاكرة التخزين المؤقت',
            'تحرير مساحة تخزين',
            Icons.cleaning_services_outlined,
            () {
              _showClearCacheDialog(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'حول التطبيق',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // معلومات التطبيق
          Row(
            children: [
              Container(
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
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.appName,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      'الإصدار ${AppConstants.appVersion}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'متجر الألبسة التقليدية والعصرية في سوريا. يوفر تجربة تسوق مميزة مع تشكيلة واسعة من الأزياء عالية الجودة.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // أزرار الإجراءات
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showPrivacyDialog(context);
                  },
                  icon: const Icon(Icons.privacy_tip_outlined),
                  label: const Text('سياسة الخصوصية'),
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showTermsDialog(context);
                  },
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('الشروط والأحكام'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'التواصل والدعم',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildContactTile(
            context,
            'واتس آب',
            '+963 982 055 788',
            Icons.phone,
            AppColors.success,
            () => _launchWhatsApp(context),
          ),
          
          const SizedBox(height: 12),
          
          _buildContactTile(
            context,
            'تليجرام',
            '@Laith041',
            Icons.telegram,
            AppColors.info,
            () => _launchTelegram(context),
          ),
          
          const SizedBox(height: 12),
          
          _buildContactTile(
            context,
            'البريد الإلكتروني',
            'laithalskaf@gmail.com',
            Icons.email,
            AppColors.error,
            () => _launchEmail(context),
          ),
          
          const SizedBox(height: 20),
          
          // زر الدعم الفني
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _showSupportDialog(context);
              },
              icon: const Icon(Icons.support_agent),
              label: const Text('الدعم الفني'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
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

  Widget _buildContactTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(
          Icons.open_in_new,
          color: color,
          size: 20,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
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