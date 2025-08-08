import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/admin_dashboard_stats_entity.dart';
import '../../repositories/product_repository.dart';

class GetAdminDashboardStatsUseCase extends UseCase<AdminDashboardStatsEntity, NoParams> {
  final ProductRepository repository;

  GetAdminDashboardStatsUseCase(this.repository);

  @override
  Future<Either<Failure, AdminDashboardStatsEntity>> call(NoParams params) async {
    return await repository.getAdminDashboardStats();
  }
}