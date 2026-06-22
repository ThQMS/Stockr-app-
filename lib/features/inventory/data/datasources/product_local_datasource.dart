import '../../../../core/database/app_database.dart' as db;
import '../../domain/entities/product_filters.dart';
import '../models/product_model.dart';

abstract interface class ProductLocalDataSource {
  Future<List<ProductModel>> getProducts({
    required String workspaceId,
    ProductFilters? filters,
  });
  Future<ProductModel?> getById(String id);
  Future<ProductModel?> findByCode(String code, String workspaceId);
  Future<void> upsert(ProductModel product);
  Future<void> upsertAll(List<ProductModel> products);
  Future<void> delete(String id);
}

final class DriftProductLocalDataSource implements ProductLocalDataSource {
  const DriftProductLocalDataSource(this._database);

  final db.AppDatabase _database;

  @override
  Future<List<ProductModel>> getProducts({
    required String workspaceId,
    ProductFilters? filters,
  }) async {
    final rows = await _database.productDao.findAll(workspaceId);
    return rows.map(_mapProduct).where((product) {
      final query = filters?.query?.trim().toLowerCase();
      final matchesQuery = query == null || query.isEmpty
          ? true
          : product.name.toLowerCase().contains(query) ||
              product.sku.toLowerCase().contains(query) ||
              (product.barcode?.toLowerCase().contains(query) ?? false);
      final matchesCategory = filters?.categoryId == null
          ? true
          : product.categoryId == filters!.categoryId;
      final matchesActive = filters?.onlyActive == null
          ? true
          : (product.status == 'active') == filters!.onlyActive;
      final matchesLowStock = filters?.onlyLowStock == true
          ? product.currentStock < product.minimumStock
          : true;

      return matchesQuery &&
          matchesCategory &&
          matchesActive &&
          matchesLowStock;
    }).toList();
  }

  @override
  Future<ProductModel?> getById(String id) async {
    final row = await _database.productDao.findById(id);
    return row == null ? null : _mapProduct(row);
  }

  @override
  Future<ProductModel?> findByCode(String code, String workspaceId) async {
    final row = await _database.productDao.findByCode(code, workspaceId);
    return row == null ? null : _mapProduct(row);
  }

  @override
  Future<void> upsert(ProductModel product) {
    return _database.productDao.upsert(product.toDrift());
  }

  @override
  Future<void> upsertAll(List<ProductModel> products) {
    return _database.productDao.upsertAll(
      products.map((product) => product.toDrift()).toList(),
    );
  }

  @override
  Future<void> delete(String id) async {
    await _database.productDao.deleteById(id);
  }

  ProductModel _mapProduct(db.ProductsTableData row) {
    return ProductModel.fromDrift(row);
  }
}
