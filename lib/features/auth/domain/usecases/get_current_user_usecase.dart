import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

final class GetCurrentUserUseCase implements UseCase<AuthUser?, NoParams> {
  const GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, AuthUser?>> call(NoParams params) {
    return _repository.getCurrentUser();
  }
}
