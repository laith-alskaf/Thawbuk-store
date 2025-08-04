import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/loading_overlay.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/localization/app_localizations.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetLink() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(ForgotPasswordEvent(
        email: _emailController.text.trim(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('استعادة كلمة المرور'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ForgotPasswordSent) {
            // إظهار رسالة نجاح
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: Text('تم الإرسال'),
                content: Text(
                  'تم إرسال رابط استعادة كلمة المرور إلى ${state.email}\n\nيرجى التحقق من بريدك الإلكتروني واتباع التعليمات.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      context.pop(); // إغلاق الحوار
                      context.go('/auth/login'); // العودة لتسجيل الدخول
                    },
                    child: Text('حسناً'),
                  ),
                ],
              ),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state is AuthLoading,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),

                      // الأيقونة والعنوان
                      _buildHeader(),

                      const SizedBox(height: 48),

                      // حقل البريد الإلكتروني
                      CustomTextField(
                        controller: _emailController,
                        labelText: context.l10n.email,
                        hintText: context.l10n.emailHint,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return context.l10n.emailRequired;
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return context.l10n.emailInvalid;
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      // زر الإرسال
                      CustomButton(
                        text: 'إرسال رابط الاستعادة',
                        onPressed: _sendResetLink,
                        isLoading: state is AuthLoading,
                      ),

                      const SizedBox(height: 24),

                      // رابط العودة لتسجيل الدخول
                      TextButton(
                        onPressed: () => context.go('/auth/login'),
                        child: Text(
                          'العودة لتسجيل الدخول',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // معلومات إضافية
                      _buildInfoCard(),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // الأيقونة
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.tertiary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.tertiary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.lock_reset_outlined,
            size: 40,
            color: AppColors.onTertiary,
          ),
        ),

        const SizedBox(height: 24),

        // العنوان
        Text(
          'نسيت كلمة المرور؟',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // الوصف
        Text(
          'لا تقلق! أدخل بريدك الإلكتروني وسنرسل لك رابط لإعادة تعيين كلمة المرور',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'معلومات مهمة',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• تحقق من صندوق البريد الوارد وصندوق الرسائل المزعجة\n'
            '• الرابط صالح لمدة 24 ساعة فقط\n'
            '• إذا لم تتلق الرسالة، تأكد من صحة البريد الإلكتروني',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
