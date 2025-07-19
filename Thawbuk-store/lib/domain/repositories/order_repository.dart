import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/order.dart';

abstract class OrderRepository {
  Future<Either<Failure, Order>> createOrder({
    required List<Map<String, dynamic>> items,
    required Map<String, dynamic> shippingAddress,
    required String paymentMethod,
    String? notes,
  });

  Future<Either<Failure, List<Order>>> getUserOrders({
    int page = 1,
    int limit = 10,
  });

  Future<Either<Failure, Order>> getOrderById(String orderId);

  Future<Either<Failure, Order>> getOrderByNumber(String orderNumber);

  // للادمن فقط
  Future<Either<Failure, List<Order>>> getAllOrders({
    int page = 1,
    int limit = 10,
    String? status,
    String? paymentStatus,
    String? userId,
  });

  Future<Either<Failure, Order>> updateOrderStatus({
    required String orderId,
    required String status,
  });

  Future<Either<Failure, Order>> updatePaymentStatus({
    required String orderId,
    required String paymentStatus,
  });
}