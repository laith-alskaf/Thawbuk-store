import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/product/product_bloc.dart';
import '../../bloc/cart/cart_bloc.dart';
import '../../widgets/shared/loading_widget.dart';
import '../../widgets/shared/error_widget.dart';
import '../../widgets/products/product_card.dart';
import '../../widgets/shared/custom_text_field.dart';
import '../../widgets/shared/network_aware_widget.dart';
import '../../widgets/shared/unified_app_bar.dart';
import '../../../core/navigation/navigation_helper.dart';

class ProductsPage extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;
  final String? searchQuery;

  const ProductsPage({
    super.key,
    this.categoryId,
    this.categoryName,
    this.searchQuery,
  });

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery ?? '';
    _loadProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadProducts() {
    if (widget.categoryId != null) {
      context.read<ProductBloc>().add(
        GetProductsByCategoryEvent(widget.categoryId!),
      );
    } else if (widget.searchQuery != null) {
      context.read<ProductBloc>().add(
        SearchProductsEvent(widget.searchQuery!),
      );
    } else {
      context.read<ProductBloc>().add(GetProductsEvent());
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Load more products if needed
      context.read<ProductBloc>().add(LoadMoreProductsEvent());
    }
  }

  void _onSearch(String query) {
    if (query.isNotEmpty) {
      context.read<ProductBloc>().add(SearchProductsEvent(query));
    } else {
      context.read<ProductBloc>().add(GetProductsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return NetworkAwareWidget(
      child: Scaffold(
        appBar: UnifiedAppBar(
          title: widget.categoryId != null
              ? (widget.categoryName ?? 'منتجات الفئة')
              : widget.searchQuery != null
                  ? 'نتائج البحث'
                  : 'المنتجات',
          customActions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              tooltip: 'الفلاتر',
              onPressed: () => _showFilterDialog(),
            ),
          ],
        ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomSearchField(
              controller: _searchController,
              hint: 'البحث عن المنتجات...',
              onChanged: _onSearch,
              onClear: () {
                _searchController.clear();
                context.read<ProductBloc>().add(GetProductsEvent());
              },
            ),
          ),
          
          // Products list
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading && state.products.isEmpty) {
                  return const LoadingWidget(message: 'جاري تحميل المنتجات...');
                }

                if (state is ProductError && state.products.isEmpty) {
                  return CustomErrorWidget(
                    message: state.message,
                    onRetry: _loadProducts,
                  );
                }

                if (state.products.isEmpty) {
                  return const EmptyStateWidget(
                    title: 'لا توجد منتجات',
                    message: 'لم يتم العثور على أي منتجات',
                    icon: Icons.shopping_bag_outlined,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _loadProducts();
                  },
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: state.products.length + 
                        (state is ProductLoading ? 2 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.products.length) {
                        return const ProductCardShimmer();
                      }
                      
                      final product = state.products[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                          // Navigate to product details
                          context.push('/app/product/${product.id}');
                        },
                        onAddToCart: () {
                          // التحقق من تسجيل الدخول قبل الإضافة للسلة
                          if (NavigationHelper.addToCart(context)) {
                            context.read<CartBloc>().add(
                                  AddToCartEvent(
                                    productId: product.id,
                                    quantity: 1,
                                  ),
                                );
                            NavigationHelper.showSuccessMessage(context, 'تم إضافة المنتج للسلة');
                          }
                        },
                        onToggleWishlist: () {
                          // التحقق من تسجيل الدخول قبل الإضافة للمفضلة
                          if (NavigationHelper.addToFavorites(context)) {
                            // Add to favorites logic here
                            NavigationHelper.showSuccessMessage(context, 'تم إضافة المنتج للمفضلة');
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      )));
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const ProductFilterSheet(),
    );
  }
}

class ProductFilterSheet extends StatefulWidget {
  const ProductFilterSheet({super.key});

  @override
  State<ProductFilterSheet> createState() => _ProductFilterSheetState();
}

class _ProductFilterSheetState extends State<ProductFilterSheet> {
  RangeValues _priceRange = const RangeValues(0, 1000);
  String? _selectedCategory;
  String _sortBy = 'newest';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'تصفية المنتجات',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Price range
          Text(
            'نطاق السعر',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          RangeSlider(
            values: _priceRange,
            min: 0,
            max: 1000,
            divisions: 20,
            labels: RangeLabels(
              '${_priceRange.start.round()} ر.س',
              '${_priceRange.end.round()} ر.س',
            ),
            onChanged: (values) {
              setState(() {
                _priceRange = values;
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          // Sort options
          Text(
            'ترتيب حسب',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            children: [
              ChoiceChip(
                label: const Text('الأحدث'),
                selected: _sortBy == 'newest',
                onSelected: (selected) {
                  setState(() {
                    _sortBy = 'newest';
                  });
                },
              ),
              ChoiceChip(
                label: const Text('السعر: من الأقل للأعلى'),
                selected: _sortBy == 'price_low',
                onSelected: (selected) {
                  setState(() {
                    _sortBy = 'price_low';
                  });
                },
              ),
              ChoiceChip(
                label: const Text('السعر: من الأعلى للأقل'),
                selected: _sortBy == 'price_high',
                onSelected: (selected) {
                  setState(() {
                    _sortBy = 'price_high';
                  });
                },
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Apply filters
                context.read<ProductBloc>().add(
                  FilterProductsEvent(
                    minPrice: _priceRange.start,
                    maxPrice: _priceRange.end,
                    sortBy: _sortBy,
                    category: _selectedCategory,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('تطبيق التصفية'),
            ),
          ),
        ],
      ),
      );
  }
}