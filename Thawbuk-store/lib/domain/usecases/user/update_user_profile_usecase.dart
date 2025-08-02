import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class UpdateUserProfileUseCase implements UseCase<UserEntity, UpdateUserParams> {
  final UserRepository repository;

  UpdateUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(UpdateUserParams params) async {
    return await repository.updateProfile(params.userData);
  }
}

class UpdateUserParams extends Equatable {
  final Map<String, dynamic> userData;

  const UpdateUserParams({required this.userData});

  @override
  List<Object> get props => [userData];
}
