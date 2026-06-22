import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';
part 'daos/movement_dao.dart';
part 'daos/product_dao.dart';

@DriftDatabase(
  tables: [
    ProductsTable,
    MovementsTable,
    PendingSyncTable,
    CategoriesTable,
  ],
  daos: [ProductDao, MovementDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // Future migrations live here.
        },
      );
}

class ProductsTable extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text()();
  TextColumn get name => text()();
  TextColumn get sku => text()();
  TextColumn get barcode => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  IntColumn get currentStock => integer().withDefault(const Constant(0))();
  IntColumn get minimumStock => integer().withDefault(const Constant(0))();
  IntColumn get costPriceCents => integer().withDefault(const Constant(0))();
  IntColumn get salePriceCents => integer().withDefault(const Constant(0))();
  TextColumn get unit => text().withDefault(const Constant('un'))();
  TextColumn get status => text().withDefault(const Constant('active'))();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class MovementsTable extends Table {
  TextColumn get id => text()();
  TextColumn get productId => text()();
  TextColumn get workspaceId => text()();
  TextColumn get type => text()();
  IntColumn get quantity => integer()();
  IntColumn get quantityBefore => integer()();
  IntColumn get quantityAfter => integer()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  DateTimeColumn get movedAt => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class PendingSyncTable extends Table {
  TextColumn get id => text()();
  TextColumn get endpoint => text()();
  TextColumn get method => text()();
  TextColumn get body => text()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class CategoriesTable extends Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text()();
  TextColumn get name => text()();
  TextColumn get parentId => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'stockr_app');
}
