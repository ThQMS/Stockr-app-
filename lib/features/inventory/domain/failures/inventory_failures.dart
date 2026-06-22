import '../../../../core/error/failures.dart';

NotFoundFailure productNotFoundFailure() {
  return const NotFoundFailure('Product not found');
}

ValidationFailure invalidSkuFailure() {
  return const ValidationFailure(
    'Invalid product SKU',
    errors: {
      'sku': ['Invalid product SKU'],
    },
  );
}
