import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../widgets/shared/custom_card.dart';
import '../../widgets/shared/custom_button.dart';
import '../../widgets/shared/custom_app_bar.dart';
import '../../widgets/shared/custom_text_field.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({Key? key}) : super(key: key);

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _storeNameController = TextEditingController();
  final _storeDescriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  
  bool _isEditing = false;

  @override
  void dispose() {
    _storeNameController.dispose();
    _storeDescriptionController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'الملف الشخصي للمتجر',
        showBackButton: true,
        onBackPressed: () => context.pop(),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated || !authState.user.isOwner) {
            return const Center(
              child: Text('غير مصرح لك بالوصول لهذه الصفحة'),
            );
          }

          // تحديث الحقول ببيانات المستخدم
          if (!_isEditing) {
            _storeNameController.text = authState.user.name;
            _emailController.text = authState.user.email;
            _phoneController.text = authState.user.phone ?? '';
            // يمكن إضافة المزيد من البيانات حسب نموذج المستخدم
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // صورة المتجر ومعلومات أساسية
                  _buildStoreHeader(authState.user),
                  
                  const SizedBox(height: 24),
                  
                  // معلومات المتجر
                  _buildStoreInfo(),
                  
                  const SizedBox(height: 24),
                  
                  // معلومات الاتصال
                  _buildContactInfo(),
                  
                  const SizedBox(height: 24),
                  
                  // إحصائيات المتجر
                  _buildStoreStats(),
                  
                  const SizedBox(height: 24),
                  
                  // إعدادات سريعة
                  _buildQuickSettings(),
                  
                  const SizedBox(height: 32),
                  
                  // أزرار الإجراءات
                  if (_isEditing) _buildActionButtons(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoreHeader(user) {
    return CustomCard(
      child: Column(
        children: [
          // صورة المتجر
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.1),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: const Icon(
              Icons.store,
              size: 50,
              color: AppColors.primary,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // اسم المتجر
          Text(
            user.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // نوع الحساب
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'صاحب متجر',
              style: TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // تاريخ الانضمام
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today, size: 16, color: AppColors.grey),
              const SizedBox(width: 8),
              Text(
                'انضم في ${_formatDate(user.createdAt ?? DateTime.now())}',
                style: const TextStyle(color: AppColors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoreInfo() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.store_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'معلومات المتجر',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _storeNameController,
            label: 'اسم المتجر',
            enabled: _isEditing,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'يرجى إدخال اسم المتجر';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _storeDescriptionController,
            label: 'وصف المتجر',
            enabled: _isEditing,
            maxLines: 3,
            hint: 'اكتب وصفاً مختصراً عن متجرك...',
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.contact_phone_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'معلومات الاتصال',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _emailController,
            label: 'البريد الإلكتروني',
            enabled: false, // البريد الإلكتروني لا يمكن تغييره
            keyboardType: TextInputType.emailAddress,
          ),
          
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _phoneController,
            label: 'رقم الهاتف',
            enabled: _isEditing,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value != null && value.isNotEmpty && value.length < 10) {
                return 'يرجى إدخال رقم هاتف صحيح';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          CustomTextField(
            controller: _addressController,
            label: 'عنوان المتجر',
            enabled: _isEditing,
            maxLines: 2,
            hint: 'العنوان الكامل للمتجر...',
          ),
        ],
      ),
    );
  }

  Widget _buildStoreStats() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'إحصائيات المتجر',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem('المنتجات', '0', Icons.inventory),
              ),
              Expanded(
                child: _buildStatItem('المبيعات', '0', Icons.monetization_on),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem('المفضلة', '0', Icons.favorite),
              ),
              Expanded(
                child: _buildStatItem('التقييم', '0.0', Icons.star),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSettings() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.settings_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'إعدادات سريعة',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildSettingItem(
            'إعدادات المتجر',
            'تخصيص إعدادات المتجر والإشعارات',
            Icons.store_mall_directory,
            () => context.go('/admin/settings'),
          ),
          
          const Divider(),
          
          _buildSettingItem(
            'تغيير كلمة المرور',
            'تحديث كلمة مرور الحساب',
            Icons.lock_outline,
            () => _changePassword(),
          ),
          
          const Divider(),
          
          _buildSettingItem(
            'سياسة الخصوصية',
            'اطلع على سياسة الخصوصية',
            Icons.privacy_tip_outlined,
            () => _showPrivacyPolicy(),
          ),
          
          const Divider(),
          
          _buildSettingItem(
            'تسجيل الخروج',
            'تسجيل الخروج من الحساب',
            Icons.logout,
            () => _showLogoutDialog(),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppColors.error : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.grey),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'إلغاء',
            isOutlined: true,
            onPressed: () {
              setState(() {
                _isEditing = false;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            text: 'حفظ التغييرات',
            onPressed: _saveProfile,
          ),
        ),
      ],
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // TODO: حفظ بيانات المتجر
      setState(() {
        _isEditing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ التغييرات بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _changePassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('سيتم إضافة صفحة تغيير كلمة المرور قريباً')),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('سياسة الخصوصية'),
        content: const SingleChildScrollView(
          child: Text(
            'هنا ستكون سياسة الخصوصية الخاصة بالتطبيق...\n\n'
            'نحن نحترم خصوصيتك ونلتزم بحماية بياناتك الشخصية.\n\n'
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

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(LogoutEvent());
              context.go('/login');
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}