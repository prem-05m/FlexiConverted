import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../settings/presentation/providers/settings_providers.dart';

class FirstRunSetupDialog extends ConsumerStatefulWidget {
  const FirstRunSetupDialog({super.key});

  @override
  ConsumerState<FirstRunSetupDialog> createState() => _FirstRunSetupDialogState();
}

class _FirstRunSetupDialogState extends ConsumerState<FirstRunSetupDialog> {
  String _storageOption = 'Ask Every Time';
  String _customPath = '';
  String _multipleOption = 'ask';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Welcome to FlexiConvert!'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please configure your preferred settings before starting.'),
            SizedBox(height: AppSpacing.lg),
            
            Text('Default Save Location', style: context.textTheme.titleMedium),
            RadioListTile<String>(
              title: const Text('Ask Every Time'),
              value: 'Ask Every Time',
              groupValue: _storageOption,
              onChanged: (val) => setState(() => _storageOption = val!),
            ),
            RadioListTile<String>(
              title: const Text('Default Downloads Folder'),
              value: 'Default Downloads',
              groupValue: _storageOption,
              onChanged: (val) => setState(() => _storageOption = val!),
            ),
            RadioListTile<String>(
              title: const Text('Custom Folder'),
              value: 'Custom',
              groupValue: _storageOption,
              onChanged: (val) async {
                setState(() => _storageOption = val!);
                if (val == 'Custom') {
                  final dir = await FilePicker.getDirectoryPath();
                  if (dir != null) {
                    setState(() => _customPath = dir);
                  } else {
                    setState(() => _storageOption = 'Ask Every Time');
                  }
                }
              },
            ),
            if (_storageOption == 'Custom' && _customPath.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                child: Text('Selected: $_customPath', style: TextStyle(color: context.colorScheme.primary, fontSize: 12)),
              ),
              
            SizedBox(height: AppSpacing.lg),
            
            Text('Multiple File Download Preference', style: context.textTheme.titleMedium),
            RadioListTile<String>(
              title: const Text('Ask Every Time'),
              value: 'ask',
              groupValue: _multipleOption,
              onChanged: (val) => setState(() => _multipleOption = val!),
            ),
            RadioListTile<String>(
              title: const Text('Save as ZIP Archive'),
              value: 'zip',
              groupValue: _multipleOption,
              onChanged: (val) => setState(() => _multipleOption = val!),
            ),
            RadioListTile<String>(
              title: const Text('Save Individually in Folder'),
              value: 'folder',
              groupValue: _multipleOption,
              onChanged: (val) => setState(() => _multipleOption = val!),
            ),
          ],
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () async {
            final saveDir = _storageOption == 'Custom' ? _customPath : _storageOption;
            
            final notifier = ref.read(settingsNotifierProvider);
            await notifier.updateSaveDirectory(saveDir);
            await notifier.updateMultipleFileDownloadPref(_multipleOption);
            
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isFirstRun', false);
            
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Get Started'),
        ),
      ],
    );
  }
}
