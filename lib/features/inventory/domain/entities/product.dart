import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../value_objects/money.dart';
import '../value_objects/product_sku.dart';
import '../value_objects/stock_quantity.dart';

@immutable
class Product extends Equatable {
  const Product({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.sku,
    required this.currentStock,
    required this.minimumStock,
    required this.costPrice,
    required this.salePrice,
    required this.categoryId,
    required this.isActive,
  });

  final String id;
  final String workspaceId;
  final String name;
  final ProductSku sku;
  final StockQuantity currentStock;
  final StockQuantity minimumStock;
  final Money costPrice;
  final Money salePrice;
  final String categoryId;
  final bool isActive;

  bool get isLowStock => currentStock.isBelow(minimumStock);
  Money get totalValue => costPrice * currentStock.value;

  Product copyWith({
    String? id,
    String? workspaceId,
    String? name,
    ProductSku? sku,
    StockQuantity? currentStock,
    StockQuantity? minimumStock,
    Money? costPrice,
    Money? salePrice,
    String? categoryId,
    bool? isActive,
  }) {
    return Product(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      sku: sku ?? this.sku,
      currentStock: currentStock ?? this.currentStock,
      minimumStock: minimumStock ?? this.minimumStock,
      costPrice: costPrice ?? this.costPrice,
      salePrice: salePrice ?? this.salePrice,
      categoryId: categoryId ?? this.categoryId,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        workspaceId,
        name,
        sku,
        currentStock,
        minimumStock,
        costPrice,
        salePrice,
        categoryId,
        isActive,
      ];
}
