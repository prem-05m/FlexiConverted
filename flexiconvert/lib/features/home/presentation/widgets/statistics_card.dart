import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';

// Provider for real statistics
final conversionStatsProvider = StreamProvider<_ConversionStats>((ref) async* {
  yield* db.watchSuccessfulHistory().map((items) {
    final totalConversions = items.length;
    final storageSavedBytes =
        items.fold<int>(0, (sum, item) => sum + item.fileSizeBytes);
    final timeSavedMs =
        items.fold<int>(0, (sum, item) => sum + item.durationMs);
    return _ConversionStats(
      total: totalConversions,
      storageSavedBytes: storageSavedBytes,
      timeSavedMs: timeSavedMs,
    );
  });
});

class _ConversionStats {
  final int total;
  final int storageSavedBytes;
  final int timeSavedMs;

  _ConversionStats({
    required this.total,
    required this.storageSavedBytes,
    required this.timeSavedMs,
  });
}

class StatisticsCard extends ConsumerWidget {
  const StatisticsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(conversionStatsProvider);

    return stats.when(
      loading: () => const GlassCard(
        padding: EdgeInsets.all(20),
        child: Center(heightFactor: 1.5, child: CircularProgressIndicator()),
      ),
      error: (_, __) => const GlassCard(
        padding: EdgeInsets.all(20),
        child: Center(child: Text('Could not load stats')),
      ),
      data: (s) => GlassCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(child: _buildStat(context, 'Total Converted', '${s.total}',
                Icons.swap_calls, AppColors.brandPrimary)),
            Container(
                width: 1,
                height: 40,
                color: context.colorScheme.outlineVariant),
            Expanded(child: _buildStat(
                context,
                'Storage Saved',
                _formatBytes(s.storageSavedBytes),
                Icons.save_alt,
                Colors.green)),
            Container(
                width: 1,
                height: 40,
                color: context.colorScheme.outlineVariant),
            Expanded(child: _buildStat(context, 'Time Saved', _formatTime(s.timeSavedMs),
                Icons.timer, Colors.orange)),
          ],
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = 0;
    double val = bytes.toDouble();
    while (val >= 1024 && i < suffixes.length - 1) {
      val /= 1024;
      i++;
    }
    return '${val.toStringAsFixed(1)} ${suffixes[i]}';
  }

  String _formatTime(int ms) {
    if (ms <= 0) return '0 min';
    final minutes = ms ~/ 60000;
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    return '${hours}h';
  }

  Widget _buildStat(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: context.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: context.textTheme.labelSmall
              ?.copyWith(color: context.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
