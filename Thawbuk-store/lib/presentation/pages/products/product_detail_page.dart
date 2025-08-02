import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/product/product_bloc.dart';
import '../../bloc/store/store_bloc.dart';
import '../../../core/di/dependency_injection.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/shared/custom_button.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  @override
  void initState() {
    super.initState();
    // Dispatch the event to fetch the product details
    context.read<ProductBloc>().add(GetProductByIdEvent(widget.productId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المنتج'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 1,
      ),
      body: BlocProvider<StoreBloc>(
        create: (context) => getIt<StoreBloc>(),
        child: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
            if (state is ProductLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProductError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'حدث خطأ',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'إعادة المحاولة',
                      onPressed: () {
                        context
                            .read<ProductBloc>()
                            .add(GetProductByIdEvent(widget.productId));
                      },
                    )
                  ],
                ),
              );
            } else if (state is ProductLoaded) {
              return _ProductDetailsView(product: state.product);
            } else {
              // Initial state or unexpected state
              return const Center(child: Text('جاري تحميل المنتج...'));
            }
          },
        ),
      ),
    );
  }

}

class _ProductDetailsView extends StatefulWidget {
  final ProductEntity product;

  const _ProductDetailsView({required this.product});

  @override
  State<_ProductDetailsView> createState() => _ProductDetailsViewState();
}

class _ProductDetailsViewState extends State<_ProductDetailsView> {
  @override
  void initState() {
    super.initState();
    if (widget.product.createdBy != null) {
      context.read<StoreBloc>().add(LoadStoreProfile(widget.product.createdBy!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Carousel
          if (widget.product.images.isNotEmpty)
            CarouselSlider(
              options: CarouselOptions(
                height: 300,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 1.0,
              ),
              items: widget.product.images.map((imageUrl) {
                return Builder(
                  builder: (BuildContext context) {
                    return CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    );
                  },
                );
              }).toList(),
            )
          else
            Container(
              height: 300,
              color: AppColors.lightGrey,
              child: const Center(
                child: Icon(Icons.image_not_supported, size: 60, color: AppColors.grey),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  widget.product.displayName,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Price
                Text(
                  '${widget.product.price} ر.س',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Store Info Section
                _buildStoreInfoSection(),

                const SizedBox(height: 16),

                // Description
                Text(
                  'الوصف',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.product.displayDescription,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.darkGrey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Stock Status
                Row(
                  children: [
                    Text(
                      'الحالة: ',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.product.isAvailable ? 'متوفر' : 'غير متوفر',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: widget.product.isAvailable ? Colors.green : AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // As per user request, no "Add to Cart" button.
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreInfoSection() {
    return BlocBuilder<StoreBloc, StoreState>(
      builder: (context, state) {
        if (state is StoreLoading) {
          return const ListTile(
            leading: CircularProgressIndicator(),
            title: Text('جاري تحميل بيانات المتجر...'),
          );
        } else if (state is StoreProfileLoaded) {
          final store = state.profile;
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: store.hasLogo ? CachedNetworkImageProvider(store.logo!) : null,
                child: !store.hasLogo ? const Icon(Icons.store) : null,
              ),
              title: Text(store.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(store.address.fullAddress),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => context.push('/store/${store.id}'),
            ),
          );
        } else if (state is StoreError) {
          return ListTile(
            leading: const Icon(Icons.error, color: AppColors.error),
            title: const Text('تعذر تحميل بيانات المتجر'),
            subtitle: Text(state.message),
          );
        }
        return const SizedBox.shrink(); // Return empty space if no store info yet
      },
    );
  }
}
