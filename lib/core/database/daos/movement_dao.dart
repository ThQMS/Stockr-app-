part of '../app_database.dart';

@DriftAccessor(tables: [MovementsTable, PendingSyncTable])
class MovementDao extends DatabaseAccessor<AppDatabase>
    with _$MovementDaoMixin {
  MovementDao(super.db);

  Future<List<MovementsTableData>> findByProduct(String productId) {
    return (select(movementsTable)
          ..where((table) => table.productId.equals(productId))
          ..orderBy([(table) => OrderingTerm.desc(table.movedAt)]))
        .get();
  }

  Future<List<MovementsTableData>> findByWorkspace(String workspaceId) {
    return (select(movementsTable)
          ..where((table) => table.workspaceId.equals(workspaceId))
          ..orderBy([(table) => OrderingTerm.desc(table.movedAt)]))
        .get();
  }

  Future<void> insertMovement(MovementsTableCompanion movement) {
    return into(movementsTable).insert(movement);
  }

  Future<int> countPendingSync() async {
    final countExpression = pendingSyncTable.id.count();
    final query = selectOnly(pendingSyncTable)
      ..addColumns([countExpression])
      ..where(pendingSyncTable.method.isNotNull());

    final row = await query.getSingle();
    return row.read(countExpression) ?? 0;
  }

  Future<List<PendingSyncTableData>> findPendingSyncInOrder() {
    return (select(pendingSyncTable)
          ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]))
        .get();
  }

  Future<void> deletePendingSync(String id) {
    return (delete(pendingSyncTable)..where((table) => table.id.equals(id)))
        .go();
  }
}
