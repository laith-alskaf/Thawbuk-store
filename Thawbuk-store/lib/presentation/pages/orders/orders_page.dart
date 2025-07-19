import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../bloc/order/order_bloc.dart';
import '../../widgets/shared/custom_card.dart';
import '../../widgets/shared/loading_widget.dart';
import '../../widgets/shared/error_widget.dart';
import '../../widgets/shared/custom_button.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<OrderBloc>().add(GetOrdersEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طلباتي'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الحالية'),
            Tab(text: 'المكتملة'),
            Tab(text: 'الملغية'),
          ],
        ),
      ),
      body: BlocConsumer<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is OrderLoading) {
            return const LoadingWidget(message: 'جاري تحميل الطلبات...');
          }
          
          if (state is OrderError) {
            return CustomErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<OrderBloc>().add(GetOrdersEvent());
              },
            );
          }
          
          if (state is OrdersLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList(_getCurrentOrders(state.orders)),
                _buildOrdersList(_getCompletedOrders(state.orders)),
                _buildOrdersList(_getCancelledOrders(state.orders)),
              ],
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildOrdersList(List<OrderEntity> orders) {
    if (orders.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrderBloc>().add(GetOrdersEvent());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: AppColors.grey,
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد طلبات',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'ستظهر طلباتك هنا بعد إتمام عمليات الشراء',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'تصفح المنتجات',
              onPressed: () => context.go('/products'),
              icon: const Icon(Icons.shopping_bag),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderEntity order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: CustomCard(
        onTap: () => _showOrderDetails(order),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رأس الطلب
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'طلب #${order.id.substring(0, 8)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildStatusChip(order.status),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // تاريخ الطلب
            Text(
              'تاريخ الطلب: ${_formatDate(order.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.grey,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // المنتجات
            Column(
              children: order.items.take(2).map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      // صورة مصغرة
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: item.product.mainImage.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                item.product.mainImage,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.image_not_supported,
                                    size: 20,
                                    color: AppColors.grey,
                                  );
                                },
                              ),
                            )
                          : const Icon(
                              Icons.checkroom,
                              size: 20,
                              color: AppColors.grey,
                            ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      // معلومات المنتج
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.displayName,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'الكمية: ${item.quantity}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // السعر
                      Text(
                        '${item.totalPrice.toStringAsFixed(0)} ل.س',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            
            // إذا كان هناك منتجات أكثر
            if (order.items.length > 2)
              Text(
                'و ${order.items.length - 2} منتج آخر',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.grey,
                ),
              ),
            
            const SizedBox(height: 12),
            
            // المجموع وأزرار التحكم
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المجموع: ${order.totalAmount.toStringAsFixed(0)} ل.س',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                Row(
                  children: [
                    if (_canCancelOrder(order))
                      CustomButton(
                        text: 'إلغاء',
                        type: ButtonType.outline,
                        size: ButtonSize.small,
                        onPressed: () => _cancelOrder(order),
                      ),
                    
                    const SizedBox(width: 8),
                    
                    if (_canReorderOrder(order))
                      CustomButton(
                        text: 'إعادة طلب',
                        size: ButtonSize.small,
                        onPressed: () => _reorderOrder(order),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderStatus status) {
    Color color;
    switch (status) {
      case OrderStatus.pending:
        color = AppColors.warning;
        break;
      case OrderStatus.confirmed:
        color = AppColors.info;
        break;
      case OrderStatus.processing:
        color = AppColors.primary;
        break;
      case OrderStatus.shipped:
        color = AppColors.secondary;
        break;
      case OrderStatus.delivered:
        color = AppColors.success;
        break;
      case OrderStatus.cancelled:
        color = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.statusText,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  List<OrderEntity> _getCurrentOrders(List<OrderEntity> orders) {
    return orders.where((order) => 
      order.status != OrderStatus.delivered && 
      order.status != OrderStatus.cancelled
    ).toList();
  }

  List<OrderEntity> _getCompletedOrders(List<OrderEntity> orders) {
    return orders.where((order) => order.status == OrderStatus.delivered).toList();
  }

  List<OrderEntity> _getCancelledOrders(List<OrderEntity> orders) {
    return orders.where((order) => order.status == OrderStatus.cancelled).toList();
  }

  bool _canCancelOrder(OrderEntity order) {
    return order.status == OrderStatus.pending || 
           order.status == OrderStatus.confirmed;
  }

  bool _canReorderOrder(OrderEntity order) {
    return order.status == OrderStatus.delivered || 
           order.status == OrderStatus.cancelled;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showOrderDetails(OrderEntity order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // رأس الطلب
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'تفاصيل الطلب',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // معلومات الطلب
                          CustomCard(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('رقم الطلب:'),
                                    Text('#${order.id.substring(0, 8)}'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('التاريخ:'),
                                    Text(_formatDate(order.createdAt)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('الحالة:'),
                                    _buildStatusChip(order.status),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // عنوان التوصيل
                          const Text(
                            'عنوان التوصيل',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          CustomCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(order.shippingAddress.fullName),
                                Text(order.shippingAddress.phone),
                                Text(order.shippingAddress.fullAddress),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // المنتجات
                          const Text(
                            'المنتجات',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...order.items.map((item) {
                            return CustomCard(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: AppColors.lightGrey,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: item.product.mainImage.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            item.product.mainImage,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : const Icon(Icons.checkroom),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.product.displayName),
                                        Text(
                                          'الكمية: ${item.quantity}',
                                          style: const TextStyle(color: AppColors.grey),
                                        ),
                                        if (item.selectedSize != null || item.selectedColor != null)
                                          Text(
                                            [
                                              if (item.selectedSize != null) 'الحجم: ${item.selectedSize}',
                                              if (item.selectedColor != null) 'اللون: ${item.selectedColor}',
                                            ].join(' • '),
                                            style: const TextStyle(color: AppColors.grey, fontSize: 12),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${item.totalPrice.toStringAsFixed(0)} ل.س',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          
                          const SizedBox(height: 16),
                          
                          // ملخص التكاليف
                          CustomCard(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('المجموع الفرعي:'),
                                    Text('${order.totalAmount.toStringAsFixed(0)} ل.س'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('التوصيل:'),
                                    const Text('مجاني', style: TextStyle(color: AppColors.success)),
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('المجموع الكلي:', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text(
                                      '${order.totalAmount.toStringAsFixed(0)} ل.س',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _cancelOrder(OrderEntity order) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('إلغاء الطلب'),
          content: const Text('هل أنت متأكد من إلغاء هذا الطلب؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('تراجع'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<OrderBloc>().add(CancelOrderEvent(order.id));
              },
              child: const Text(
                'إلغاء الطلب',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  void _reorderOrder(OrderEntity order) {
    // TODO: إضافة المنتجات للسلة مرة أخرى
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم إضافة إعادة الطلب قريباً'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}