import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:thawbuk_store/presentation/widgets/shared/error_widget.dart';
import '../../bloc/admin/admin_bloc.dart';
import '../../widgets/shared/custom_card.dart';
import '../../widgets/shared/loading_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/product_entity.dart';

class ProductsAnalyticsPage extends StatefulWidget {
  const ProductsAnalyticsPage({Key? key}) : super(key: key);

  @override
  State<ProductsAnalyticsPage> createState() => _ProductsAnalyticsPageState();
}

class _ProductsAnalyticsPageState extends State<ProductsAnalyticsPage> {
  @override
  void initState() {
    super.initState();
    // Load dashboard data which includes product statistics
    context.read<AdminBloc>().add(GetAdminDashboardDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إحصائيات المنتجات'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<AdminBloc>().add(GetAdminDashboardDataEvent());
        },
        child: BlocBuilder<AdminBloc, AdminState>(
          builder: (context, state) {
            if (state is AdminLoading) {
              return const LoadingWidget();
            }
            
            if (state is AdminError) {
              return CustomErrorWidget(
                message: state.message,
                onRetry: () {
                  context.read<AdminBloc>().add(GetAdminDashboardDataEvent());
                },
              );
            }
            
            if (state is AdminDashboardLoaded) {
              return _buildAnalyticsContent(state.stats);
            }
            
            return const Center(
              child: Text('لا توجد بيانات متاحة'),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnalyticsContent(stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        children: [
          // إحصائيات عامة
          _buildOverviewSection(stats),
          
          const SizedBox(height: 24),
          
          // المنتجات الأكثر إعجاباً
          _buildTopFavoriteProducts(stats.topFavoriteProducts ?? []),
          
          const SizedBox(height: 24),
          
          // أحدث المنتجات
          _buildRecentProducts(stats.recentProducts ?? []),
          
          const SizedBox(height: 24),
          
          // إحصائيات التصنيفات
          _buildCategoryStats(stats.categoryStats ?? {}),
          
          const SizedBox(height: 24),
          
          // تحليل المخزون
          _buildStockAnalysis(stats),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(stats) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'نظرة عامة',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'إجمالي المنتجات',
                  value: '${stats.totalProducts ?? 0}',
                  icon: Icons.inventory_2,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'المتوفرة',
                  value: '${stats.availableProducts ?? 0}',
                  icon: Icons.check_circle,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'غير متوفرة',
                  value: '${stats.outOfStockProducts ?? 0}',
                  icon: Icons.error,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'إجمالي الإعجابات',
                  value: '${stats.totalFavorites ?? 0}',
                  icon: Icons.favorite,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTopFavoriteProducts(List<ProductEntity> products) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, color: AppColors.error),
              const SizedBox(width: 8),
              Text(
                'المنتجات الأكثر إعجاباً',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ...products.take(5).map((product) => _buildProductTile(product)).toList(),
        ],
      ),
    );
  }

  Widget _buildRecentProducts(List<ProductEntity> products) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, color: AppColors.info),
              const SizedBox(width: 8),
              Text(
                'أحدث المنتجات',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ...products.take(5).map((product) => _buildProductTile(product)).toList(),
        ],
      ),
    );
  }

  Widget _buildProductTile(ProductEntity product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightGrey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // صورة المنتج
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.grey.withOpacity(0.2),
            ),
            child: product.mainImage.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.mainImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported, color: AppColors.grey);
                      },
                    ),
                  )
                : const Icon(Icons.image_not_supported, color: AppColors.grey),
          ),
          
          const SizedBox(width: 12),
          
          // معلومات المنتج
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.displayName,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${product.price.toStringAsFixed(0)} ل.س',
                      style:const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if ((product.favoritesCount ?? 0) > 0) ...[
                      const Icon(Icons.favorite, size: 14, color: AppColors.error),
                      const SizedBox(width: 2),
                      Text(
                        '${product.favoritesCount}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          // زر عرض المنتج
          IconButton(
            onPressed: () => context.push('/product/${product.id}'),
            icon: const Icon(Icons.visibility, color: AppColors.primary),
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryStats(Map<String, int> categoryStats) {
    if (categoryStats.isEmpty) {
      return const SizedBox.shrink();
    }

    // ترتيب التصنيفات حسب عدد المنتجات
    final sortedStats = categoryStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.category, color: AppColors.info),
              const SizedBox(width: 8),
              Text(
                'إحصائيات التصنيفات',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ...sortedStats.take(5).map((entry) {
            final total = categoryStats.values.fold(0, (sum, count) => sum + count);
            final percentage = total > 0 ? (entry.value / total) * 100 : 0.0;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      entry.key,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 3,
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: AppColors.grey.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStockAnalysis(stats) {
    // تحليل بسيط للمخزون بناءً على البيانات المتاحة
    final totalProducts = stats.totalProducts ?? 0;
    final availableProducts = stats.availableProducts ?? 0;
    final outOfStockProducts = stats.outOfStockProducts ?? 0;
    
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics, color: AppColors.warning),
              const SizedBox(width: 8),
              Text(
                'تحليل المخزون',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (totalProducts > 0) ...[
            // نسبة التوفر
            _buildStockIndicator(
              'معدل التوفر',
              '${((availableProducts / totalProducts) * 100).toStringAsFixed(1)}%',
              (availableProducts / totalProducts),
              availableProducts > (totalProducts * 0.8) 
                ? AppColors.success 
                : availableProducts > (totalProducts * 0.5)
                  ? AppColors.warning
                  : AppColors.error,
            ),
            
            const SizedBox(height: 16),
            
            // نسبة النفاد
            _buildStockIndicator(
              'معدل النفاد',
              '${((outOfStockProducts / totalProducts) * 100).toStringAsFixed(1)}%',
              (outOfStockProducts / totalProducts),
              outOfStockProducts < (totalProducts * 0.2) 
                ? AppColors.success 
                : outOfStockProducts < (totalProducts * 0.5)
                  ? AppColors.warning
                  : AppColors.error,
            ),
            
            const SizedBox(height: 16),
            
            // توصيات
            if (outOfStockProducts > (totalProducts * 0.3))
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'تنبيه: نسبة عالية من المنتجات غير متوفرة. يُنصح بإعادة تخزين المنتجات.',
                        style: TextStyle(
                          color: AppColors.warning.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ] else ...[
            const Center(
              child: Text(
                'لا توجد منتجات للتحليل',
                style: TextStyle(color: AppColors.grey),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStockIndicator(String title, String value, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.grey.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
      ],
    );
  }
}