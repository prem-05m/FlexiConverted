import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flexiconvert/core/database/models/settings_model.dart';
import 'package:flexiconvert/features/settings/presentation/providers/settings_providers.dart';

void main() {
  test('SettingsProvider emits settings correctly', () async {
    final streamController = StreamController<AppSettings>();
    final settings = AppSettings()
      ..themeMode = 'dark'
      ..defaultSaveDirectory = 'Default Downloads';

    // Override the stream provider
    final container = ProviderContainer(
      overrides: [
        settingsProvider.overrideWith((ref) => streamController.stream),
      ],
    );

    // Initial state is loading
    expect(container.read(settingsProvider).isLoading, isTrue);

    // Emit setting
    streamController.add(settings);
    
    // Yield to let stream process
    await Future.delayed(Duration.zero);
    
    final value = container.read(settingsProvider).value;
    expect(value, isNotNull);
    expect(value?.themeMode, 'dark');
    expect(value?.defaultSaveDirectory, 'Default Downloads');
    
    await streamController.close();
  });
}
