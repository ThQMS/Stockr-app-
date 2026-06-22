import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/movement_repository.dart';

final class SyncPendingMovementsUseCase implements UseCase<int, NoParams> {
  const SyncPendingMovementsUseCase(this._repository);

  final MovementRepository _repository;

  @override
  Future<Either<Failure, int>> call(NoParams params) async {
    final Either<Failure, int> pendingResult;
    try {
      pendingResult = await _repository.getPendingSyncCount();
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }

    return pendingResult.match(
      (failure) async => Left(failure),
      (pendingCount) async {
        if (pendingCount == 0) {
          return const Right(0);
        }

        final Either<Failure, Unit> syncResult;
        try {
          syncResult = await _repository.syncPending();
        } catch (error) {
          return Left(ServerFailure(error.toString()));
        }

        return syncResult.match(
          (failure) => Left(failure),
          (_) => Right(pendingCount),
        );
      },
    );
  }
}
