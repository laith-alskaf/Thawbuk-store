import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/order_entity.dart';
import '../../repositories/order_repository.dart';

class CreateOrderUseCase implements UseCase<OrderEntity, CreateOrderParams> {
  final OrderRepository repository;

  CreateOrderUseCase(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(CreateOrderParams params) async {
    return await repository.createOrder(
      shippingAddress: params.shippingAddress,
      notes: params.notes,
    );
  }
}

class CreateOrderParams extends Equatable {
  final AddressEntity shippingAddress;
  final String? notes;

  const CreateOrderParams({
    required this.shippingAddress,
    this.notes,
  });

  @override
  List<Object?> get props => [shippingAddress, notes];
}