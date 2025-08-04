import 'package:dartz/dartz.dart';

import '../entities/order_entity.dart';
import '../entities/user_entity.dart';
import '../../core/errors/failures.dart';

abstract class OrderRepository {
  Future<Either<Failure, List<OrderEntity>>> getOrders();

  Future<Either<Failure, OrderEntity>> getOrderById(String id);

  Future<Either<Failure, OrderEntity>> createOrder({
    required AddressEntity shippingAddress,
    String? notes,
  });

  Future<Either<Failure, OrderEntity>> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
  });

  Future<Either<Failure, void>> cancelOrder(String orderId);
}