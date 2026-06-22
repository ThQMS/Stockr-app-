import 'package:equatable/equatable.dart';

import 'movement.dart';

final class RegisterMovementParams extends Equatable {
  const RegisterMovementParams({
    required this.productId,
    required this.workspaceId,
    required this.type,
    required this.quantity,
    this.notes,
    this.referenceCode,
  });

  final String productId;
  final String workspaceId;
  final MovementType type;
  final int quantity;
  final String? notes;
  final String? referenceCode;

  @override
  List<Object?> get props => [
        productId,
        workspaceId,
        type,
        quantity,
        notes,
        referenceCode,
      ];
}
