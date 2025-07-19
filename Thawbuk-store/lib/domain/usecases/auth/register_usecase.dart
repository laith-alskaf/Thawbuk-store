import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/auth_repository.dart';

class RegisterUseCase implements UseCase<void, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RegisterParams params) async {
    return await repository.register(
      email: params.email,
      password: params.password,
      name: params.name,
      role: params.role,
      age: params.age,
      gender: params.gender,
      children: params.children,
      address: params.address,
      companyDetails: params.companyDetails,
    );
  }
}

class RegisterParams {
  final String email;
  final String password;
  final String? name;
  final String role;
  final int? age;
  final String? gender;
  final List<Map<String, dynamic>>? children;
  final Map<String, dynamic>? address;
  final Map<String, dynamic>? companyDetails;

  RegisterParams({
    required this.email,
    required this.password,
    this.name,
    this.role = 'customer',
    this.age,
    this.gender,
    this.children,
    this.address,
    this.companyDetails,
  });
}