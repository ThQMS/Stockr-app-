import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/di/injection.dart';
import '../../../inventory/domain/entities/product.dart';
import '../../../inventory/domain/usecases/scan_product_usecase.dart';

part 'scanner_provider.g.dart';

sealed class ScannerState {
  const ScannerState();
}

class ScannerIdle extends ScannerState {
  const ScannerIdle();
}

class ScannerScanning extends ScannerState {
  const ScannerScanning();
}

class ScannerProductFound extends ScannerState {
  const ScannerProductFound(this.product);

  final Product product;
}

class ScannerProductNotFound extends ScannerState {
  const ScannerProductNotFound(this.code);

  final String code;
}

class ScannerOfflineFound extends ScannerState {
  const ScannerOfflineFound(this.product);

  final Product product;
}

@riverpod
class ScannerNotifier extends _$ScannerNotifier {
  @override
  ScannerState build() => const ScannerIdle();

  String? _lastCode;

  Future<void> scan({
    required String code,
    required String workspaceId,
  }) async {
    if (code == _lastCode) {
      return;
    }

    _lastCode = code;
    state = const ScannerScanning();

    final result = await getIt<ScanProductUseCase>()(
      ScanProductParams(code: code, workspaceId: workspaceId),
    );

    state = result.match(
      (failure) => ScannerProductNotFound(code),
      ScannerProductFound.new,
    );
  }

  void reset() {
    _lastCode = null;
    state = const ScannerIdle();
  }
}
