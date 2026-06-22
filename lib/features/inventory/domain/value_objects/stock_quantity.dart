import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';

final class StockQuantity extends Equatable {
  const StockQuantity._(this.value);

  final int value;

  factory StockQuantity.of(int value) {
    if (value < 0) {
      throw ArgumentError('StockQuantity cannot be negative');
    }
    return StockQuantity._(value);
  }

  static const zero = StockQuantity._(0);

  StockQuantity add(StockQuantity other) => StockQuantity._(value + other.value);

  Either<InsufficientStockFailure, StockQuantity> subtract(
    StockQuantity other,
  ) {
    if (value < other.value) {
      return Left(
        InsufficientStockFailure(available: value, requested: other.value),
      );
    }
    return Right(StockQuantity._(value - other.value));
  }

  bool isBelow(StockQuantity minimum) => value < minimum.value;

  StockStatus get status {
    return this == zero
        ? StockStatus.critical
        : value <= value ~/ 4
            ? StockStatus.low
            : StockStatus.ok;
  }

  @override
  List<Object> get props => [value];
}

enum StockStatus { ok, low, critical }
