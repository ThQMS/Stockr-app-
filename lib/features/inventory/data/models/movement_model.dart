import '../../domain/entities/movement.dart';

final class MovementModel extends Movement {
  const MovementModel({
    required super.id,
    required super.productId,
    required super.workspaceId,
    required super.type,
    required super.quantity,
    required super.occurredAt,
    super.note,
  });

  factory MovementModel.fromJson(Map<String, dynamic> json) {
    return MovementModel(
      id: json['id'] as String,
      productId: json['productId'] as String,
      workspaceId: json['workspaceId'] as String? ?? '',
      type: MovementType.values.byName(json['type'] as String),
      quantity: json['quantity'] as int,
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      note: json['note'] as String?,
    );
  }

  factory MovementModel.fromEntity(Movement movement) {
    return MovementModel(
      id: movement.id,
      productId: movement.productId,
      workspaceId: movement.workspaceId,
      type: movement.type,
      quantity: movement.quantity,
      occurredAt: movement.occurredAt,
      note: movement.note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'workspaceId': workspaceId,
      'type': type.name,
      'quantity': quantity,
      'occurredAt': occurredAt.toIso8601String(),
      'note': note,
    };
  }
}
