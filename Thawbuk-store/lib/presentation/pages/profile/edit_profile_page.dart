import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user_entity.dart';
import '../../bloc/user/user_bloc.dart';
import '../../widgets/shared/custom_button.dart';
import '../../widgets/shared/custom_text_field.dart';
import '../../../core/theme/app_theme.dart';

class EditProfilePage extends StatefulWidget {
  final UserEntity user;

  const EditProfilePage({Key? key, required this.user}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  // Add controllers for other fields as needed, e.g., address, phone

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _handleUpdateProfile() {
    if (_formKey.currentState!.validate()) {
      final updatedData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        // Add other fields to the map
      };
      context.read<UserBloc>().add(UpdateUserProfile(updatedData));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل الملف الشخصي'),
      ),
      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is UserProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تحديث الملف الشخصي بنجاح'),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.of(context).pop();
          } else if (state is UserError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('خطأ في التحديث: ${state.message}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  controller: _nameController,
                  label: 'الاسم',
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال الاسم' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  label: 'البريد الإلكتروني',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value!.isEmpty ? 'الرجاء إدخال البريد الإلكتروني' : null,
                ),
                // Add other text fields for address, phone, etc.
                const SizedBox(height: 32),
                BlocBuilder<UserBloc, UserState>(
                  builder: (context, state) {
                    return CustomButton(
                      text: 'حفظ التغييرات',
                      isLoading: state is UserLoading,
                      onPressed: _handleUpdateProfile,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
