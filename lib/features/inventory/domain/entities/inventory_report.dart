import 'package:equatable/equatable.dart';

import '../value_objects/money.dart';

final class InventoryReport extends Equatable {
  const InventoryReport({
    required this.totalProducts,
    required this.lowStockProducts,
    required this.outOfStockProducts,
    required this.totalInventoryValue,
  });

  final int totalProducts;
  final int lowStockProducts;
  final int outOfStockProducts;
  final Money totalInventoryValue;

  @override
  List<Object?> get props => [
        totalProducts,
        lowStockProducts,
        outOfStockProducts,
        totalInventoryValue,
      ];
}
