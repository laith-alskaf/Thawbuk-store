import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/fcm_service.dart';
import '../../widgets/shared/custom_button.dart';
import '../../widgets/shared/custom_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _ageController = TextEditingController();
  
  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;
  String _selectedGender = 'male';
  String _selectedRole = 'customer';
  // Company fields
  final _companyNameController = TextEditingController();
  final _companyDescriptionController = TextEditingController();
  final _companyCityController = TextEditingController();
  final _companyStreetController = TextEditingController();
  final _companyCountryController = TextEditingController();
  final _companyPhoneController = TextEditingController();
  
  // Customer fields
  final _customerCityController = TextEditingController();
  final _customerStreetController = TextEditingController();
  
  // Additional state
  File? _companyLogo;
  final List<Map<String, dynamic>> _children = [];
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    _companyNameController.dispose();
    _companyDescriptionController.dispose();
    _companyCityController.dispose();
    _companyStreetController.dispose();
    _companyCountryController.dispose();
    _companyPhoneController.dispose();
    _customerCityController.dispose();
    _customerStreetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب جديد'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthRegistrationSuccess) {
            context.go('/verify-email/${state.email}');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Text(
                    'إنشاء حساب في ثوبك',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'انضم إلينا واستمتع بأجمل الأزياء',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Name Field
                  CustomTextField(
                    controller: _nameController,
                    label: 'الاسم الكامل',
                    hint: 'أدخل اسمك الكامل',
                    prefixIcon: const Icon(Icons.account_circle), // أيقونة شخص أوضح
                    validator: (value) {
                      if (_selectedRole == 'customer') {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال الاسم';
                        }
                        if (value.length < 2) {
                          return 'الاسم يجب أن يكون حرفين على الأقل';
                        }
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Email Field
                  CustomTextField(
                    controller: _emailController,
                    label: 'البريد الإلكتروني',
                    hint: 'أدخل بريدك الإلكتروني',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.alternate_email), // أيقونة بريد إلكتروني أوضح
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال البريد الإلكتروني';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'الرجاء إدخال بريد إلكتروني صحيح';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Age Field
                  CustomTextField(
                    controller: _ageController,
                    label: 'العمر',
                    hint: 'أدخل عمرك',
                    keyboardType: TextInputType.number,
                    prefixIcon: const Icon(Icons.date_range), // أيقونة تاريخ أوضح من الكعكة
                    validator: (value) {
                      if (_selectedRole == 'customer') {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال العمر';
                        }
                        final age = int.tryParse(value);
                        if (age == null || age < 18 || age > 100) {
                          return 'يجب أن يكون العمر بين 18 و 100';
                        }
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Gender Selection
                  Text(
                    'الجنس',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('ذكر'),
                          value: 'male',
                          groupValue: _selectedGender,
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value!;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('أنثى'),
                          value: 'female',
                          groupValue: _selectedGender,
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Address Fields for Customer
                  if (_selectedRole == 'customer') ...[
                    CustomTextField(
                      controller: _customerCityController,
                      label: 'المدينة',
                      hint: 'أدخل مدينتك',
                      prefixIcon: const Icon(Icons.location_city),
                      validator: (value) {
                        if (_selectedRole == 'customer' && (value == null || value.isEmpty)) {
                          return 'الرجاء إدخال المدينة';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    CustomTextField(
                      controller: _customerStreetController,
                      label: 'الشارع (اختياري)',
                      hint: 'أدخل عنوان الشارع',
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                    const SizedBox(height: 16),
                    
                    // Children Section
                    _buildChildrenSection(),
                    const SizedBox(height: 16),
                  ],
                  
                  // Role Selection
                  Text(
                    'نوع الحساب',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('عميل'),
                          value: 'customer',
                          groupValue: _selectedRole,
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value!;
                              // مسح البيانات عند تغيير نوع الحساب
                              _clearFormData();
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('متجر'),
                          value: 'admin',
                          groupValue: _selectedRole,
                          onChanged: (value) {
                            setState(() {
                              _selectedRole = value!;
                              // مسح البيانات عند تغيير نوع الحساب
                              _clearFormData();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  if (_selectedRole == 'admin') ...[
                    const SizedBox(height: 16),
                    _buildCompanySection(),
                  ],

                  const SizedBox(height: 16),
                  
                  // Password Field
                  CustomTextField(
                    controller: _passwordController,
                    label: 'كلمة المرور',
                    hint: 'أدخل كلمة المرور',
                    obscureText: _isPasswordHidden,
                    prefixIcon: const Icon(Icons.key), // أيقونة مفتاح أوضح
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordHidden ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordHidden = !_isPasswordHidden;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال كلمة المرور';
                      }
                      if (value.length < 6) {
                        return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Confirm Password Field
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'تأكيد كلمة المرور',
                    hint: 'أعد إدخال كلمة المرور',
                    obscureText: _isConfirmPasswordHidden,
                    prefixIcon: const Icon(Icons.key), // أيقونة مفتاح أوضح
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordHidden ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء تأكيد كلمة المرور';
                      }
                      if (value != _passwordController.text) {
                        return 'كلمتا المرور غير متطابقتان';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Register Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      
                      return CustomButton(
                        text: 'إنشاء الحساب',
                        isLoading: isLoading,
                        onPressed: isLoading ? null : _handleRegister,
                      );
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'لديك حساب بالفعل؟ ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          'تسجيل الدخول',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      // الحصول على FCM Token
      final fcmService = FCMService();
      await fcmService.initialize();
      final fcmToken = fcmService.fcmToken;

      final userData = <String, dynamic>{
        'email': _emailController.text.trim(),
        'password': _passwordController.text,
        'role': _selectedRole,
      };

      // إضافة FCM Token إذا كان متوفراً
      if (fcmToken != null) {
        userData['fcmToken'] = fcmToken;
      }

      // إضافة البيانات المطلوبة حسب نوع الحساب
      if (_selectedRole == 'customer') {
        final addressData = <String, dynamic>{
          'city': _customerCityController.text.trim(),
        };
        
        // إضافة الشارع إذا تم إدخاله
        if (_customerStreetController.text.trim().isNotEmpty) {
          addressData['street'] = _customerStreetController.text.trim();
        }

        userData.addAll({
          'name': _nameController.text.trim(),
          'age': int.parse(_ageController.text),
          'gender': _selectedGender,
          'address': addressData,
        });

        // إضافة الأطفال إذا تم إدخالهم
        if (_children.isNotEmpty) {
          userData['children'] = _children;
        }
      } else if (_selectedRole == 'admin') {
        final companyAddressData = <String, dynamic>{
          'city': _companyCityController.text.trim(),
        };
        
        // إضافة الشارع والبلد إذا تم إدخالهما
        if (_companyStreetController.text.trim().isNotEmpty) {
          companyAddressData['street'] = _companyStreetController.text.trim();
        }
        if (_companyCountryController.text.trim().isNotEmpty) {
          companyAddressData['country'] = _companyCountryController.text.trim();
        }

        final companyDetailsData = <String, dynamic>{
          'companyName': _companyNameController.text.trim(),
          'companyAddress': companyAddressData,
        };

        // إضافة الوصف والهاتف إذا تم إدخالهما
        if (_companyDescriptionController.text.trim().isNotEmpty) {
          companyDetailsData['companyDescription'] = _companyDescriptionController.text.trim();
        }
        if (_companyPhoneController.text.trim().isNotEmpty) {
          companyDetailsData['companyPhone'] = _companyPhoneController.text.trim();
        }

        // TODO: رفع شعار الشركة إلى الخادم وإضافة الرابط
        if (_companyLogo != null) {
          // يجب إضافة خدمة رفع الصور هنا
          // companyDetailsData['companyLogo'] = uploadedImageUrl;
        }

        userData['companyDetails'] = companyDetailsData;
      }

      context.read<AuthBloc>().add(
        RegisterEvent(userData: userData),
      );
    }
  }

  /// مسح جميع بيانات النموذج
  void _clearFormData() {
    // Company fields
    _companyNameController.clear();
    _companyDescriptionController.clear();
    _companyCityController.clear();
    _companyStreetController.clear();
    _companyCountryController.clear();
    _companyPhoneController.clear();
    
    // Customer fields
    _customerCityController.clear();
    _customerStreetController.clear();
    
    // Additional data
    _companyLogo = null;
    _children.clear();
  }

  /// بناء قسم معلومات الشركة
  Widget _buildCompanySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'معلومات المتجر',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Company Name
        CustomTextField(
          controller: _companyNameController,
          label: 'اسم المتجر',
          hint: 'أدخل اسم المتجر',
          prefixIcon: const Icon(Icons.store),
          validator: (value) {
            if (_selectedRole == 'admin' && (value == null || value.isEmpty)) {
              return 'الرجاء إدخال اسم المتجر';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Company Description
        CustomTextField(
          controller: _companyDescriptionController,
          label: 'وصف المتجر (اختياري)',
          hint: 'أدخل وصف مختصر عن المتجر',
          prefixIcon: const Icon(Icons.description),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        
        // Company Phone
        CustomTextField(
          controller: _companyPhoneController,
          label: 'رقم هاتف المتجر (اختياري)',
          hint: 'أدخل رقم هاتف المتجر',
          prefixIcon: const Icon(Icons.phone),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        
        // Company Address Section
        Text(
          'عنوان المتجر',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        
        // Company City
        CustomTextField(
          controller: _companyCityController,
          label: 'مدينة المتجر',
          hint: 'أدخل مدينة المتجر',
          prefixIcon: const Icon(Icons.location_city),
          validator: (value) {
            if (_selectedRole == 'admin' && (value == null || value.isEmpty)) {
              return 'الرجاء إدخال مدينة المتجر';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        
        // Company Street
        CustomTextField(
          controller: _companyStreetController,
          label: 'الشارع (اختياري)',
          hint: 'أدخل عنوان الشارع',
          prefixIcon: const Icon(Icons.location_on),
        ),
        const SizedBox(height: 16),
        
        // Company Country
        CustomTextField(
          controller: _companyCountryController,
          label: 'البلد (اختياري)',
          hint: 'أدخل البلد',
          prefixIcon: const Icon(Icons.public),
        ),
        const SizedBox(height: 16),
        
        // Company Logo
        _buildCompanyLogoSection(),
      ],
    );
  }

  /// بناء قسم شعار الشركة
  Widget _buildCompanyLogoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'شعار المتجر (اختياري)',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        
        GestureDetector(
          onTap: _pickCompanyLogo,
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.lightGrey.withOpacity(0.3),
            ),
            child: _companyLogo != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _companyLogo!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 40,
                        color: AppColors.grey,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'اضغط لإضافة شعار المتجر',
                        style: TextStyle(
                          color: AppColors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        
        if (_companyLogo != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: _pickCompanyLogo,
                icon: const Icon(Icons.edit),
                label: const Text('تغيير الصورة'),
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _companyLogo = null;
                  });
                },
                icon: const Icon(Icons.delete, color: AppColors.error),
                label: const Text('حذف الصورة', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ],
      ],
    );
  }

  /// بناء قسم الأطفال
  Widget _buildChildrenSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'الأطفال (اختياري)',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton.icon(
              onPressed: _addChild,
              icon: const Icon(Icons.add),
              label: const Text('إضافة طفل'),
            ),
          ],
        ),
        
        if (_children.isNotEmpty) ...[
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _children.length,
            itemBuilder: (context, index) {
              return _buildChildItem(index);
            },
          ),
        ],
      ],
    );
  }

  /// بناء عنصر طفل
  Widget _buildChildItem(int index) {
    final child = _children[index];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الطفل ${index + 1}'),
                  const SizedBox(height: 4),
                  Text(
                    'العمر: ${child['age']} - الجنس: ${child['gender'] == 'male' ? 'ذكر' : 'أنثى'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => _removeChild(index),
              icon: const Icon(Icons.delete, color: AppColors.error),
            ),
          ],
        ),
      ),
    );
  }

  /// اختيار شعار الشركة
  Future<void> _pickCompanyLogo() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _companyLogo = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في اختيار الصورة: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// إضافة طفل
  void _addChild() {
    showDialog(
      context: context,
      builder: (context) => _ChildDialog(
        onAdd: (age, gender) {
          setState(() {
            _children.add({
              'age': age,
              'gender': gender,
            });
          });
        },
      ),
    );
  }

  /// حذف طفل
  void _removeChild(int index) {
    setState(() {
      _children.removeAt(index);
    });
  }
}

/// Dialog لإضافة طفل
class _ChildDialog extends StatefulWidget {
  final Function(int age, String gender) onAdd;

  const _ChildDialog({required this.onAdd});

  @override
  State<_ChildDialog> createState() => _ChildDialogState();
}

class _ChildDialogState extends State<_ChildDialog> {
  final _ageController = TextEditingController();
  String _selectedGender = 'male';

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة طفل'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            controller: _ageController,
            label: 'العمر',
            hint: 'أدخل عمر الطفل',
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'الرجاء إدخال العمر';
              }
              final age = int.tryParse(value);
              if (age == null || age < 0 || age > 18) {
                return 'العمر يجب أن يكون بين 0 و 18';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('ذكر'),
                  value: 'male',
                  groupValue: _selectedGender,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('أنثى'),
                  value: 'female',
                  groupValue: _selectedGender,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_ageController.text.isNotEmpty) {
              final age = int.tryParse(_ageController.text);
              if (age != null && age >= 0 && age <= 18) {
                widget.onAdd(age, _selectedGender);
                Navigator.of(context).pop();
              }
            }
          },
          child: const Text('إضافة'),
        ),
      ],
    );
  }
}
