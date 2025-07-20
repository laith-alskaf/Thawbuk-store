import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/product/product_bloc.dart';
import '../../widgets/shared/custom_button.dart';
import '../../widgets/shared/custom_text_field.dart';
import '../../widgets/shared/custom_card.dart';
import '../../widgets/shared/loading_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({Key? key}) : super(key: key);

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _nameArController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _descriptionArController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  
  // Selected values
  String? _selectedCategory;
  final List<String> _selectedSizes = [];
  final List<String> _selectedColors = [];
  final List<File> _selectedImages = [];

  // Available options
  final List<String> _categories = ['الثياب التقليدية', 'الثياب العصرية', 'الأحذية', 'الإكسسوارات'];
  final List<String> _sizes = ['صغير', 'متوسط', 'كبير', 'كبير جداً'];
  final List<String> _colors = ['أبيض', 'أسود', 'أزرق', 'أحمر', 'أخضر', 'بني', 'رمادي'];

  @override
  void dispose() {
    _nameController.dispose();
    _nameArController.dispose();
    _descriptionController.dispose();
    _descriptionArController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة منتج جديد'),
        actions: [
          TextButton(
            onPressed: _resetForm,
            child: const Text(
              'إعادة تعيين',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
      body: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم إضافة المنتج بنجاح'),
                backgroundColor: AppColors.success,
              ),
            );
            context.pop();
          } else if (state is ProductError) {
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // معلومات أساسية
                _buildBasicInfo(),
                
                const SizedBox(height: 24),
                
                // الوصف
                _buildDescription(),
                
                const SizedBox(height: 24),
                
                // السعر والكمية
                _buildPriceAndQuantity(),
                
                const SizedBox(height: 24),
                
                // الفئة
                _buildCategorySelection(),
                
                const SizedBox(height: 24),
                
                // الأحجام والألوان
                _buildSizesAndColors(),
                
                const SizedBox(height: 24),
                
                // الصور
                _buildImageSelection(),
                
                const SizedBox(height: 32),
                
                // أزرار التحكم
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'المعلومات الأساسية',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            label: 'اسم المنتج (بالعربية)',
            hint: 'أدخل اسم المنتج بالعربية',
            controller: _nameArController,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'اسم المنتج مطلوب';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          CustomTextField(
            label: 'اسم المنتج (بالإنجليزية)',
            hint: 'أدخل اسم المنتج بالإنجليزية',
            controller: _nameController,
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الوصف',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          
          CustomTextField(
            label: 'الوصف (بالعربية)',
            hint: 'أدخل وصف المنتج بالعربية',
            controller: _descriptionArController,
            maxLines: 3,
          ),
          
          const SizedBox(height: 16),
          
          CustomTextField(
            label: 'الوصف (بالإنجليزية)',
            hint: 'أدخل وصف المنتج بالإنجليزية',
            controller: _descriptionController,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceAndQuantity() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'السعر والكمية',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'السعر (ل.س)',
                  hint: '0',
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'السعر مطلوب';
                    }
                    if (double.tryParse(value!) == null) {
                      return 'سعر غير صحيح';
                    }
                    return null;
                  },
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: CustomTextField(
                  label: 'الكمية',
                  hint: '0',
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'الكمية مطلوبة';
                    }
                    if (int.tryParse(value!) == null) {
                      return 'كمية غير صحيحة';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الفئة',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.lightGrey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                borderSide: BorderSide.none,
              ),
              hintText: 'اختر الفئة',
            ),
            items: _categories.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'الفئة مطلوبة';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSizesAndColors() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الأحجام والألوان',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          
          // الأحجام
          const Text('الأحجام المتاحة:'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _sizes.map((size) {
              return FilterChip(
                label: Text(size),
                selected: _selectedSizes.contains(size),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSizes.add(size);
                    } else {
                      _selectedSizes.remove(size);
                    }
                  });
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: 16),
          
          // الألوان
          const Text('الألوان المتاحة:'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _colors.map((color) {
              return FilterChip(
                label: Text(color),
                selected: _selectedColors.contains(color),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedColors.add(color);
                    } else {
                      _selectedColors.remove(color);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSelection() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'صور المنتج',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          
          // زر إضافة صور
          CustomButton(
            text: 'إضافة صور',
            icon:  Icons.photo_camera,
            onPressed: _selectImages,
          ),
          
          const SizedBox(height: 16),
          
          // عرض الصور المحددة
          if (_selectedImages.isNotEmpty) ...[
            const Text('الصور المحددة:'),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.grey),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImages[index],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          left: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        return Column(
          children: [
            CustomButton(
              text: 'إضافة المنتج',
              // isFullWidth: true,
              isLoading: state is ProductLoading,
              onPressed: state is ProductLoading ? null : _addProduct,
            ),
            
            const SizedBox(height: 12),
            
            CustomButton(
              text: 'إلغاء',isOutlined: true,
              // type: ButtonType.outline,
              // isFullWidth: true,
              onPressed: state is ProductLoading ? null : () => context.pop(),
            ),
          ],
        );
      },
    );
  }

  void _selectImages() async {
    // TODO: تنفيذ اختيار الصور
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم إضافة اختيار الصور قريباً'),
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _addProduct() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedSizes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى اختيار حجم واحد على الأقل'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      if (_selectedColors.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى اختيار لون واحد على الأقل'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      context.read<ProductBloc>().add(
        CreateProductEvent(
          name: _nameController.text.trim(),
          nameAr: _nameArController.text.trim(),
          description: _descriptionController.text.trim(),
          descriptionAr: _descriptionArController.text.trim(),
          price: double.parse(_priceController.text),
          category: _selectedCategory!,
          sizes: _selectedSizes,
          colors: _selectedColors,
          quantity: int.parse(_quantityController.text),
          images: _selectedImages,
        ),
      );
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _nameArController.clear();
    _descriptionController.clear();
    _descriptionArController.clear();
    _priceController.clear();
    _quantityController.clear();
    
    setState(() {
      _selectedCategory = null;
      _selectedSizes.clear();
      _selectedColors.clear();
      _selectedImages.clear();
    });
  }
}