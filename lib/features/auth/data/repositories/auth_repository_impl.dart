import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

final class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, AuthUser>> login({
    required String email,
    required String password,
  }) async {
    try {
      final user =
          await _remoteDataSource.login(email: email, password: password);
      await _localDataSource.cacheUser(user);
      return Right(user);
    } on DioException catch (error) {
      return Left(ServerFailure(error.message ?? 'Login failed'));
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    }
  }

  @override
  Future<Either<Failure, AuthUser>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final user = await _remoteDataSource.register(
        name: name,
        email: email,
        password: password,
      );
      await _localDataSource.cacheUser(user);
      return Right(user);
    } on DioException catch (error) {
      return Left(ServerFailure(error.message ?? 'Register failed'));
    } on ServerException catch (error) {
      return Left(ServerFailure(error.message));
    }
  }

  @override
  Future<Either<Failure, AuthUser?>> getCurrentUser() async {
    try {
      return Right(await _localDataSource.getCachedUser());
    } on CacheException catch (error) {
      return Left(CacheFailure(error.message));
    }
  }
}
