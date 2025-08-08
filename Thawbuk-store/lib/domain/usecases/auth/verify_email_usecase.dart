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
    return await repository.verifyEmail(params.code, params.email);
  }
}

class VerifyEmailParams extends Equatable {
  final String code;
  final String email;

  const VerifyEmailParams({required this.code, required this.email});

  @override
  List<Object?> get props => [code, email];
}
