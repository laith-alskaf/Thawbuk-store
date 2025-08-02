import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class ChangePasswordUseCase implements UseCase<void, ChangePasswordParams> {
  final AuthRepository repository;

  ChangePasswordUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ChangePasswordParams params) async {
    return await repository.changePassword(ChangePasswordRequest(
      email: params.email,
      newPassword: params.newPassword,
    ));
  }
}

class ChangePasswordParams {
  final String email;
  final String newPassword;

  ChangePasswordParams({
    required this.email,
    required this.newPassword,
  });
}