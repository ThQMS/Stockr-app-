import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/auth_user.dart';

abstract interface class AuthRepository {
  Future<Either<Failure, AuthUser>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthUser>> register({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<Failure, AuthUser?>> getCurrentUser();
}
