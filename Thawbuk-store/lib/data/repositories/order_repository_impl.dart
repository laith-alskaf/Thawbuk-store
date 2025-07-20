import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  OrderRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Order>>> getOrders() async {
    if (await networkInfo.isConnected) {
      try {
        final orderModels = await remoteDataSource.getOrders();
        final orders = orderModels.map((model) => model.toEntity()).toList();
        return Right(orders);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Order>> getOrderById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final orderModel = await remoteDataSource.getOrderById(id);
        return Right(orderModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Order>> createOrder(Map<String, dynamic> orderData) async {
    if (await networkInfo.isConnected) {
      try {
        final orderModel = await remoteDataSource.createOrder(orderData);
        return Right(orderModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Order>> updateOrderStatus(String id, String status) async {
    if (await networkInfo.isConnected) {
      try {
        final statusData = {'status': status};
        final orderModel = await remoteDataSource.updateOrderStatus(id, statusData);
        return Right(orderModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelOrder(String id) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.cancelOrder(id);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}