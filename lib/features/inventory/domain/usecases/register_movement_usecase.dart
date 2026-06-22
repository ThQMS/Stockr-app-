import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/movement.dart';
import '../entities/movement_params.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';
import '../value_objects/stock_quantity.dart';

final class RegisterMovementUseCase
    implements UseCase<Movement, RegisterMovementParams> {
  const RegisterMovementUseCase(this._repository, this._products);

  final MovementRepository _repository;
  final ProductRepository _products;

  @override
  Future<Either<Failure, Movement>> call(RegisterMovementParams params) async {
    if (params.productId.trim().isEmpty) {
      return const Left(
        ValidationFailure(
          'Invalid movement',
          errors: {
            'productId': ['Product is required'],
          },
        ),
      );
    }
    if (params.workspaceId.trim().isEmpty) {
      return const Left(
        ValidationFailure(
          'Invalid movement',
          errors: {
            'workspaceId': ['Workspace is required'],
          },
        ),
      );
    }
    if (params.quantity <= 0) {
      return const Left(
        ValidationFailure(
          'Invalid movement',
          errors: {
            'quantity': ['Quantity must be greater than zero'],
          },
        ),
      );
    }

    final Either<Failure, Product> productResult;
    try {
      productResult = await _products.getById(params.productId);
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }

    return productResult.match(
      (failure) async => Left(failure),
      (product) async {
        if (params.type == MovementType.out ||
            params.type == MovementType.transfer) {
          final subtractResult = product.currentStock.subtract(
            StockQuantity.of(params.quantity),
          );

          return subtractResult.match(
            (failure) async => Left<Failure, Movement>(failure),
            (_) async {
              try {
                return await _repository.register(params);
              } catch (error) {
                return Left(ServerFailure(error.toString()));
              }
            },
          );
        }

        try {
          return await _repository.register(params);
        } catch (error) {
          return Left(ServerFailure(error.toString()));
        }
      },
    );
  }
}
