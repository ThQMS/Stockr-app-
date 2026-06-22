import 'package:flutter/material.dart';

import '../../domain/entities/movement.dart';

class MovementTile extends StatelessWidget {
  const MovementTile({
    required this.movement,
    super.key,
  });

  final Movement movement;

  @override
  Widget build(BuildContext context) {
    final icon = switch (movement.type) {
      MovementType.inbound => Icons.south_west,
      MovementType.out => Icons.north_east,
      MovementType.adjustment => Icons.tune,
      MovementType.transfer => Icons.compare_arrows,
    };

    return ListTile(
      leading: Icon(icon),
      title: Text('${movement.quantity} unidades'),
      subtitle: Text(movement.note ?? movement.occurredAt.toIso8601String()),
    );
  }
}
