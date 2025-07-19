import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../widgets/shared/custom_button.dart';
import '../../widgets/shared/custom_text_field.dart';
import '../../widgets/shared/custom_card.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  UserRole _selectedRole = UserRole.customer;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              context.go('/home');
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              children: [
                const SizedBox(height: 40),
                
                // شعار التطبيق
                _buildLogo(),
                
                const SizedBox(height: 32),
                
                // بطاقة التسجيل
                CustomCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إنشاء حساب جديد',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // الاسم
                        CustomTextField(
                          label: 'الاسم الكامل',
                          hint: 'أدخل اسمك الكامل',
                          controller: _nameController,
                          prefixIcon: const Icon(Icons.person_outline),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'الاسم مطلوب';
                            }
                            if (value!.length < 3) {
                              return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // البريد الإلكتروني
                        CustomTextField(
                          label: 'البريد الإلكتروني',
                          hint: 'أدخل بريدك الإلكتروني',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'البريد الإلكتروني مطلوب';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                              return 'البريد الإلكتروني غير صحيح';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // رقم الهاتف
                        CustomTextField(
                          label: 'رقم الهاتف',
                          hint: 'أدخل رقم هاتفك',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Icons.phone_outlined),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'رقم الهاتف مطلوب';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // نوع الحساب
                        const Text(
                          'نوع الحساب',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.lightGrey,
                            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                          ),
                          child: Column(
                            children: [
                              RadioListTile<UserRole>(
                                title: const Text('عميل'),
                                subtitle: const Text('للتسوق وشراء المنتجات'),
                                value: UserRole.customer,
                                groupValue: _selectedRole,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedRole = value!;
                                  });
                                },
                              ),
                              RadioListTile<UserRole>(
                                title: const Text('صاحب متجر'),
                                subtitle: const Text('لإدارة المتجر وإضافة المنتجات'),
                                value: UserRole.owner,
                                groupValue: _selectedRole,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedRole = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // كلمة المرور
                        CustomTextField(
                          label: 'كلمة المرور',
                          hint: 'أدخل كلمة المرور',
                          controller: _passwordController,
                          obscureText: true,
                          prefixIcon: const Icon(Icons.lock_outline),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'كلمة المرور مطلوبة';
                            }
                            if (value!.length < 6) {
                              return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // تأكيد كلمة المرور
                        CustomTextField(
                          label: 'تأكيد كلمة المرور',
                          hint: 'أعد إدخال كلمة المرور',
                          controller: _confirmPasswordController,
                          obscureText: true,
                          prefixIcon: const Icon(Icons.lock_outline),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'تأكيد كلمة المرور مطلوب';
                            }
                            if (value != _passwordController.text) {
                              return 'كلمة المرور غير متطابقة';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // زر التسجيل
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return CustomButton(
                              text: 'إنشاء حساب',
                              isFullWidth: true,
                              isLoading: state is AuthLoading,
                              onPressed: state is AuthLoading ? null : _register,
                            );
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // رابط تسجيل الدخول
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('لديك حساب بالفعل؟ '),
                            TextButton(
                              onPressed: () => context.go('/login'),
                              child: const Text('سجل دخول'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.storefront,
            size: 40,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppConstants.appName,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'متجر الألبسة التقليدية والعصرية',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _register() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        RegisterEvent(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
          role: _selectedRole,
        ),
      );
    }
  }
}