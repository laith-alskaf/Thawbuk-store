import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/store_profile_entity.dart';

class StoreCard extends StatelessWidget {
  final StoreProfileEntity store;
  final bool showFullInfo;
  final VoidCallback? onTap;

  const StoreCard({
    super.key,
    required this.store,
    this.showFullInfo = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () => _navigateToStoreProfile(context),
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(color: AppColors.lightGrey),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: showFullInfo ? _buildFullInfo(context) : _buildCompactInfo(context),
      ),
    );
  }

  Widget _buildCompactInfo(BuildContext context) {
    return Row(
      children: [
        // Store Logo
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.lightGrey, width: 1),
          ),
          child: ClipOval(
            child: store.hasLogo
                ? CachedNetworkImage(
                    imageUrl: store.logo!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.lightGrey,
                      child: const Icon(Icons.store, size: 20),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.primary.withOpacity(0.1),
                      child: const Icon(
                        Icons.store,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  )
                : Container(
                    color: AppColors.primary.withOpacity(0.1),
                    child: const Icon(
                      Icons.store,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Store Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      store.name,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (store.isVerified)
                    const Icon(
                      Icons.verified,
                      color: AppColors.success,
                      size: 16,
                    ),
                ],
              ),
              
              const SizedBox(height: 2),
              
              Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 14,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    store.displayRating,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.location_on,
                    size: 14,
                    color: AppColors.grey,
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      store.address.city,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Arrow Icon
        Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.grey,
        ),
      ],
    );
  }

  Widget _buildFullInfo(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            // Store Logo
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.lightGrey, width: 2),
              ),
              child: ClipOval(
                child: store.hasLogo
                    ? CachedNetworkImage(
                        imageUrl: store.logo!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.lightGrey,
                          child: const Icon(Icons.store, size: 24),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.primary.withOpacity(0.1),
                          child: const Icon(
                            Icons.store,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                      )
                    : Container(
                        color: AppColors.primary.withOpacity(0.1),
                        child: const Icon(
                          Icons.store,
                          color: AppColors.primary,
                          size: 24,
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
                          store.name,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (store.isVerified)
                        const Icon(
                          Icons.verified,
                          color: AppColors.success,
                          size: 20,
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
                        '${store.displayRating} (${store.reviewsCount})',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 2),
                  
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
                          store.address.fullAddress,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        
        if (store.hasDescription) ...[
          const SizedBox(height: 12),
          Text(
            store.description!,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        
        const SizedBox(height: 12),
        
        // Stats Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatChip(
              icon: Icons.inventory,
              label: '${store.productsCount} منتج',
            ),
            _buildStatChip(
              icon: Icons.people,
              label: '${store.followersCount} متابع',
            ),
            _buildStatChip(
              icon: Icons.access_time,
              label: store.stats.responseTimeText,
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        // View Store Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _navigateToStoreProfile(context),
            icon: const Icon(Icons.store, size: 18),
            label: const Text('زيارة المتجر'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToStoreProfile(BuildContext context) {
    context.push('/store/${store.id}');
  }
}