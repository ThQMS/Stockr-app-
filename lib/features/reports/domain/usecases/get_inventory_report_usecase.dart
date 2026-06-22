import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../inventory/domain/entities/inventory_report.dart';
import '../../../inventory/domain/entities/product.dart';
import '../../../inventory/domain/repositories/product_repository.dart';
import '../../../inventory/domain/value_objects/money.dart';
import '../../../inventory/domain/value_objects/stock_quantity.dart';

final class GetInventoryReportParams extends Equatable {
  const GetInventoryReportParams({required this.workspaceId});

  final String workspaceId;

  @override
  List<Object> get props => [workspaceId];
}

final class GetInventoryReportUseCase
    implements UseCase<InventoryReport, GetInventoryReportParams> {
  const GetInventoryReportUseCase(this._repository);

  final ProductRepository _repository;

  @override
  Future<Either<Failure, InventoryReport>> call(
    GetInventoryReportParams params,
  ) async {
    if (params.workspaceId.trim().isEmpty) {
      return const Left(
        ValidationFailure(
          'Invalid report request',
          errors: {
            'workspaceId': ['Workspace is required'],
          },
        ),
      );
    }

    final Either<Failure, List<Product>> productsResult;
    try {
      productsResult = await _repository.getProducts(
        workspaceId: params.workspaceId,
      );
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }

    return productsResult.map((products) {
      final totalValue = products.fold<Money>(
        Money.zero,
        (sum, product) => sum + product.totalValue,
      );

      return InventoryReport(
        totalProducts: products.length,
        lowStockProducts:
            products.where((product) => product.isLowStock).length,
        outOfStockProducts: products
            .where((product) => product.currentStock == StockQuantity.zero)
            .length,
        totalInventoryValue: totalValue,
      );
    });
  }
}
