import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../shared/custom_button.dart';

class FilterBottomSheet extends StatefulWidget {
  final List<String> selectedSizes;
  final List<String> selectedColors;
  final RangeValues priceRange;
  final bool inStockOnly;
  final Function(List<String>, List<String>, RangeValues, bool) onApplyFilters;

  const FilterBottomSheet({
    Key? key,
    required this.selectedSizes,
    required this.selectedColors,
    required this.priceRange,
    required this.inStockOnly,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  
  late List<String> _selectedSizes;
  late List<String> _selectedColors;
  late RangeValues _priceRange;
  late bool _inStockOnly;

  final List<String> _availableSizes = [
    'XS', 'S', 'M', 'L', 'XL', 'XXL', '36', '38', '40', '42', '44', '46'
  ];

  final List<String> _availableColors = [
    'أحمر', 'أزرق', 'أخضر', 'أصفر', 'بني', 'أسود', 'أبيض', 'رمادي', 'بنفسجي', 'وردي'
  ];

  @override
  void initState() {
    super.initState();
    
    _selectedSizes = List.from(widget.selectedSizes);
    _selectedColors = List.from(widget.selectedColors);
    _priceRange = widget.priceRange;
    _inStockOnly = widget.inStockOnly;
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, MediaQuery.of(context).size.height * _slideAnimation.value),
          child: _buildBottomSheet(),
        );
      },
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPriceFilter(),
                  const SizedBox(height: 24),
                  _buildSizeFilter(),
                  const SizedBox(height: 24),
                  _buildColorFilter(),
                  const SizedBox(height: 24),
                  _buildStockFilter(),
                ],
              ),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _closeBottomSheet,
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.lightGrey,
              foregroundColor: AppColors.darkGrey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'فلترة المنتجات',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: _resetFilters,
            child: Text(
              'إعادة تعيين',
              style: TextStyle(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('نطاق السعر', Icons.attach_money),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightGrey.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              RangeSlider(
                values: _priceRange,
                min: 0,
                max: 1000,
                divisions: 20,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.lightGrey,
                onChanged: (values) {
                  setState(() {
                    _priceRange = values;
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPriceChip('${_priceRange.start.round()} ريال'),
                  Text(
                    'إلى',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                  _buildPriceChip('${_priceRange.end.round()} ريال'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSizeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('الأحجام', Icons.straighten),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableSizes.map((size) {
            final isSelected = _selectedSizes.contains(size);
            return GestureDetector(
              onTap: () => _toggleSize(size),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.grey.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Text(
                  size,
                  style: TextStyle(
                    color: isSelected ? AppColors.white : AppColors.darkGrey,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('الألوان', Icons.palette),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _availableColors.map((color) {
            final isSelected = _selectedColors.contains(color);
            return GestureDetector(
              onTap: () => _toggleColor(color),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.secondary.withOpacity(0.1) : AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppColors.secondary : AppColors.grey.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _getColorFromName(color),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.grey.withOpacity(0.3),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      color,
                      style: TextStyle(
                        color: isSelected ? AppColors.secondary : AppColors.darkGrey,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStockFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('التوفر', Icons.inventory),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _inStockOnly ? AppColors.success.withOpacity(0.1) : AppColors.lightGrey.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _inStockOnly ? AppColors.success.withOpacity(0.3) : AppColors.grey.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Switch(
                value: _inStockOnly,
                onChanged: (value) {
                  setState(() {
                    _inStockOnly = value;
                  });
                },
                activeColor: AppColors.success,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المنتجات المتوفرة فقط',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'إظهار المنتجات المتوفرة في المخزون فقط',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.darkGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'إلغاء',
                isOutlined: true,
                onPressed: _closeBottomSheet,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: CustomButton(
                text: 'تطبيق الفلترة',
                onPressed: _applyFilters,
                icon: Icons.check,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Methods
  void _toggleSize(String size) {
    setState(() {
      if (_selectedSizes.contains(size)) {
        _selectedSizes.remove(size);
      } else {
        _selectedSizes.add(size);
      }
    });
  }

  void _toggleColor(String color) {
    setState(() {
      if (_selectedColors.contains(color)) {
        _selectedColors.remove(color);
      } else {
        _selectedColors.add(color);
      }
    });
  }

  void _resetFilters() {
    setState(() {
      _selectedSizes.clear();
      _selectedColors.clear();
      _priceRange = const RangeValues(0, 1000);
      _inStockOnly = false;
    });
  }

  void _applyFilters() {
    widget.onApplyFilters(
      _selectedSizes,
      _selectedColors,
      _priceRange,
      _inStockOnly,
    );
    _closeBottomSheet();
  }

  void _closeBottomSheet() {
    Navigator.of(context).pop();
  }

  Color _getColorFromName(String colorName) {
    final colorMap = {
      'أحمر': Colors.red,
      'أزرق': Colors.blue,
      'أخضر': Colors.green,
      'أصفر': Colors.yellow,
      'بني': Colors.brown,
      'أسود': Colors.black,
      'أبيض': Colors.white,
      'رمادي': Colors.grey,
      'بنفسجي': Colors.purple,
      'وردي': Colors.pink,
    };
    
    return colorMap[colorName] ?? AppColors.primary;
  }
}