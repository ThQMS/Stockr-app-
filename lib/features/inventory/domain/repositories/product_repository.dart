import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/movement.dart';
import '../entities/movement_filters.dart';
import '../entities/movement_params.dart';
import '../entities/product.dart';
import '../entities/product_filters.dart';
import '../entities/product_params.dart';

abstract interface class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts({
    required String workspaceId,
    ProductFilters? filters,
  });

  Future<Either<Failure, Product>> getById(String id);

  Future<Either<Failure, Product>> scanByCode({
    required String code,
    required String workspaceId,
  });

  Future<Either<Failure, Product>> create(CreateProductParams params);
  Future<Either<Failure, Product>> update(UpdateProductParams params);
  Future<Either<Failure, Unit>> delete(String id);
}

abstract interface class MovementRepository {
  Future<Either<Failure, Movement>> register(RegisterMovementParams params);
  Future<Either<Failure, List<Movement>>> getByProduct(String productId);
  Future<Either<Failure, List<Movement>>> getByWorkspace({
    required String workspaceId,
    MovementFilters? filters,
  });
  Future<Either<Failure, int>> getPendingSyncCount();
  Future<Either<Failure, Unit>> syncPending();
}
