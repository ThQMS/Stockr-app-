import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

final class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});

  @override
  List<Object> get props => [message, statusCode ?? 0];
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local cache error']);
}

final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

final class InsufficientStockFailure extends Failure {
  final int available;
  final int requested;
  const InsufficientStockFailure({
    required this.available,
    required this.requested,
  }) : super('Insufficient stock: $available available, $requested requested');

  @override
  List<Object> get props => [message, available, requested];
}

final class ValidationFailure extends Failure {
  final Map<String, List<String>> errors;
  const ValidationFailure(super.message, {required this.errors});
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message);
}
