import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

final class ScanProductParams extends Equatable {
  const ScanProductParams({
    required this.code,
    required this.workspaceId,
  });

  final String code;
  final String workspaceId;

  @override
  List<Object> get props => [code, workspaceId];
}

final class ScanProductUseCase implements UseCase<Product, ScanProductParams> {
  const ScanProductUseCase(this._repository);

  final ProductRepository _repository;

  @override
  Future<Either<Failure, Product>> call(ScanProductParams params) async {
    if (params.code.trim().isEmpty) {
      return const Left(
        ValidationFailure(
          'Invalid scan',
          errors: {
            'code': ['Code is required'],
          },
        ),
      );
    }
    if (params.workspaceId.trim().isEmpty) {
      return const Left(
        ValidationFailure(
          'Invalid scan',
          errors: {
            'workspaceId': ['Workspace is required'],
          },
        ),
      );
    }

    try {
      return await _repository.scanByCode(
        code: params.code.trim(),
        workspaceId: params.workspaceId,
      );
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }
  }
}
