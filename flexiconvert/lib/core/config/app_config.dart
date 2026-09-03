enum Environment {
  dev,
  staging,
  prod,
}

class AppConfig {
  final Environment environment;
  final String appName;
  final String baseUrl;

  AppConfig({
    required this.environment,
    required this.appName,
    required this.baseUrl,
  });

  bool get isDevelopment => environment == Environment.dev;
  bool get isProduction => environment == Environment.prod;
}
