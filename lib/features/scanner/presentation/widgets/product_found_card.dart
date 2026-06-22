import 'package:flutter/material.dart';

import '../../../inventory/domain/entities/product.dart';
import '../../../inventory/presentation/widgets/stock_badge.dart';

class ProductFoundCard extends StatelessWidget {
  const ProductFoundCard({
    required this.product,
    super.key,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(product.sku.value),
                ],
              ),
            ),
            StockBadge(quantity: product.currentStock),
          ],
        ),
      ),
    );
  }
}
