import '../../core/errors/exceptions.dart';
import '../../core/network/http_client.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<List<OrderModel>> getOrders();
  Future<OrderModel> getOrderById(String id);
  Future<OrderModel> createOrder(Map<String, dynamic> orderData);
  Future<OrderModel> updateOrderStatus(String id, Map<String, dynamic> statusData);
  Future<void> cancelOrder(String id);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final HttpClient httpClient;

  OrderRemoteDataSourceImpl(this.httpClient);

  @override
  Future<List<OrderModel>> getOrders() async {
    try {
      final response = await httpClient.get('/user/order');
      
      if (response['data'] is List) {
        return (response['data'] as List)
            .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      // else if (response is List) {
      //   return response
      //       .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
      //       .toList();
      // }
      
      throw const ServerException('Invalid response format for orders');
    } catch (e) {
      throw ServerException('Failed to get orders: ${e.toString()}');
    }
  }

  @override
  Future<OrderModel> getOrderById(String id) async {
    try {
      final response = await httpClient.get('/user/order/$id');
      
      if (response['data'] != null) {
        return OrderModel.fromJson(response['data'] as Map<String, dynamic>);
      } else {
        return OrderModel.fromJson(response);
      }
    } catch (e) {
      throw ServerException('Failed to get order: ${e.toString()}');
    }
  }

  @override
  Future<OrderModel> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await httpClient.post('/user/order', body: orderData);
      
      if (response['data'] != null) {
        return OrderModel.fromJson(response['data'] as Map<String, dynamic>);
      } else {
        return OrderModel.fromJson(response);
      }
    } catch (e) {
      throw ServerException('Failed to create order: ${e.toString()}');
    }
  }

  @override
  Future<OrderModel> updateOrderStatus(String id, Map<String, dynamic> statusData) async {
    try {
      final response = await httpClient.put('/user/order/$id/status', body: statusData);
      
      if (response['data'] != null) {
        return OrderModel.fromJson(response['data'] as Map<String, dynamic>);
      } else {
        return OrderModel.fromJson(response);
      }
    } catch (e) {
      throw ServerException('Failed to update order status: ${e.toString()}');
    }
  }

  @override
  Future<void> cancelOrder(String id) async {
    try {
      await httpClient.deleteVoid('/user/order/$id');
    } catch (e) {
      throw ServerException('Failed to cancel order: ${e.toString()}');
    }
  }
}