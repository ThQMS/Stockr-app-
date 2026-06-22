import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/movement.dart';
import '../../domain/entities/movement_params.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_pending_sync_count_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/register_movement_usecase.dart';

part 'products_provider.g.dart';

const defaultWorkspaceId = 'default';

@riverpod
class ProductsNotifier extends _$ProductsNotifier {
  @override
  Future<List<Product>> build({required String workspaceId}) async {
    final useCase = getIt<GetProductsUseCase>();
    final result = await useCase(GetProductsParams(workspaceId: workspaceId));

    return result.match(
      (failure) => throw _mapFailureToException(failure),
      (products) => products,
    );
  }

  Future<void> refresh() async {
    final refreshed = ref.refresh(
      productsNotifierProvider(workspaceId: workspaceId).future,
    );
    await refreshed;
  }
}

@riverpod
class MovementNotifier extends _$MovementNotifier {
  @override
  Future<Movement?> build() async => null;

  Future<void> register(RegisterMovementParams params) async {
    state = const AsyncLoading();

    final result = await getIt<RegisterMovementUseCase>()(params);
    result.match(
      (failure) {
        state = AsyncError(_mapFailureToException(failure), StackTrace.current);
      },
      (movement) {
        state = AsyncData(movement);
        ref.invalidate(productsNotifierProvider);
        ref.invalidate(pendingSyncCountProvider);
      },
    );
  }
}

@riverpod
Future<int> pendingSyncCount(PendingSyncCountRef ref) async {
  final result = await getIt<GetPendingSyncCountUseCase>()(const NoParams());
  return result.match(
    (failure) => throw _mapFailureToException(failure),
    (count) => count,
  );
}

Exception _mapFailureToException(Failure failure) {
  return _FailureException(failure.message);
}

final class _FailureException implements Exception {
  const _FailureException(this.message);

  final String message;

  @override
  String toString() => message;
}
