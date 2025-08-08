import 'product_entity.dart';

class AdminDashboardStatsEntity {
  final int totalProducts;
  final int availableProducts;
  final int outOfStockProducts;
  final int totalFavorites;
  final double totalRevenue;
  final int totalOrders;
  final List<ProductEntity> topFavoriteProducts;
  final List<ProductEntity> recentProducts;
  final Map<String, int> categoryStats;

  const AdminDashboardStatsEntity({
    required this.totalProducts,
    required this.availableProducts,
    required this.outOfStockProducts,
    required this.totalFavorites,
    required this.totalRevenue,
    required this.totalOrders,
    required this.topFavoriteProducts,
    required this.recentProducts,
    required this.categoryStats,
  });

  AdminDashboardStatsEntity copyWith({
    int? totalProducts,
    int? availableProducts,
    int? outOfStockProducts,
    int? totalFavorites,
    double? totalRevenue,
    int? totalOrders,
    List<ProductEntity>? topFavoriteProducts,
    List<ProductEntity>? recentProducts,
    Map<String, int>? categoryStats,
  }) {
    return AdminDashboardStatsEntity(
      totalProducts: totalProducts ?? this.totalProducts,
      availableProducts: availableProducts ?? this.availableProducts,
      outOfStockProducts: outOfStockProducts ?? this.outOfStockProducts,
      totalFavorites: totalFavorites ?? this.totalFavorites,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalOrders: totalOrders ?? this.totalOrders,
      topFavoriteProducts: topFavoriteProducts ?? this.topFavoriteProducts,
      recentProducts: recentProducts ?? this.recentProducts,
      categoryStats: categoryStats ?? this.categoryStats,
    );
  }
}