import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/product_repository.dart';

final class GetPendingSyncCountUseCase implements UseCase<int, NoParams> {
  const GetPendingSyncCountUseCase(this._repository);

  final MovementRepository _repository;

  @override
  Future<Either<Failure, int>> call(NoParams params) async {
    try {
      return await _repository.getPendingSyncCount();
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }
}
