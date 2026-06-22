part of '../app_database.dart';

@DriftAccessor(tables: [ProductsTable])
class ProductDao extends DatabaseAccessor<AppDatabase> with _$ProductDaoMixin {
  ProductDao(super.db);

  Future<List<ProductsTableData>> findAll(String workspaceId) {
    return (select(productsTable)
          ..where((table) => table.workspaceId.equals(workspaceId))
          ..orderBy([(table) => OrderingTerm.asc(table.name)]))
        .get();
  }

  Future<ProductsTableData?> findById(String id) {
    return (select(productsTable)..where((table) => table.id.equals(id)))
        .getSingleOrNull();
  }

  Future<ProductsTableData?> findByCode(String code, String workspaceId) {
    return (select(productsTable)
          ..where(
            (table) =>
                table.workspaceId.equals(workspaceId) &
                (table.barcode.equals(code) | table.sku.equals(code)),
          ))
        .getSingleOrNull();
  }

  Future<void> upsert(ProductsTableCompanion product) {
    return into(productsTable).insertOnConflictUpdate(product);
  }

  Future<void> upsertAll(List<ProductsTableCompanion> productsToUpsert) {
    return transaction(() async {
      await batch((batch) {
        batch.insertAllOnConflictUpdate(productsTable, productsToUpsert);
      });
    });
  }

  Future<int> deleteById(String id) {
    return (delete(productsTable)..where((table) => table.id.equals(id))).go();
  }
}
