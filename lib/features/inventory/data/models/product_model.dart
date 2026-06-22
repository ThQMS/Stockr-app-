import 'package:drift/drift.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/product.dart';
import '../../domain/value_objects/money.dart';
import '../../domain/value_objects/product_sku.dart';
import '../../domain/value_objects/stock_quantity.dart';

final class ProductModel extends Equatable {
  const ProductModel({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.sku,
    required this.currentStock,
    required this.minimumStock,
    required this.costPriceCents,
    required this.salePriceCents,
    required this.unit,
    required this.status,
    required this.isSynced,
    required this.updatedAt,
    this.barcode,
    this.categoryId,
    this.syncedAt,
  });

  final String id;
  final String workspaceId;
  final String name;
  final String sku;
  final String? barcode;
  final String? categoryId;
  final int currentStock;
  final int minimumStock;
  final int costPriceCents;
  final int salePriceCents;
  final String unit;
  final String status;
  final bool isSynced;
  final DateTime updatedAt;
  final DateTime? syncedAt;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      workspaceId: json['workspaceId'] as String? ?? '',
      name: json['name'] as String,
      sku: json['sku'] as String,
      barcode: json['barcode'] as String?,
      categoryId: json['categoryId'] as String?,
      currentStock:
          json['currentStock'] as int? ?? json['quantity'] as int? ?? 0,
      minimumStock: json['minimumStock'] as int? ?? 0,
      costPriceCents: json['costPriceCents'] as int? ?? 0,
      salePriceCents:
          json['salePriceCents'] as int? ?? json['priceCents'] as int? ?? 0,
      unit: json['unit'] as String? ?? 'un',
      status: json['status'] as String? ??
          ((json['isActive'] as bool? ?? true) ? 'active' : 'inactive'),
      isSynced: json['isSynced'] as bool? ?? true,
      updatedAt: json['updatedAt'] == null
          ? DateTime.now()
          : DateTime.parse(json['updatedAt'] as String),
      syncedAt: json['syncedAt'] == null
          ? null
          : DateTime.parse(json['syncedAt'] as String),
    );
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      workspaceId: product.workspaceId,
      name: product.name,
      sku: product.sku.value,
      categoryId: product.categoryId.isEmpty ? null : product.categoryId,
      currentStock: product.currentStock.value,
      minimumStock: product.minimumStock.value,
      costPriceCents: product.costPrice.cents,
      salePriceCents: product.salePrice.cents,
      unit: 'un',
      status: product.isActive ? 'active' : 'inactive',
      isSynced: true,
      updatedAt: DateTime.now(),
    );
  }

  factory ProductModel.fromDrift(ProductsTableData row) {
    return ProductModel(
      id: row.id,
      workspaceId: row.workspaceId,
      name: row.name,
      sku: row.sku,
      barcode: row.barcode,
      categoryId: row.categoryId,
      currentStock: row.currentStock,
      minimumStock: row.minimumStock,
      costPriceCents: row.costPriceCents,
      salePriceCents: row.salePriceCents,
      unit: row.unit,
      status: row.status,
      isSynced: row.isSynced,
      updatedAt: row.updatedAt,
      syncedAt: row.syncedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workspaceId': workspaceId,
      'name': name,
      'sku': sku,
      'barcode': barcode,
      'categoryId': categoryId,
      'currentStock': currentStock,
      'minimumStock': minimumStock,
      'costPriceCents': costPriceCents,
      'salePriceCents': salePriceCents,
      'unit': unit,
      'status': status,
      'isSynced': isSynced,
      'updatedAt': updatedAt.toIso8601String(),
      'syncedAt': syncedAt?.toIso8601String(),
    };
  }

  ProductsTableCompanion toDrift() {
    return ProductsTableCompanion.insert(
      id: id,
      workspaceId: workspaceId,
      name: name,
      sku: sku,
      updatedAt: updatedAt,
      barcode: Value(barcode),
      categoryId: Value(categoryId),
      currentStock: Value(currentStock),
      minimumStock: Value(minimumStock),
      costPriceCents: Value(costPriceCents),
      salePriceCents: Value(salePriceCents),
      unit: Value(unit),
      status: Value(status),
      isSynced: Value(isSynced),
      syncedAt: Value(syncedAt),
    );
  }

  Product toDomain() {
    return Product(
      id: id,
      workspaceId: workspaceId,
      name: name,
      sku: ProductSku(sku),
      currentStock: StockQuantity.of(currentStock),
      minimumStock: StockQuantity.of(minimumStock),
      costPrice: Money.fromCents(costPriceCents),
      salePrice: Money.fromCents(salePriceCents),
      categoryId: categoryId ?? '',
      isActive: status == 'active',
    );
  }

  @override
  List<Object?> get props => [
        id,
        workspaceId,
        name,
        sku,
        barcode,
        categoryId,
        currentStock,
        minimumStock,
        costPriceCents,
        salePriceCents,
        unit,
        status,
        isSynced,
        updatedAt,
        syncedAt,
      ];
}
