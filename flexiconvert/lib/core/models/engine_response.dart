enum EngineStatus {
  success,
  failure,
  notAvailable,
}

class EngineResponse<T> {
  final EngineStatus status;
  final T? data;
  final String? errorMessage;

  const EngineResponse._({
    required this.status,
    this.data,
    this.errorMessage,
  });

  factory EngineResponse.success(T data) {
    return EngineResponse._(status: EngineStatus.success, data: data);
  }

  factory EngineResponse.failure(String message) {
    return EngineResponse._(
      status: EngineStatus.failure,
      errorMessage: message,
    );
  }

  factory EngineResponse.notAvailable([String? featureName]) {
    final msg = featureName != null 
      ? 'The feature "$featureName" is not supported by the current engine. Advanced Cloud Engine Required.'
      : 'This feature is not supported by the current engine.';
    return EngineResponse._(
      status: EngineStatus.notAvailable,
      errorMessage: msg,
    );
  }
  
  bool get isSuccess => status == EngineStatus.success;
  bool get isNotAvailable => status == EngineStatus.notAvailable;
}
