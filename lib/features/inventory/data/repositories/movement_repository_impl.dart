import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/database/app_database.dart' as db;
import '../../../../core/error/failures.dart';
import '../../domain/entities/movement.dart';
import '../../domain/entities/movement_filters.dart';
import '../../domain/entities/movement_params.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/movement_model.dart';

final class MovementRepositoryImpl implements MovementRepository {
  const MovementRepositoryImpl(this._database);

  final db.AppDatabase _database;

  @override
  Future<Either<Failure, Movement>> register(
    RegisterMovementParams params,
  ) async {
    final model = MovementModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      productId: params.productId,
      workspaceId: params.workspaceId,
      type: params.type,
      quantity: params.quantity,
      occurredAt: DateTime.now(),
      note: params.notes,
    );

    await _database.movementDao.insertMovement(
      db.MovementsTableCompanion.insert(
        id: model.id,
        productId: model.productId,
        workspaceId: model.workspaceId,
        type: model.type.name,
        quantity: model.quantity,
        quantityBefore: 0,
        quantityAfter: model.quantity,
        movedAt: model.occurredAt,
        createdAt: DateTime.now(),
        notes: Value(model.note),
      ),
    );

    return Right(model);
  }

  @override
  Future<Either<Failure, List<Movement>>> getByProduct(String productId) async {
    final rows = await _database.movementDao.findByProduct(productId);
    return Right(rows.map(_mapMovement).toList());
  }

  @override
  Future<Either<Failure, List<Movement>>> getByWorkspace({
    required String workspaceId,
    MovementFilters? filters,
  }) async {
    final rows = await _database.movementDao.findByWorkspace(workspaceId);
    final movements = rows.map(_mapMovement).where((movement) {
      final matchesType =
          filters?.type == null ? true : movement.type == filters!.type;
      final matchesFrom = filters?.from == null
          ? true
          : !movement.occurredAt.isBefore(filters!.from!);
      final matchesTo = filters?.to == null
          ? true
          : !movement.occurredAt.isAfter(filters!.to!);

      return matchesType && matchesFrom && matchesTo;
    }).toList();

    return Right(movements);
  }

  @override
  Future<Either<Failure, int>> getPendingSyncCount() async {
    return Right(await _database.movementDao.countPendingSync());
  }

  @override
  Future<Either<Failure, Unit>> syncPending() async {
    final pending = await _database.movementDao.findPendingSyncInOrder();
    for (final item in pending) {
      await _database.movementDao.deletePendingSync(item.id);
    }
    return const Right(unit);
  }

  MovementModel _mapMovement(db.MovementsTableData row) {
    return MovementModel.fromJson({
      'id': row.id,
      'productId': row.productId,
      'workspaceId': row.workspaceId,
      'type': row.type,
      'quantity': row.quantity,
      'occurredAt': row.movedAt.toIso8601String(),
      'note': row.notes,
    });
  }
}
