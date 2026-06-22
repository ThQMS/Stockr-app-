import 'package:equatable/equatable.dart';

final class ProductFilters extends Equatable {
  const ProductFilters({
    this.query,
    this.categoryId,
    this.onlyActive,
    this.onlyLowStock,
  });

  final String? query;
  final String? categoryId;
  final bool? onlyActive;
  final bool? onlyLowStock;

  @override
  List<Object?> get props => [query, categoryId, onlyActive, onlyLowStock];
}
