import 'package:equatable/equatable.dart';

enum MovementType { inbound, out, adjustment, transfer }

class Movement extends Equatable {
  const Movement({
    required this.id,
    required this.productId,
    required this.workspaceId,
    required this.type,
    required this.quantity,
    required this.occurredAt,
    this.note,
  });

  final String id;
  final String productId;
  final String workspaceId;
  final MovementType type;
  final int quantity;
  final DateTime occurredAt;
  final String? note;

  @override
  List<Object?> get props => [
        id,
        productId,
        workspaceId,
        type,
        quantity,
        occurredAt,
        note,
      ];
}
