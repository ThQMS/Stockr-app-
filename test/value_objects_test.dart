import 'package:flutter_test/flutter_test.dart';
import 'package:stockr_app/features/inventory/domain/value_objects/product_sku.dart';
import 'package:stockr_app/features/inventory/domain/value_objects/stock_quantity.dart';

void main() {
  test('normalizes product SKU', () {
    expect(ProductSku(' abc-123 ').value, 'ABC-123');
  });

  test('detects low and out of stock quantities', () {
    expect(StockQuantity.zero.status, StockStatus.critical);
    expect(StockQuantity.of(4).isBelow(StockQuantity.of(5)), isTrue);
    expect(StockQuantity.of(12).isBelow(StockQuantity.of(5)), isFalse);
  });
}
