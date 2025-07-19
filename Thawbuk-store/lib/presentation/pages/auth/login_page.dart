import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../widgets/shared/custom_button.dart';
import '../../widgets/shared/custom_text_field.dart';
import '../../widgets/shared/custom_card.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                const SizedBox(height: 60),
                
                // شعار التطبيق
                _buildLogo(),
                
                const SizedBox(height: 48),
                
                // بطاقة تسجيل الدخول
                CustomCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تسجيل الدخول',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        
                        const SizedBox(height: 24),
                        
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
                        
                        const SizedBox(height: 8),
                        
                        // نسيت كلمة المرور
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              // TODO: تنفيذ نسيان كلمة المرور
                            },
                            child: const Text('نسيت كلمة المرور؟'),
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // زر تسجيل الدخول
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return CustomButton(
                              text: 'تسجيل الدخول',
                              isFullWidth: true,
                              isLoading: state is AuthLoading,
                              onPressed: state is AuthLoading ? null : _login,
                            );
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // رابط التسجيل
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('ليس لديك حساب؟ '),
                            TextButton(
                              onPressed: () => context.go('/register'),
                              child: const Text('سجل الآن'),
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
      ],
    );
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
        LoginEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }
}