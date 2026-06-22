class ServerException implements Exception {
  const ServerException(this.message, {this.code, this.statusCode});

  final String message;
  final String? code;
  final int? statusCode;

  @override
  String toString() {
    return 'ServerException(code: $code, statusCode: $statusCode, message: $message)';
  }
}

class CacheException implements Exception {
  const CacheException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => 'CacheException(code: $code, message: $message)';
}

class UnauthorizedException implements Exception {
  const UnauthorizedException([this.message = 'Unauthorized']);

  final String message;

  @override
  String toString() => 'UnauthorizedException(message: $message)';
}

class NetworkException implements Exception {
  const NetworkException([this.message = 'No internet connection']);

  final String message;

  @override
  String toString() => 'NetworkException(message: $message)';
}

class NotFoundException implements Exception {
  const NotFoundException([this.message = 'Not found']);

  final String message;

  @override
  String toString() => 'NotFoundException(message: $message)';
}
