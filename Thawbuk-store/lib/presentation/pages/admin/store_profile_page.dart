import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../widgets/shared/custom_text_field.dart';
import '../../widgets/shared/custom_button.dart';
import '../../widgets/shared/loading_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/user_entity.dart';

class StoreProfilePage extends StatefulWidget {
  const StoreProfilePage({Key? key}) : super(key: key);

  @override
  State<StoreProfilePage> createState() => _StoreProfilePageState();
}

class _StoreProfilePageState extends State<StoreProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers للمعلومات الشخصية
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  
  // Controllers للعنوان الشخصي
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  
  // Controllers لمعلومات الشركة
  final _companyNameController = TextEditingController();
  final _companyDescriptionController = TextEditingController();
  final _companyPhoneController = TextEditingController();
  final _companyStreetController = TextEditingController();
  final _companyCityController = TextEditingController();
  
  // Controllers لروابط التواصل
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _whatsappController = TextEditingController();
  
  Gender? _selectedGender;
  UserEntity? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUser = authState.user;
      _populateFields();
    }
  }

  void _populateFields() {
    if (_currentUser == null) return;
    
    // معلومات شخصية
    _nameController.text = _currentUser!.name ;
    _emailController.text = _currentUser!.email;
    _ageController.text = _currentUser!.age?.toString() ?? '';
    _selectedGender = _currentUser!.gender;
    
    // العنوان الشخصي
    if (_currentUser!.address != null) {
      _streetController.text = _currentUser!.address!.street;
      _cityController.text = _currentUser!.address!.city;
    }
    
    // معلومات الشركة
    if (_currentUser!.company != null) {
      final company = _currentUser!.company!;
      _companyNameController.text = company.name;
      _companyDescriptionController.text = company.description ?? '';
      _companyStreetController.text = company.address;
      // Note: CompanyEntity doesn't have phone and social links in current structure
      // These will be empty for now
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _companyNameController.dispose();
    _companyDescriptionController.dispose();
    _companyPhoneController.dispose();
    _companyStreetController.dispose();
    _companyCityController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي للمتجر'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin/dashboard'),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تحديث الملف الشخصي بنجاح'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthLoading) {
              return const LoadingWidget();
            }
            
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // المعلومات الشخصية
                    _buildSectionHeader('المعلومات الشخصية'),
                    _buildPersonalInfoSection(),
                    
                    const SizedBox(height: 32),
                    
                    // معلومات الشركة/المتجر
                    _buildSectionHeader('معلومات المتجر'),
                    _buildCompanyInfoSection(),
                    
                    const SizedBox(height: 32),
                    
                    // روابط التواصل الاجتماعي
                    _buildSectionHeader('روابط التواصل الاجتماعي'),
                    _buildSocialLinksSection(),
                    
                    const SizedBox(height: 32),
                    
                    // أزرار الحفظ والإلغاء
                    _buildActionButtons(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(
              controller: _nameController,
              label: 'الاسم',
              prefixIcon: const Icon(Icons.person),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال الاسم';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _emailController,
              label: 'البريد الإلكتروني',
              prefixIcon: const Icon(Icons.email),
              keyboardType: TextInputType.emailAddress,
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
            
            Row(
              children: [
                Expanded(
                  child: CustomTextField(
                    controller: _ageController,
                    label: 'العمر',
                    prefixIcon: const Icon(Icons.cake),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<Gender>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'الجنس',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: Gender.male, child: Text('ذكر')),
                      DropdownMenuItem(value: Gender.female, child: Text('أنثى')),
                      DropdownMenuItem(value: Gender.other, child: Text('آخر')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // العنوان الشخصي
            Text(
              'العنوان الشخصي',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            
            CustomTextField(
              controller: _streetController,
              label: 'الشارع',
              prefixIcon: const Icon(Icons.location_on),
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _cityController,
              label: 'المدينة',
              prefixIcon: const Icon(Icons.location_city),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompanyInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(
              controller: _companyNameController,
              label: 'اسم المتجر',
              prefixIcon: const Icon(Icons.store),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال اسم المتجر';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _companyDescriptionController,
              label: 'وصف المتجر',
              prefixIcon: const Icon(Icons.description),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _companyPhoneController,
              label: 'رقم هاتف المتجر',
              prefixIcon: const Icon(Icons.phone),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال رقم الهاتف';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // عنوان المتجر
            Text(
              'عنوان المتجر',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            
            CustomTextField(
              controller: _companyStreetController,
              label: 'شارع المتجر',
              prefixIcon: const Icon(Icons.location_on),
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _companyCityController,
              label: 'مدينة المتجر',
              prefixIcon: const Icon(Icons.location_city),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLinksSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(
              controller: _facebookController,
              label: 'رابط فيسبوك',
              prefixIcon: const Icon(Icons.facebook),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _instagramController,
              label: 'رابط إنستغرام',
              prefixIcon: const Icon(Icons.camera_alt),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),
            
            CustomTextField(
              controller: _whatsappController,
              label: 'رقم واتساب',
              prefixIcon: const Icon(Icons.message),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'حفظ التغييرات',
            onPressed: _saveProfile,
            isOutlined: false,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: CustomButton(
            text: 'إلغاء',
            onPressed: () => context.go('/admin/dashboard'),
            isOutlined: true,
          ),
        ),
      ],
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // بناء البيانات للإرسال
      final userData = <String, dynamic>{};
      
      // المعلومات الشخصية
      if (_nameController.text.isNotEmpty) {
        userData['name'] = _nameController.text;
      }
      if (_emailController.text.isNotEmpty) {
        userData['email'] = _emailController.text;
      }
      if (_ageController.text.isNotEmpty) {
        userData['age'] = int.tryParse(_ageController.text);
      }
      if (_selectedGender != null) {
        userData['gender'] = _selectedGender!.name;
      }
      
      // العنوان الشخصي
      if (_streetController.text.isNotEmpty || _cityController.text.isNotEmpty) {
        userData['address'] = {
          'street': _streetController.text,
          'city': _cityController.text,
        };
      }
      
      // معلومات الشركة
      if (_companyNameController.text.isNotEmpty) {
        final companyDetails = <String, dynamic>{
          'companyName': _companyNameController.text,
        };
        
        if (_companyDescriptionController.text.isNotEmpty) {
          companyDetails['companyDescription'] = _companyDescriptionController.text;
        }
        
        if (_companyPhoneController.text.isNotEmpty) {
          companyDetails['companyPhone'] = _companyPhoneController.text;
        }
        
        // عنوان الشركة
        if (_companyStreetController.text.isNotEmpty || _companyCityController.text.isNotEmpty) {
          companyDetails['companyAddress'] = {
            'street': _companyStreetController.text,
            'city': _companyCityController.text,
          };
        }
        
        // روابط التواصل
        final socialLinks = <String, dynamic>{};
        if (_facebookController.text.isNotEmpty) {
          socialLinks['facebook'] = _facebookController.text;
        }
        if (_instagramController.text.isNotEmpty) {
          socialLinks['instagram'] = _instagramController.text;
        }
        if (_whatsappController.text.isNotEmpty) {
          socialLinks['whatsapp'] = _whatsappController.text;
        }
        
        if (socialLinks.isNotEmpty) {
          companyDetails['socialLinks'] = socialLinks;
        }
        
        userData['companyDetails'] = companyDetails;
      }
      
      // إرسال البيانات
      context.read<AuthBloc>().add(UpdateUserProfileEvent(userData: userData));
    }
  }
}