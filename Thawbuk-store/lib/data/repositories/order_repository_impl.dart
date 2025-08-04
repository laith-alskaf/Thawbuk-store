import 'package:dartz/dartz.dart';
import 'package:thawbuk_store/domain/entities/order_entity.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/user_entity.dart';
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
  Future<Either<Failure, List<OrderEntity>>> getOrders() async {
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
  Future<Either<Failure, OrderEntity>> getOrderById(String id) async {
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
  Future<Either<Failure, OrderEntity>> createOrder(
      {String? notes, required AddressEntity shippingAddress}) async {
    if (await networkInfo.isConnected) {
      // try {
      //   final orderModel = await remoteDataSource.createOrder(orderData);
      //   return Right(orderModel.toEntity());
      // } on ServerException catch (e) {
        return Left(ServerFailure('e.message'));
      // }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> updateOrderStatus(
      {required String orderId, required dynamic status}) async {
    if (await networkInfo.isConnected) {
      // try {
      //   final statusData = {'status': status};
      //   final orderModel =
      //       await remoteDataSource.updateOrderStatus(id, statusData);
      // return Right(orderModel.toEntity());
      // } on ServerException catch (e) {
      return Left(ServerFailure('e.message'));
      // }
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
