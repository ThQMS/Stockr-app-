import 'package:equatable/equatable.dart';

import 'movement.dart';

final class MovementFilters extends Equatable {
  const MovementFilters({
    this.type,
    this.from,
    this.to,
  });

  final MovementType? type;
  final DateTime? from;
  final DateTime? to;

  @override
  List<Object?> get props => [type, from, to];
}
