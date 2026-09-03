class EngineNotImplementedException implements Exception {
  final String featureName;
  final String message;

  EngineNotImplementedException(this.featureName)
      : message = 'The feature "$featureName" is not supported by the current local PDF engine. Advanced Cloud Engine Required (Coming Soon).';

  @override
  String toString() => message;
}
