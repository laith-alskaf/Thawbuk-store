import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/product/product_bloc.dart';
import '../../bloc/cart/cart_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/product_entity.dart';
import '../../widgets/shared/custom_text_field.dart';
import '../../widgets/shared/loading_widget.dart';
import '../../widgets/shared/error_widget.dart';
import '../../widgets/products/product_card.dart';
import '../../widgets/products/filter_bottom_sheet.dart';
import '../../widgets/products/sort_bottom_sheet.dart';

enum ViewMode { grid, list }
enum SortType { newest, oldest, priceAsc, priceDesc, rating }

class ProductsPage extends StatefulWidget {
  final String? category;
  
  const ProductsPage({
    Key? key,
    this.category,
  }) : super(key: key);

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage>
    with SingleTickerProviderStateMixin {
  
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showScrollToTop = false;
  
  ViewMode _viewMode = ViewMode.grid;
  SortType _sortType = SortType.newest;
  
  List<String> _selectedSizes = [];
  List<String> _selectedColors = [];
  RangeValues _priceRange = const RangeValues(0, 1000);
  bool _inStockOnly = false;
  
  String _searchQuery = '';
  List<ProductEntity> _products = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Listen to scroll changes
    _scrollController.addListener(_onScroll);
    
    print('ProductsPage initState - Category: ${widget.category}');
    _loadProducts();
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    print('Loading products - Category: ${widget.category}, Search: $_searchQuery, HasFilters: ${_hasActiveFilters()}');
    
    if (widget.category != null && _searchQuery.isEmpty && !_hasActiveFilters()) {
      // If we have a specific category and no search/filters, use category-specific endpoint
      print('Using GetProductsByCategoryEvent for category: ${widget.category}');
      context.read<ProductBloc>().add(
            GetProductsByCategoryEvent(widget.category!),
          );
    } else {
      // Otherwise use filtered products endpoint
      print('Using GetFilteredProductsEvent');
      context.read<ProductBloc>().add(
            GetFilteredProductsEvent(
              category: widget.category,
              searchQuery: _searchQuery,
              sizes: _selectedSizes,
              colors: _selectedColors,
              minPrice: _priceRange.start,
              maxPrice: _priceRange.end,
              sortBy: _sortType.toString().split('.').last,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildSearchAndFilters(),
            _buildProductsBody(),
          ],
        ),
      ),
      floatingActionButton: _buildScrollToTopFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(widget.category != null ? 'منتجات ${widget.category}' : 'جميع المنتجات'),
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(_viewMode == ViewMode.grid ? Icons.list : Icons.grid_view),
          onPressed: _toggleViewMode,
          tooltip: _viewMode == ViewMode.grid ? 'عرض قائمة' : 'عرض شبكة',
        ),
        IconButton(
          icon: const Icon(Icons.sort),
          onPressed: _showSortOptions,
          tooltip: 'ترتيب',
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          CustomTextField(
            controller: _searchController,
            hint: 'ابحث عن المنتجات...',
            prefixIcon: Icons.search,
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSearch,
                  )
                : null,
            onChanged: _onSearchChanged,
          ),
          
          const SizedBox(height: 12),
          
          // Filter Chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip(
                  'فلترة',
                  Icons.filter_list,
                  _hasActiveFilters(),
                  _showFilterOptions,
                ),
                const SizedBox(width: 8),
                if (_selectedSizes.isNotEmpty)
                  _buildActiveFilterChip('الأحجام: ${_selectedSizes.join(", ")}'),
                if (_selectedColors.isNotEmpty)
                  _buildActiveFilterChip('الألوان: ${_selectedColors.join(", ")}'),
                if (_inStockOnly)
                  _buildActiveFilterChip('متوفر فقط'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.lightGrey,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.grey.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppColors.white : AppColors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? AppColors.white : AppColors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilterChip(String label) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: _clearFilters,
            child: Icon(
              Icons.close,
              size: 14,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductsBody() {
    return Expanded(
      child: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductsLoaded) {
            setState(() {
              _products = state.products;
            });
          }
        },
        builder: (context, state) {
          if (state is ProductLoading) {
            return _viewMode == ViewMode.grid
                ? const GridLoadingWidget()
                : const ListLoadingWidget();
          } else if (state is ProductError) {
            return CustomErrorWidget(
              message: state.message,
              onRetry: _loadProducts,
            );
          } else if (state is ProductsLoaded) {
            if (state.products.isEmpty) {
              return const EmptyWidget(
                message: 'لم يتم العثور على منتجات تطابق البحث',
                icon: Icons.search_off,
              );
            }
            return _buildProductsList(state.products);
          }

          return const EmptyWidget(
            message: 'لا توجد منتجات',
            icon: Icons.inventory_2_outlined,
          );
        },
      ),
    );
  }

  Widget _buildProductsList(List<ProductEntity> products) {
    return RefreshIndicator(
      onRefresh: () async => _loadProducts(),
      child: _viewMode == ViewMode.grid
          ? _buildGridView(products)
          : _buildListView(products),
    );
  }

  Widget _buildGridView(List<ProductEntity> products) {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return Hero(
          tag: 'product-${products[index].id}',
          child: ProductCard(
            product: products[index],
            onTap: () => _navigateToProductDetail(products[index]),
            onAddToCart: () => _addToCart(products[index]),
            onToggleWishlist: () => _toggleWishlist(products[index]),
          ),
        );
      },
    );
  }

  Widget _buildListView(List<ProductEntity> products) {
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Hero(
          tag: 'product-${products[index].id}',
          child: ProductCard(
            product: products[index],
            isListView: true,
            onTap: () => _navigateToProductDetail(products[index]),
            onAddToCart: () => _addToCart(products[index]),
            onToggleWishlist: () => _toggleWishlist(products[index]),
          ),
        );
      },
    );
  }

  Widget? _buildScrollToTopFAB() {
    if (!_showScrollToTop) return null;
    
    return FloatingActionButton(
      mini: true,
      onPressed: _scrollToTop,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      child: const Icon(Icons.keyboard_arrow_up),
    );
  }

  // Helper Methods
  void _toggleViewMode() {
    setState(() {
      _viewMode = _viewMode == ViewMode.grid ? ViewMode.list : ViewMode.grid;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });

    // Debounce search
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchQuery == query) {
        _loadProducts();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
    _loadProducts();
  }

  bool _hasActiveFilters() {
    final hasFilters = _selectedSizes.isNotEmpty ||
           _selectedColors.isNotEmpty ||
           _inStockOnly ||
           _priceRange != const RangeValues(0, 1000);
    print('_hasActiveFilters: $hasFilters - Sizes: $_selectedSizes, Colors: $_selectedColors, InStock: $_inStockOnly, PriceRange: $_priceRange');
    return hasFilters;
  }

  void _clearFilters() {
    setState(() {
      _selectedSizes.clear();
      _selectedColors.clear();
      _priceRange = const RangeValues(0, 1000);
      _inStockOnly = false;
    });
    _loadProducts();
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        selectedSizes: _selectedSizes,
        selectedColors: _selectedColors,
        priceRange: _priceRange,
        inStockOnly: _inStockOnly,
        onApplyFilters: (sizes, colors, priceRange, inStock) {
          setState(() {
            _selectedSizes = sizes;
            _selectedColors = colors;
            _priceRange = priceRange;
            _inStockOnly = inStock;
          });
          _loadProducts();
        },
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SortBottomSheet(
        currentSort: _sortType,
        onSortSelected: (sortType) {
          setState(() {
            _sortType = sortType;
          });
          _loadProducts();
        },
      ),
    );
  }

  void _navigateToProductDetail(ProductEntity product) {
    context.push('/product/${product.id}');
  }

  void _addToCart(ProductEntity product) {
    context.read<CartBloc>().add(AddToCartEvent(
      productId: product.id,
      quantity: 1,
    ));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إضافة ${product.displayName} للسلة'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _toggleWishlist(ProductEntity product) {
    // TODO: Implement wishlist functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إضافة ${product.displayName} للمفضلة'),
        backgroundColor: AppColors.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _onScroll() {
    if (_scrollController.offset >= 200) {
      if (!_showScrollToTop) {
        setState(() {
          _showScrollToTop = true;
        });
      }
    } else {
      if (_showScrollToTop) {
        setState(() {
          _showScrollToTop = false;
        });
      }
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}
