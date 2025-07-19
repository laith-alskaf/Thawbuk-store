import 'package:equatable/equatable.dart';
import 'product.dart';

class Order extends Equatable {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final ShippingAddress shippingAddress;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final String orderNumber;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.shippingAddress,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderNumber,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  bool get canBeCancelled => 
      status == OrderStatus.pending || status == OrderStatus.confirmed;

  bool get isCompleted => status == OrderStatus.delivered;

  String get statusText => _getStatusText(status);
  String get paymentStatusText => _getPaymentStatusText(paymentStatus);

  static String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'في الانتظار';
      case OrderStatus.confirmed:
        return 'مؤكد';
      case OrderStatus.shipped:
        return 'تم الشحن';
      case OrderStatus.delivered:
        return 'تم التسليم';
      case OrderStatus.cancelled:
        return 'ملغي';
    }
  }

  static String _getPaymentStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'في الانتظار';
      case PaymentStatus.paid:
        return 'مدفوع';
      case PaymentStatus.failed:
        return 'فشل الدفع';
    }
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        items,
        totalAmount,
        shippingAddress,
        status,
        paymentMethod,
        paymentStatus,
        orderNumber,
        notes,
        createdAt,
        updatedAt,
      ];
}

class OrderItem extends Equatable {
  final String productId;
  final int quantity;
  final double price;
  final String? selectedSize;
  final String? selectedColor;
  final Product? product;

  const OrderItem({
    required this.productId,
    required this.quantity,
    required this.price,
    this.selectedSize,
    this.selectedColor,
    this.product,
  });

  double get totalPrice => price * quantity;

  String get displayText {
    final parts = <String>[];
    if (selectedSize != null) parts.add('المقاس: $selectedSize');
    if (selectedColor != null) parts.add('اللون: $selectedColor');
    return parts.join(' • ');
  }

  @override
  List<Object?> get props => [
        productId,
        quantity,
        price,
        selectedSize,
        selectedColor,
        product,
      ];
}

class ShippingAddress extends Equatable {
  final String street;
  final String city;
  final String country;
  final String? postalCode;
  final String? phone;

  const ShippingAddress({
    required this.street,
    required this.city,
    required this.country,
    this.postalCode,
    this.phone,
  });

  String get fullAddress {
    final parts = [street, city, country];
    if (postalCode != null) parts.add(postalCode!);
    return parts.join(', ');
  }

  @override
  List<Object?> get props => [street, city, country, postalCode, phone];
}

enum OrderStatus {
  pending,
  confirmed,
  shipped,
  delivered,
  cancelled,
}

enum PaymentMethod {
  cash,
  card,
  online,
}

enum PaymentStatus {
  pending,
  paid,
  failed,
}