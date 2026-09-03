import 'app_config.dart';

class EnvironmentConfig {
  static late final AppConfig config;

  static void init(Environment env) {
    switch (env) {
      case Environment.dev:
        config = AppConfig(
          environment: env,
          appName: 'FlexiConvert Dev',
          // 10.0.2.2 is the localhost alias for the Android Emulator
          baseUrl: 'http://10.0.2.2:3000',
        );
        break;
      case Environment.staging:
        config = AppConfig(
          environment: env,
          appName: 'FlexiConvert Staging',
          baseUrl: 'https://staging.api.flexiconvert.com',
        );
        break;
      case Environment.prod:
        config = AppConfig(
          environment: env,
          appName: 'FlexiConvert',
          baseUrl: 'https://api.flexiconvert.com',
        );
        break;
    }
  }
}
