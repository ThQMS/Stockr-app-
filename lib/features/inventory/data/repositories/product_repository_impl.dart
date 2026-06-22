import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_filters.dart';
import '../../domain/entities/product_params.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_datasource.dart';
import '../datasources/product_remote_ds.dart';

@Injectable(as: ProductRepository)
class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl({
    required ProductRemoteDataSource remote,
    required ProductLocalDataSource local,
    required NetworkInfo network,
  })  : _remote = remote,
        _local = local,
        _network = network;

  final ProductRemoteDataSource _remote;
  final ProductLocalDataSource _local;
  final NetworkInfo _network;

  @override
  Future<Either<Failure, List<Product>>> getProducts({
    required String workspaceId,
    ProductFilters? filters,
  }) async {
    if (await _network.isConnected) {
      return _fetchRemoteAndCache(workspaceId, filters);
    }
    return _getFromCache(workspaceId, filters);
  }

  Future<Either<Failure, List<Product>>> _fetchRemoteAndCache(
    String workspaceId,
    ProductFilters? filters,
  ) async {
    try {
      final models = await _remote.getProducts(
        workspaceId: workspaceId,
        filters: filters,
      );
      await _local.upsertAll(models);
      return Right(models.map((model) => model.toDomain()).toList());
    } on ServerException catch (error) {
      return Left(
        ServerFailure(error.message, statusCode: error.statusCode),
      );
    } on NetworkException {
      return const Left(NetworkFailure());
    } on DioException catch (error) {
      return Left(ServerFailure(error.message ?? 'Could not fetch products'));
    }
  }

  Future<Either<Failure, List<Product>>> _getFromCache(
    String workspaceId,
    ProductFilters? filters,
  ) async {
    try {
      final cached = await _local.getProducts(
        workspaceId: workspaceId,
        filters: filters,
      );
      if (cached.isEmpty) {
        return const Left(CacheFailure('No cached data available'));
      }
      return Right(cached.map((model) => model.toDomain()).toList());
    } on CacheException catch (error) {
      return Left(CacheFailure(error.message));
    }
  }

  @override
  Future<Either<Failure, Product>> getById(String id) async {
    final cached = await _local.getById(id);
    if (cached != null) {
      return Right(cached.toDomain());
    }

    if (!await _network.isConnected) {
      return const Left(NotFoundFailure('Product not found offline'));
    }

    try {
      final remote = await _remote.getById(id);
      await _local.upsert(remote);
      return Right(remote.toDomain());
    } on NotFoundException {
      return const Left(NotFoundFailure('Product not found'));
    } on DioException catch (error) {
      return Left(ServerFailure(error.message ?? 'Could not fetch product'));
    }
  }

  @override
  Future<Either<Failure, Product>> scanByCode({
    required String code,
    required String workspaceId,
  }) async {
    final local = await _local.findByCode(code, workspaceId);
    if (local != null) {
      return Right(local.toDomain());
    }

    if (!await _network.isConnected) {
      return const Left(NotFoundFailure('Product not found offline'));
    }

    try {
      final remote = await _remote.scanByCode(
        code: code,
        workspaceId: workspaceId,
      );
      await _local.upsert(remote);
      return Right(remote.toDomain());
    } on NotFoundException {
      return const Left(NotFoundFailure('Product not found'));
    } on DioException catch (error) {
      return Left(ServerFailure(error.message ?? 'Could not scan product'));
    }
  }

  @override
  Future<Either<Failure, Product>> create(CreateProductParams params) async {
    if (!await _network.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final created = await _remote.create(params);
      await _local.upsert(created);
      return Right(created.toDomain());
    } on DioException catch (error) {
      return Left(ServerFailure(error.message ?? 'Could not create product'));
    }
  }

  @override
  Future<Either<Failure, Product>> update(UpdateProductParams params) async {
    if (!await _network.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      final updated = await _remote.update(params);
      await _local.upsert(updated);
      return Right(updated.toDomain());
    } on DioException catch (error) {
      return Left(ServerFailure(error.message ?? 'Could not update product'));
    }
  }

  @override
  Future<Either<Failure, Unit>> delete(String id) async {
    if (!await _network.isConnected) {
      return const Left(NetworkFailure());
    }

    try {
      await _remote.delete(id);
      await _local.delete(id);
      return const Right(unit);
    } on DioException catch (error) {
      return Left(ServerFailure(error.message ?? 'Could not delete product'));
    }
  }
}
