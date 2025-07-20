import '../../core/errors/exceptions.dart';
import '../../core/network/api_client.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getOrders();
  Future<OrderModel> getOrderById(String id);
  Future<OrderModel> createOrder(Map<String, dynamic> orderData);
  Future<OrderModel> updateOrderStatus(String id, Map<String, dynamic> statusData);
  Future<void> cancelOrder(String id);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final ApiClient apiClient;

  OrderRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<OrderModel>> getOrders() async {
    try {
      final response = await apiClient.getOrders();
      return response;
    } catch (e) {
      throw ServerException('Failed to get orders: ${e.toString()}');
    }
  }

  @override
  Future<OrderModel> getOrderById(String id) async {
    try {
      final response = await apiClient.getOrderById(id);
      return response;
    } catch (e) {
      throw ServerException('Failed to get order: ${e.toString()}');
    }
  }

  @override
  Future<OrderModel> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await apiClient.createOrder(orderData);
      return response;
    } catch (e) {
      throw ServerException('Failed to create order: ${e.toString()}');
    }
  }

  @override
  Future<OrderModel> updateOrderStatus(String id, Map<String, dynamic> statusData) async {
    try {
      final response = await apiClient.updateOrderStatus(id, statusData);
      return response;
    } catch (e) {
      throw ServerException('Failed to update order status: ${e.toString()}');
    }
  }

  @override
  Future<void> cancelOrder(String id) async {
    try {
      await apiClient.cancelOrder(id);
    } catch (e) {
      throw ServerException('Failed to cancel order: ${e.toString()}');
    }
  }
}