class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() {
    return 'AppException: $message ${code != null ? '($code)' : ''}';
  }
}

class NetworkException extends AppException {
  NetworkException(super.message, {super.code, super.details});
}

class CacheException extends AppException {
  CacheException(super.message, {super.code, super.details});
}

class ConversionException extends AppException {
  ConversionException(super.message, {super.code, super.details});
}

class PermissionException extends AppException {
  PermissionException(super.message, {super.code, super.details});
}
