import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stockr_app/core/error/failures.dart';
import 'package:stockr_app/core/usecases/usecase.dart';
import 'package:stockr_app/features/inventory/domain/repositories/movement_repository.dart';
import 'package:stockr_app/features/inventory/domain/usecases/sync_pending_movements_usecase.dart';

class _MockMovementRepository extends Mock implements MovementRepository {}

void main() {
  late _MockMovementRepository repository;
  late SyncPendingMovementsUseCase useCase;

  setUp(() {
    repository = _MockMovementRepository();
    useCase = SyncPendingMovementsUseCase(repository);
  });

  test('returns 0 and never syncs when there is nothing pending', () async {
    when(() => repository.getPendingSyncCount())
        .thenAnswer((_) async => const Right(0));

    final result = await useCase(const NoParams());

    expect(result, const Right<Failure, int>(0));
    verify(() => repository.getPendingSyncCount()).called(1);
    verifyNever(() => repository.syncPending());
  });

  test('drains the queue and returns the synced count on success', () async {
    when(() => repository.getPendingSyncCount())
        .thenAnswer((_) async => const Right(3));
    when(() => repository.syncPending())
        .thenAnswer((_) async => const Right(unit));

    final result = await useCase(const NoParams());

    expect(result, const Right<Failure, int>(3));
    verify(() => repository.syncPending()).called(1);
  });

  test('propagates a failure from counting pending items', () async {
    when(() => repository.getPendingSyncCount())
        .thenAnswer((_) async => const Left(CacheFailure()));

    final result = await useCase(const NoParams());

    expect(result.isLeft(), isTrue);
    verifyNever(() => repository.syncPending());
  });

  test('propagates a failure raised while syncing', () async {
    when(() => repository.getPendingSyncCount())
        .thenAnswer((_) async => const Right(2));
    when(() => repository.syncPending())
        .thenAnswer((_) async => const Left(NetworkFailure()));

    final result = await useCase(const NoParams());

    expect(result.isLeft(), isTrue);
  });

  test('wraps an unexpected exception as a ServerFailure', () async {
    when(() => repository.getPendingSyncCount()).thenThrow(Exception('boom'));

    final result = await useCase(const NoParams());

    expect(
      result.getLeft().toNullable(),
      isA<ServerFailure>(),
    );
  });
}
