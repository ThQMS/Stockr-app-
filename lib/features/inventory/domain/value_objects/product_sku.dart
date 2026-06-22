import 'package:equatable/equatable.dart';

final class ProductSku extends Equatable {
  ProductSku(String value) : value = value.trim().toUpperCase();

  final String value;

  bool get isValid => value.length >= 3;

  @override
  List<Object?> get props => [value];
}
