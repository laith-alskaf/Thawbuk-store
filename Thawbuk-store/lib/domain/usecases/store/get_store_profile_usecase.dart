import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/store_profile_entity.dart';
import '../../repositories/store_repository.dart';

class GetStoreProfileUseCase implements UseCase<StoreProfileEntity, GetStoreProfileParams> {
  final StoreRepository repository;

  GetStoreProfileUseCase(this.repository);

  @override
  Future<Either<Failure, StoreProfileEntity>> call(GetStoreProfileParams params) async {
    return await repository.getStoreProfile(params.storeId);
  }
}

class GetStoreProfileParams extends Equatable {
  final String storeId;

  const GetStoreProfileParams({required this.storeId});

  @override
  List<Object> get props => [storeId];
}