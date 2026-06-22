import 'package:equatable/equatable.dart';

import '../value_objects/money.dart';
import '../value_objects/product_sku.dart';
import '../value_objects/stock_quantity.dart';

final class CreateProductParams extends Equatable {
  const CreateProductParams({
    required this.workspaceId,
    required this.name,
    required this.sku,
    required this.currentStock,
    required this.minimumStock,
    required this.costPrice,
    required this.salePrice,
    required this.categoryId,
    this.barcode,
    this.isActive = true,
  });

  final String workspaceId;
  final String name;
  final ProductSku sku;
  final StockQuantity currentStock;
  final StockQuantity minimumStock;
  final Money costPrice;
  final Money salePrice;
  final String categoryId;
  final String? barcode;
  final bool isActive;

  @override
  List<Object?> get props => [
        workspaceId,
        name,
        sku,
        currentStock,
        minimumStock,
        costPrice,
        salePrice,
        categoryId,
        barcode,
        isActive,
      ];
}

final class UpdateProductParams extends Equatable {
  const UpdateProductParams({
    required this.id,
    this.name,
    this.sku,
    this.currentStock,
    this.minimumStock,
    this.costPrice,
    this.salePrice,
    this.categoryId,
    this.barcode,
    this.isActive,
  });

  final String id;
  final String? name;
  final ProductSku? sku;
  final StockQuantity? currentStock;
  final StockQuantity? minimumStock;
  final Money? costPrice;
  final Money? salePrice;
  final String? categoryId;
  final String? barcode;
  final bool? isActive;

  @override
  List<Object?> get props => [
        id,
        name,
        sku,
        currentStock,
        minimumStock,
        costPrice,
        salePrice,
        categoryId,
        barcode,
        isActive,
      ];
}
