import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class GetCurrentUserUseCase implements UseCaseNoParams<User> {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call() async {
    return await repository.getCurrentUser();
  }
}