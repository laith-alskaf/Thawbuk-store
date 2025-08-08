import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:thawbuk_store/presentation/bloc/cart/cart_bloc.dart';
import '../../bloc/order/order_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/order_entity.dart';
import '../../widgets/shared/loading_widget.dart';
import '../../widgets/shared/error_widget.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with SingleTickerProviderStateMixin {
  
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<OrderStatus> _statusTabs = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.processing,
    OrderStatus.shipped,
    OrderStatus.delivered,
  ];

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: _statusTabs.length, vsync: this);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Load orders
    context.read<OrderBloc>().add(GetOrdersEvent());
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildStatusTabs(),
            Expanded(child: _buildOrdersList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/products'),
        label: const Text('تسوق الآن'),
        icon: const Icon(Icons.shopping_bag),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('طلباتي'),
      elevation: 0,
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.darkGrey,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            context.read<OrderBloc>().add(GetOrdersEvent());
          },
          tooltip: 'تحديث',
        ),
      ],
    );
  }

  Widget _buildStatusTabs() {
    return Container(
      color: AppColors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: AppColors.primary,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.grey,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 14,
        ),
        tabs: _statusTabs.map((status) {
          return Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(status.statusText),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildOrdersList() {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading) {
          return const ListLoadingWidget();
        } else if (state is OrderError) {
          return CustomErrorWidget(
            message: state.message,
            onRetry: () => context.read<OrderBloc>().add(GetOrdersEvent()),
          );
        } else if (state is OrdersLoaded) {
          return TabBarView(
            controller: _tabController,
            children: _statusTabs.map((status) {
              final filteredOrders = state.orders
                  .where((order) => order.status == status)
                  .toList();
              
              return _buildOrdersTabContent(filteredOrders, status);
            }).toList(),
          );
        }
        
        return const EmptyWidget(
          title: 'لا توجد طلبات',
          message: 'لم تقم بإجراء أي طلبات بعد',
          icon: Icons.receipt_long_outlined,
        );
      },
    );
  }

  Widget _buildOrdersTabContent(List<OrderEntity> orders, OrderStatus status) {
    if (orders.isEmpty) {
      return _buildEmptyState(status);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrderBloc>().add(GetOrdersEvent());
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return SizedBox();
          // return OrderCard(
          //   order: orders[index],
          //   onTap: () => _showOrderDetails(orders[index]),
          //   onTrack: () => _trackOrder(orders[index]),
          //   onReorder: () => _reorderItems(orders[index]),
          //   onCancel: orders[index].status == OrderStatus.pending
          //       ? () => _cancelOrder(orders[index])
          //       : null,
          // );
        },
      ),
    );
  }

  Widget _buildEmptyState(OrderStatus status) {
    String message;
    IconData icon;
    
    switch (status) {
      case OrderStatus.pending:
        message = 'لا توجد طلبات في الانتظار';
        icon = Icons.hourglass_empty;
        break;
      case OrderStatus.confirmed:
        message = 'لا توجد طلبات مؤكدة';
        icon = Icons.check_circle_outline;
        break;
      case OrderStatus.processing:
        message = 'لا توجد طلبات جاري تحضيرها';
        icon = Icons.engineering_outlined;
        break;
      case OrderStatus.shipped:
        message = 'لا توجد طلبات مشحونة';
        icon = Icons.local_shipping_outlined;
        break;
      case OrderStatus.delivered:
        message = 'لا توجد طلبات مسلمة';
        icon = Icons.done_all;
        break;
      case OrderStatus.cancelled:
        message = 'لا توجد طلبات ملغاة';
        icon = Icons.cancel_outlined;
        break;
    }

    return EmptyWidget(
      title: 'لا توجد طلبات',
      message: message,
      icon: icon,
    );
  }

  void _showOrderDetails(OrderEntity order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderDetailsBottomSheet(order: order),
    );
  }

  void _trackOrder(OrderEntity order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderTrackingBottomSheet(order: order),
    );
  }

  void _reorderItems(OrderEntity order) {
    // Add all order items back to cart
    for (final item in order.items) {
      context.read<CartBloc>().add(AddToCartEvent(
        productId: item.productId,
        quantity: item.quantity,
        selectedSize: item.selectedSize,
        selectedColor: item.selectedColor,
      ));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إضافة ${order.items.length} منتج للسلة'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        action: SnackBarAction(
          label: 'عرض السلة',
          textColor: AppColors.white,
          onPressed: () => context.push('/cart'),
        ),
      ),
    );
  }

  void _cancelOrder(OrderEntity order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الطلب'),
        content: Text('هل أنت متأكد من إلغاء الطلب رقم ${order.id}؟'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لا'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement cancel order logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إلغاء الطلب بنجاح'),
                  backgroundColor: AppColors.warning,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('نعم، إلغاء'),
          ),
        ],
      ),
    );
  }
}

// Order Details Bottom Sheet
class OrderDetailsBottomSheet extends StatelessWidget {
  final OrderEntity order;

  const OrderDetailsBottomSheet({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOrderInfo(),
                  const SizedBox(height: 20),
                  _buildShippingAddress(),
                  const SizedBox(height: 20),
                  _buildOrderItems(),
                  const SizedBox(height: 20),
                  _buildOrderSummary(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
          Expanded(
            child: Text(
              'تفاصيل الطلب #${order.id}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(order.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(order.status).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
             const Text(
                'حالة الطلب',
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.status.statusText,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          const    Text(
                'تاريخ الطلب',
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: 14,
                ),
              ),
              Text(
                _formatDate(order.createdAt),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (order.deliveredAt != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
               const Text(
                  'تاريخ التسليم',
                  style: TextStyle(
                    color: AppColors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  _formatDate(order.deliveredAt!),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShippingAddress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       const Text(
          'عنوان التسليم',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightGrey.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.shippingAddress.fullName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(order.shippingAddress.phone),
              const SizedBox(height: 4),
              Text(order.shippingAddress.fullAddress),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المنتجات (${order.items.length})',
          style:const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...order.items.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.lightGrey.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: AppColors.lightGrey,
                    child: item.product.images.isNotEmpty
                        ? Image.network(
                            item.product.images.first,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.image),
                          )
                        : const Icon(Icons.image),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.selectedSize != null || item.selectedColor != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (item.selectedSize != null)
                              Text(
                                'الحجم: ${item.selectedSize}',
                                style:const TextStyle(
                                  color: AppColors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            if (item.selectedSize != null && item.selectedColor != null)
                            const  Text(' • ', style: TextStyle(color: AppColors.grey)),
                            if (item.selectedColor != null)
                              Text(
                                'اللون: ${item.selectedColor}',
                                style:const TextStyle(
                                  color: AppColors.grey,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'الكمية: ${item.quantity}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '${item.totalPrice.toStringAsFixed(2)} ريال',
                            style:const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
       const   Text(
            'ملخص الطلب',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
          const    Text('إجمالي المنتجات'),
              Text('${order.totalAmount.toStringAsFixed(2)} ريال'),
            ],
          ),
          const SizedBox(height: 8),
      const    Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('رسوم التوصيل'),
              Text('مجاناً'),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            const  Text(
                'المجموع الإجمالي',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${order.totalAmount.toStringAsFixed(2)} ريال',
                style:const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.warning;
      case OrderStatus.confirmed:
        return AppColors.info;
      case OrderStatus.processing:
        return AppColors.secondary;
      case OrderStatus.shipped:
        return AppColors.primary;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Order Tracking Bottom Sheet
class OrderTrackingBottomSheet extends StatelessWidget {
  final OrderEntity order;

  const OrderTrackingBottomSheet({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Container(
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
                Expanded(
                  child: Text(
                    'تتبع الطلب #${order.id}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _buildTrackingSteps(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingSteps() {
    final steps = [
      {'status': OrderStatus.pending, 'title': 'تم استلام الطلب', 'subtitle': 'تم تأكيد طلبكم'},
      {'status': OrderStatus.confirmed, 'title': 'تم تأكيد الطلب', 'subtitle': 'جاري التحضير'},
      {'status': OrderStatus.processing, 'title': 'جاري التحضير', 'subtitle': 'يتم تجهيز منتجاتك'},
      {'status': OrderStatus.shipped, 'title': 'تم الشحن', 'subtitle': 'الطلب في الطريق إليك'},
      {'status': OrderStatus.delivered, 'title': 'تم التسليم', 'subtitle': 'تم التسليم بنجاح'},
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final status = step['status'] as OrderStatus;
        final isCompleted = _getStatusIndex(order.status) >= _getStatusIndex(status);
        final isCurrent = order.status == status;

        return Row(
          children: [
            Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.success : AppColors.lightGrey,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCurrent ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check : Icons.circle,
                    color: isCompleted ? AppColors.white : AppColors.grey,
                    size: 16,
                  ),
                ),
                if (index < steps.length - 1)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted ? AppColors.success : AppColors.lightGrey,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step['title'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? AppColors.darkGrey : AppColors.grey,
                      ),
                    ),
                    Text(
                      step['subtitle'] as String,
                      style:const  TextStyle(
                        fontSize: 12,
                        color: AppColors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  int _getStatusIndex(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.processing:
        return 2;
      case OrderStatus.shipped:
        return 3;
      case OrderStatus.delivered:
        return 4;
      case OrderStatus.cancelled:
        return -1;
    }
  }
}