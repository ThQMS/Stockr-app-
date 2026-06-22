import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../entities/product_filters.dart';
import '../repositories/product_repository.dart';

final class GetProductsParams extends Equatable {
  const GetProductsParams({
    required this.workspaceId,
    this.filters,
  });

  final String workspaceId;
  final ProductFilters? filters;

  @override
  List<Object?> get props => [workspaceId, filters];
}

final class GetProductsUseCase
    implements UseCase<List<Product>, GetProductsParams> {
  const GetProductsUseCase(this._repository);

  final ProductRepository _repository;

  @override
  Future<Either<Failure, List<Product>>> call(GetProductsParams params) async {
    if (params.workspaceId.trim().isEmpty) {
      return const Left(
        ValidationFailure(
          'Invalid product request',
          errors: {
            'workspaceId': ['Workspace is required'],
          },
        ),
      );
    }

    final Either<Failure, List<Product>> result;
    try {
      result = await _repository.getProducts(
        workspaceId: params.workspaceId,
        filters: params.filters,
      );
    } catch (error) {
      return Left(ServerFailure(error.toString()));
    }

    return result.map(
      (products) => products
          .where((product) => _matchesFilters(product, params.filters))
          .toList(),
    );
  }

  bool _matchesFilters(Product product, ProductFilters? filters) {
    if (filters == null) {
      return true;
    }

    final query = filters.query?.trim().toLowerCase();
    final matchesQuery = query == null || query.isEmpty
        ? true
        : product.name.toLowerCase().contains(query) ||
            product.sku.value.toLowerCase().contains(query);
    final matchesCategory = filters.categoryId == null
        ? true
        : product.categoryId == filters.categoryId;
    final matchesActive = filters.onlyActive == null
        ? true
        : product.isActive == filters.onlyActive;
    final matchesLowStock =
        filters.onlyLowStock == true ? product.isLowStock : true;

    return matchesQuery && matchesCategory && matchesActive && matchesLowStock;
  }
}
