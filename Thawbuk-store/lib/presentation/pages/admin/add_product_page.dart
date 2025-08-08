import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thawbuk_store/core/navigation/navigation_service.dart';
import '../../bloc/admin/admin_bloc.dart';
import '../../widgets/shared/custom_button.dart';
import '../../widgets/shared/custom_text_field.dart';
import '../../widgets/shared/custom_card.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../bloc/category/category_bloc.dart';
import '../../bloc/category/category_event.dart';
import '../../bloc/category/category_state.dart';
import '../../../domain/entities/product_entity.dart';

class AddProductPage extends StatefulWidget {
  final ProductEntity? product;
  const AddProductPage({Key? key, this.product}) : super(key: key);

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  bool get _isEditMode => widget.product != null;
  
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
  
  // For edit mode - existing images
  final List<String> _existingImages = [];

  // Available options
  final List<String> _sizes = ['صغير', 'متوسط', 'كبير', 'كبير جداً'];
  final List<String> _predefinedColors = ['أبيض', 'أسود', 'أزرق', 'أحمر', 'أخضر', 'بني', 'رمادي', 'أصفر', 'بنفسجي', 'وردي', 'برتقالي', 'فضي', 'ذهبي'];
  final TextEditingController _customColorController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _nameArController.dispose();
    _descriptionController.dispose();
    _descriptionArController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _customColorController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(GetCategoriesEvent());
    if (_isEditMode) {
      _nameController.text = widget.product!.name;
      _nameArController.text = widget.product!.nameAr ?? '';
      _descriptionController.text = widget.product!.description ?? '';
      _descriptionArController.text = widget.product!.descriptionAr ?? '';
      _priceController.text = widget.product!.price.toString();
      _quantityController.text = widget.product!.stock.toString();
      _selectedCategory = widget.product!.categoryId;
      _selectedSizes.addAll(widget.product!.sizes ?? []);
      _selectedColors.addAll(widget.product!.colors ?? []);
      
      // Load existing images
      if (widget.product!.images.isNotEmpty) {
        _existingImages.addAll(widget.product!.images);
      } else if (widget.product!.mainImage.isNotEmpty) {
        _existingImages.add(widget.product!.mainImage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _resetForm,
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.refresh, color: AppColors.white),
        tooltip: 'إعادة تعيين',
      ),
      body: BlocListener<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is ProductCreated || state is ProductUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isEditMode ? 'تم تعديل المنتج بنجاح' : 'تم إضافة المنتج بنجاح'),
                backgroundColor: AppColors.success,
              ),
            );
            
            // إعادة تعيين الحقول عند نجاح الإضافة (وليس التعديل)
            if (state is ProductCreated) {
              // تأخير قصير لإعطاء المستخدم وقت لرؤية رسالة النجاح
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  _resetForm();
                }
              });
            } else if (state is ProductUpdated) {
              // في حالة التعديل، الانتقال لصفحة منتجاتي
              // (البيانات ستُحدث تلقائياً من AdminBloc)
              NavigationService.instance.pushAdminProducts();
            }
          } else if (state is AdminError) {
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
          
          BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              if (state is CategoriesLoaded) {
                return DropdownButtonFormField<String>(
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
                  items: state.categories.map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Text(category.displayName),
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
                );
              }
              return const Center(child: CircularProgressIndicator());
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
          
          // الألوان المحددة مسبقاً
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _predefinedColors.map((color) {
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
          
          const SizedBox(height: 16),
          
          // إضافة لون مخصص
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _customColorController,
                  label: 'إضافة لون مخصص',
                  hint: 'مثال: أزرق فاتح، أخضر زيتوني',
                  prefixIcon: const Icon(Icons.palette),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _addCustomColor,
                child: const Text('إضافة'),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // عرض الألوان المخصصة المضافة
          if (_selectedColors.where((color) => !_predefinedColors.contains(color)).isNotEmpty) ...[
            const Text('الألوان المخصصة:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedColors
                  .where((color) => !_predefinedColors.contains(color))
                  .map((color) {
                return Chip(
                  label: Text(color),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() {
                      _selectedColors.remove(color);
                    });
                  },
                );
              }).toList(),
            ),
          ],
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
            text: _isEditMode ? 'إضافة صور جديدة' : 'إضافة صور',
            icon: Icons.photo_camera,
            onPressed: _selectImages,
          ),
          
          const SizedBox(height: 16),
          
          // عرض الصور الموجودة (في حالة التعديل)
          if (_isEditMode && _existingImages.isNotEmpty) ...[
            const Text('الصور الحالية:'),
            const SizedBox(height: 8),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _existingImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 100,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _existingImages[index],
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: AppColors.grey,
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 4,
                          left: 4,
                          child: GestureDetector(
                            onTap: () => _removeExistingImage(index),
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
                        // Badge لتمييز الصور الحالية
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'حالي',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
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
            const SizedBox(height: 16),
          ],
          
          // عرض الصور الجديدة المحددة
          if (_selectedImages.isNotEmpty) ...[
            Text(_isEditMode ? 'الصور الجديدة:' : 'الصور المحددة:'),
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
                      border: Border.all(color: AppColors.success, width: 2),
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
                            onTap: () => _removeNewImage(index),
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
                        // Badge لتمييز الصور الجديدة
                        if (_isEditMode)
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'جديد',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
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
          
          // تنبيه لحد الصور
          if ((_existingImages.length + _selectedImages.length) == 0) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.error.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'يجب إضافة صورة واحدة على الأقل',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if ((_existingImages.length + _selectedImages.length) >= 10) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: AppColors.warning, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'تم الوصول للحد الأقصى من الصور (10 صور)',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        return Column(
          children: [
            CustomButton(
              text: _isEditMode ? 'حفظ التعديلات' : 'إضافة المنتج',
              // isFullWidth: true,
              isLoading: state is AdminLoading,
              onPressed: state is AdminLoading ? null : _submitForm,
            ),
            
            const SizedBox(height: 12),
            
            CustomButton(
              text: 'إلغاء',isOutlined: true,
              // type: ButtonType.outline,
              // isFullWidth: true,
              onPressed: state is AdminLoading ? null : () => context.pop(),
            ),
          ],
        );
      },
    );
  }

  void _selectImages() async {
    // التحقق من عدد الصور الحالي
    final currentImagesCount = _existingImages.length + _selectedImages.length;
    if (currentImagesCount >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم الوصول للحد الأقصى من الصور (10 صور)'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (images.isNotEmpty) {
        // التحقق من عدم تجاوز الحد الأقصى
        final remainingSlots = 10 - currentImagesCount;
        final imagesToAdd = images.take(remainingSlots).toList();
        
        setState(() {
          _selectedImages.addAll(imagesToAdd.map((xfile) => File(xfile.path)));
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم اختيار ${imagesToAdd.length} صورة'),
              backgroundColor: AppColors.success,
            ),
          );
          
          if (images.length > remainingSlots) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم تجاهل ${images.length - remainingSlots} صورة لتجاوز الحد الأقصى'),
                backgroundColor: AppColors.warning,
              ),
            );
          }
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في اختيار الصور: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حذف الصورة الجديدة'),
        backgroundColor: AppColors.info,
        duration: Duration(seconds: 1),
      ),
    );
  }
  
  void _removeExistingImage(int index) {
    setState(() {
      _existingImages.removeAt(index);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم حذف الصورة الحالية'),
        backgroundColor: AppColors.warning,
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'تراجع',
          onPressed: () {
            // TODO: يمكن تنفيذ ميزة التراجع لاحقاً
          },
        ),
      ),
    );
  }

  void _addCustomColor() {
    final colorName = _customColorController.text.trim();
    if (colorName.isNotEmpty && !_selectedColors.contains(colorName)) {
      setState(() {
        _selectedColors.add(colorName);
        _customColorController.clear();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إضافة اللون: $colorName'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (_selectedColors.contains(colorName)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('هذا اللون موجود بالفعل'),
          backgroundColor: AppColors.warning,
        ),
      );
    }
  }

  void _submitForm() {
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

      if (_selectedImages.isEmpty && _existingImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى اختيار صورة واحدة على الأقل'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      if (_isEditMode) {
        // في حالة التعديل، نحتاج لتمرير معلومات عن الصور الموجودة أيضاً
        context.read<AdminBloc>().add(
          UpdateProductEvent(
            productId: widget.product!.id,
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
            // TODO: إضافة معلومات الصور الموجودة إذا كانت مطلوبة في الbackend
            // existingImages: _existingImages,
          ),
        );
      } else {
        context.read<AdminBloc>().add(
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
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameController.clear();
    _nameArController.clear();
    _descriptionController.clear();
    _descriptionArController.clear();
    _priceController.clear();
    _quantityController.clear();
    _customColorController.clear();
    
    setState(() {
      _selectedCategory = null;
      _selectedSizes.clear();
      _selectedColors.clear();
      _selectedImages.clear();
      
      // في حالة التعديل، إعادة تحميل البيانات الأصلية
      if (_isEditMode) {
        _existingImages.clear();
        if (widget.product!.images.isNotEmpty) {
          _existingImages.addAll(widget.product!.images);
        } else if (widget.product!.mainImage.isNotEmpty) {
          _existingImages.add(widget.product!.mainImage);
        }
        
        _nameController.text = widget.product!.name;
        _nameArController.text = widget.product!.nameAr ?? '';
        _descriptionController.text = widget.product!.description ?? '';
        _descriptionArController.text = widget.product!.descriptionAr ?? '';
        _priceController.text = widget.product!.price.toString();
        _quantityController.text = widget.product!.stock.toString();
        _selectedCategory = widget.product!.categoryId;
        _selectedSizes.addAll(widget.product!.sizes ?? []);
        _selectedColors.addAll(widget.product!.colors ?? []);
      }
    });
    
    // رسالة تأكيد
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditMode ? 'تم إعادة تعيين البيانات للحالة الأصلية' : 'تم إعادة تعيين جميع الحقول'),
        backgroundColor: AppColors.info,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}