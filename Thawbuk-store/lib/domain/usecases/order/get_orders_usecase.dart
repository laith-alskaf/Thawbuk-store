import 'package:dartz/dartz.dart';
import 'package:thawbuk_store/domain/entities/order_entity.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/order_repository.dart';

class GetOrdersUseCase implements UseCase<List<OrderEntity>, NoParams> {
  final OrderRepository repository;

  GetOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, List<OrderEntity>>> call(NoParams params) async {
    return await repository.getOrders();
  }
}