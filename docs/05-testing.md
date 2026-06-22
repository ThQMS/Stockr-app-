# 05 · Testing

```sh
flutter test                 # run everything
flutter test --coverage      # with coverage -> coverage/lcov.info
flutter test test/value_objects_test.dart   # a single file
```

## What's covered

| Area | File | Why it matters |
|------|------|----------------|
| Value objects | `test/value_objects_test.dart` | Pure domain rules — SKU normalization, stock status |
| Sync logic | `test/sync_pending_movements_test.dart` | The heart of the app: queue draining + failure propagation |
| Widgets | `test/widget/` | Key screens render and react to state |

## Conventions

- **Mirror the `lib/` path** under `test/` so a test is easy to locate.
- **Mock at the boundary** with [`mocktail`](https://pub.dev/packages/mocktail)
  — fake the repository, exercise the use case. Domain tests need no Flutter
  binding.
- **Test behaviour, not implementation.** Assert on the `Either<Failure, T>`
  result of a use case, not on private calls.
- **Deterministic.** No real network, no real database in unit tests; inject
  fakes. Use an in-memory Drift database (`NativeDatabase.memory()`) when a real
  DAO is under test.

## Example — use-case test with mocktail

```dart
class _MockMovementRepository extends Mock implements MovementRepository {}

void main() {
  late _MockMovementRepository repository;
  late SyncPendingMovementsUseCase useCase;

  setUp(() {
    repository = _MockMovementRepository();
    useCase = SyncPendingMovementsUseCase(repository);
  });

  test('returns the count of synced items on success', () async {
    when(() => repository.getPendingSyncCount())
        .thenAnswer((_) async => const Right(3));
    when(() => repository.syncPending())
        .thenAnswer((_) async => const Right(unit));

    final result = await useCase(const NoParams());

    expect(result, const Right(3));
  });
}
```

## CI

Every push and pull request runs `dart format --set-exit-if-changed`,
`flutter analyze` and `flutter test` on a pinned Flutter version — see
[`.github/workflows/ci.yml`](../.github/workflows/ci.yml).
