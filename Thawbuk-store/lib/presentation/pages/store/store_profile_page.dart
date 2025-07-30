import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/store/store_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/store_profile_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../widgets/shared/custom_button.dart';
import '../../widgets/shared/loading_widget.dart';
import '../../widgets/shared/error_widget.dart';
import '../../widgets/products/product_card.dart';

class StoreProfilePage extends StatefulWidget {
  final String storeId;

  const StoreProfilePage({
    super.key,
    required this.storeId,
  });

  @override
  State<StoreProfilePage> createState() => _StoreProfilePageState();
}

class _StoreProfilePageState extends State<StoreProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<StoreBloc>().add(LoadStoreProfile(widget.storeId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<StoreBloc, StoreState>(
        builder: (context, state) {
          if (state is StoreLoading) {
            return const LoadingWidget();
          } else if (state is StoreError) {
            return CustomErrorWidget(
              message: state.message,
              onRetry: () => context.read<StoreBloc>().add(
                    LoadStoreProfile(widget.storeId),
                  ),
            );
          } else if (state is StoreProfileLoaded || state is StoreProductsLoaded) {
            final profile = state is StoreProfileLoaded
                ? state.profile
                : (state as StoreProductsLoaded).profile;
            
            return _buildStoreProfile(context, profile, state);
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStoreProfile(BuildContext context, StoreProfileEntity profile, StoreState state) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        _buildSliverAppBar(profile),
        SliverToBoxAdapter(
          child: Column(
            children: [
              _buildStoreHeader(profile),
              _buildStoreStats(profile),
              _buildTabBar(),
            ],
          ),
        ),
        _buildTabContent(profile, state),
      ],
    );
  }

  Widget _buildSliverAppBar(StoreProfileEntity profile) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: profile.hasCoverImage
            ? CachedNetworkImage(
                imageUrl: profile.coverImage!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.lightGrey,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.primary.withOpacity(0.1),
                  child: const Icon(
                    Icons.store,
                    size: 60,
                    color: AppColors.primary,
                  ),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.7),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.store,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
      ),
      actions: [
        IconButton(
          onPressed: () => _showShareOptions(profile),
          icon: const Icon(Icons.share, color: Colors.white),
        ),
        IconButton(
          onPressed: () => _showMoreOptions(profile),
          icon: const Icon(Icons.more_vert, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildStoreHeader(StoreProfileEntity profile) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          // Store Logo and Basic Info
          Row(
            children: [
              // Store Logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: profile.hasLogo
                      ? CachedNetworkImage(
                          imageUrl: profile.logo!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.lightGrey,
                            child: const Icon(Icons.store),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.primary.withOpacity(0.1),
                            child: const Icon(
                              Icons.store,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.primary.withOpacity(0.1),
                          child: const Icon(
                            Icons.store,
                            color: AppColors.primary,
                            size: 40,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Store Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            profile.name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (profile.isVerified)
                          const Icon(
                            Icons.verified,
                            color: AppColors.success,
                            size: 24,
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            profile.address.fullAddress,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${profile.displayRating} (${profile.reviewsCount} تقييم)',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'متابعة',
                  onPressed: () => _followStore(profile),
                  backgroundColor: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'تواصل',
                  onPressed: () => _contactStore(profile),
                  backgroundColor: AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoreStats(StoreProfileEntity profile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.inventory,
            label: 'المنتجات',
            value: profile.productsCount.toString(),
          ),
          _buildStatItem(
            icon: Icons.people,
            label: 'المتابعون',
            value: profile.followersCount.toString(),
          ),
          _buildStatItem(
            icon: Icons.access_time,
            label: 'وقت الرد',
            value: profile.stats.responseTimeText,
          ),
          _buildStatItem(
            icon: Icons.check_circle,
            label: 'معدل الإنجاز',
            value: profile.stats.completionRateText,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.grey,
        tabs: const [
          Tab(text: 'المنتجات'),
          Tab(text: 'حول المتجر'),
          Tab(text: 'التقييمات'),
        ],
      ),
    );
  }

  Widget _buildTabContent(StoreProfileEntity profile, StoreState state) {
    return SliverFillRemaining(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildProductsTab(profile, state),
          _buildAboutTab(profile),
          _buildReviewsTab(profile),
        ],
      ),
    );
  }

  Widget _buildProductsTab(StoreProfileEntity profile, StoreState state) {
    if (state is! StoreProductsLoaded) {
      // Load products when tab is first accessed
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<StoreBloc>().add(LoadStoreProducts(widget.storeId));
      });
      return const LoadingWidget();
    }

    final products = state.products;
    
    if (products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'لا توجد منتجات حالياً',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return ProductCard(
          product: products[index],
          onTap: () {
            // Navigate to product details
            context.go('/product/${products[index].id}');
          },
          onAddToCart: () {
            // Add to cart functionality
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم إضافة ${products[index].displayName} إلى السلة'),
                backgroundColor: AppColors.success,
              ),
            );
            // TODO: Implement actual cart functionality
            // context.read<CartBloc>().add(AddToCart(products[index]));
          },
          onToggleWishlist: () {
            // Toggle wishlist functionality
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('تم إضافة ${products[index].displayName} إلى المفضلة'),
                backgroundColor: AppColors.primary,
              ),
            );
            // TODO: Implement actual wishlist functionality
            // context.read<WishlistBloc>().add(ToggleWishlist(products[index]));
          },
        );
      },
    );
  }

  Widget _buildAboutTab(StoreProfileEntity profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (profile.hasDescription) ...[
            Text(
              'وصف المتجر',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              profile.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
          ],
          
          Text(
            'معلومات التواصل',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildContactInfo(profile),
          
          const SizedBox(height: 24),
          
          if (profile.socialLinks?.hasAnyLink == true) ...[
            Text(
              'وسائل التواصل الاجتماعي',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSocialLinks(profile.socialLinks!),
          ],
        ],
      ),
    );
  }

  Widget _buildContactInfo(StoreProfileEntity profile) {
    return Column(
      children: [
        _buildInfoRow(
          icon: Icons.email,
          label: 'البريد الإلكتروني',
          value: profile.email,
          onTap: () => _launchEmail(profile.email),
        ),
        if (profile.phone?.isNotEmpty == true)
          _buildInfoRow(
            icon: Icons.phone,
            label: 'رقم الهاتف',
            value: profile.phone!,
            onTap: () => _launchPhone(profile.phone!),
          ),
        _buildInfoRow(
          icon: Icons.location_on,
          label: 'العنوان',
          value: profile.address.fullAddress,
        ),
        _buildInfoRow(
          icon: Icons.calendar_today,
          label: 'انضم في',
          value: 'عام ${profile.joinedYear}',
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.grey,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLinks(StoreSocialLinksEntity socialLinks) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        if (socialLinks.website?.isNotEmpty == true)
          _buildSocialButton(
            icon: Icons.language,
            label: 'الموقع الإلكتروني',
            onTap: () => _launchUrl(socialLinks.website!),
          ),
        if (socialLinks.facebook?.isNotEmpty == true)
          _buildSocialButton(
            icon: Icons.facebook,
            label: 'فيسبوك',
            onTap: () => _launchUrl(socialLinks.facebook!),
          ),
        if (socialLinks.instagram?.isNotEmpty == true)
          _buildSocialButton(
            icon: Icons.camera_alt,
            label: 'إنستغرام',
            onTap: () => _launchUrl(socialLinks.instagram!),
          ),
        if (socialLinks.whatsapp?.isNotEmpty == true)
          _buildSocialButton(
            icon: Icons.message,
            label: 'واتساب',
            onTap: () => _launchUrl('https://wa.me/${socialLinks.whatsapp}'),
          ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightGrey),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsTab(StoreProfileEntity profile) {
    return const Center(
      child: Text(
        'التقييمات قيد التطوير',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  // Helper Methods
  void _followStore(StoreProfileEntity profile) {
    // TODO: Implement follow functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم متابعة المتجر')),
    );
  }

  void _contactStore(StoreProfileEntity profile) {
    if (profile.phone?.isNotEmpty == true) {
      _launchPhone(profile.phone!);
    } else {
      _launchEmail(profile.email);
    }
  }

  void _showShareOptions(StoreProfileEntity profile) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('مشاركة المتجر')),
    );
  }

  void _showMoreOptions(StoreProfileEntity profile) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('الإبلاغ عن المتجر'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement report functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('حظر المتجر'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement block functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}