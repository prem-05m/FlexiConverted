import 'app_config.dart';

class EnvironmentConfig {
  static late final AppConfig config;

  static void init(Environment env) {
    switch (env) {
      case Environment.dev:
        config = AppConfig(
          environment: env,
          appName: 'FlexiConvert Dev',
          // Auto-detected PC Wi-Fi IP for physical device testing
          baseUrl: 'https://flexiconverted-2.onrender.com',
        );
        break;
      case Environment.staging:
        config = AppConfig(
          environment: env,
          appName: 'FlexiConvert Staging',
          baseUrl: 'https://staging-api.flexiconvert.com',
        );
        break;
      case Environment.prod:
        config = AppConfig(
          environment: env,
          appName: 'FlexiConvert',
          // TODO: Replace with your actual Render deployment URL
          baseUrl: 'https://flexiconverted-2.onrender.com',
        );
        break;
    }
  }
}
