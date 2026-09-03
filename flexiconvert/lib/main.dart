import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';

import 'core/config/app_config.dart';
import 'core/config/environment.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/database/database_provider.dart';
import 'core/network/api_client.dart';
import 'core/services/snackbar_service.dart';
import 'firebase_options.dart';
import 'features/settings/presentation/providers/settings_providers.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      await windowManager.ensureInitialized();
      WindowOptions windowOptions = const WindowOptions(
        size: Size(450, 850),
        minimumSize: Size(400, 700),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.normal,
      );
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    }

    // Initialize Environment
    EnvironmentConfig.init(Environment.dev);

    // Initialize Firebase
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      debugPrint('Firebase initialization error: $e');
      debugPrint('Please add google-services.json. See REMAINING_MANUAL_CONFIGURATION.md');
    }

    // Initialize Database (Isar on native, in-memory on web)
    await initDatabase();

    // Initialize API Client
    ApiClient.init();

    runApp(const ProviderScope(child: FlexiConvertApp()));
  } catch (e, stackTrace) {
    debugPrint('Fatal Error during initialization: $e\n$stackTrace');
    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.red,
          body: SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Initialization Error:\n$e\n\n$stackTrace',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FlexiConvertApp extends ConsumerWidget {
  const FlexiConvertApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final router = ref.watch(routerProvider);

    final themeMode = settingsAsync.maybeWhen(
      data: (s) {
        switch (s.themeMode) {
          case 'light':
            return ThemeMode.light;
          case 'dark':
            return ThemeMode.dark;
          default:
            return ThemeMode.system;
        }
      },
      orElse: () => ThemeMode.system,
    );

    Size getDesignSize() {
      if (kIsWeb) {
        final view = View.of(context);
        final size = view.physicalSize / view.devicePixelRatio;
        // Fallback to a standard desktop size if view size is somehow 0
        return size.width > 0 ? size : const Size(1440, 900);
      }
      return const Size(AppConstants.designWidth, AppConstants.designHeight);
    }

    return ScreenUtilInit(
      designSize: getDesignSize(),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return DynamicColorBuilder(
          builder: (lightDynamic, darkDynamic) {
            return MaterialApp.router(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              routerConfig: router,
              scaffoldMessengerKey: SnackbarService.scaffoldMessengerKey,
              theme: AppTheme.lightTheme(lightDynamic),
              darkTheme: AppTheme.darkTheme(darkDynamic),
              themeMode: themeMode,
            );
          },
        );
      },
    );
  }
}
