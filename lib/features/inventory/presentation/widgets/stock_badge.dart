import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/value_objects/stock_quantity.dart';

class StockBadge extends StatelessWidget {
  const StockBadge({
    required this.quantity,
    super.key,
  });

  final StockQuantity quantity;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (quantity.value) {
      _ when quantity.status == StockStatus.critical => (
          'Sem estoque',
          AppColors.danger
        ),
      _ when quantity.status == StockStatus.low => (
          'Estoque baixo',
          AppColors.warning
        ),
      _ => ('Em estoque', AppColors.success),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          '$label • ${quantity.value}',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
        ),
      ),
    );
  }
}
