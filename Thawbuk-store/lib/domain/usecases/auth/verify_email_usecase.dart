import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../repositories/auth_repository.dart';

class VerifyEmailUseCase implements UseCase<void, VerifyEmailParams> {
  final AuthRepository repository;

  VerifyEmailUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(VerifyEmailParams params) async {
    return await repository.verifyEmail(params.email, params.code);
  }
}

class VerifyEmailParams extends Equatable {
  final String email;
  final String code;

  const VerifyEmailParams({required this.email, required this.code});

  @override
  List<Object?> get props => [email, code];
}
