import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/models/history_model.dart';
import '../../../../core/database/models/recent_file_model.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_spacing.dart';

class ToolEntry {
  final String name;
  final String category;
  final String routePath;
  final IconData icon;
  final Color color;
  final List<String> formats;

  const ToolEntry({
    required this.name,
    required this.category,
    required this.routePath,
    required this.icon,
    required this.color,
    required this.formats,
  });
}

// All specific tools for global search
const List<ToolEntry> _allTools = [
  // PDF Tools
  ToolEntry(
      name: 'Image to PDF',
      category: 'PDF Tools',
      routePath: '/home/pdf/imageToPdf',
      icon: Icons.image,
      color: Colors.blue,
      formats: ['pdf', 'jpg', 'png']),
  ToolEntry(
      name: 'PDF to Image',
      category: 'PDF Tools',
      routePath: '/home/pdf/pdfToImage',
      icon: Icons.collections,
      color: Colors.green,
      formats: ['pdf', 'jpg', 'png']),
  ToolEntry(
      name: 'Merge PDF',
      category: 'PDF Tools',
      routePath: '/home/pdf/mergePdf',
      icon: Icons.merge_type,
      color: Colors.orange,
      formats: ['pdf']),
  ToolEntry(
      name: 'Split PDF',
      category: 'PDF Tools',
      routePath: '/home/pdf/splitPdf',
      icon: Icons.call_split,
      color: Colors.red,
      formats: ['pdf']),
  ToolEntry(
      name: 'Compress PDF',
      category: 'PDF Tools',
      routePath: '/home/pdf/compressPdf',
      icon: Icons.compress,
      color: Colors.purple,
      formats: ['pdf']),
  // QR Tools
  ToolEntry(
      name: 'Text to QR',
      category: 'QR Tools',
      routePath: '/home/qr/tool',
      icon: Icons.qr_code,
      color: Colors.deepPurple,
      formats: ['qr', 'png']),
  ToolEntry(
      name: 'Scan QR',
      category: 'QR Tools',
      routePath: '/home/qr/scan',
      icon: Icons.qr_code_scanner,
      color: Colors.deepPurple,
      formats: ['qr']),
  // Image Tools
  ToolEntry(
      name: 'Compress Image',
      category: 'Image Tools',
      routePath: '/home/image/compressImage',
      icon: Icons.compress,
      color: Colors.green,
      formats: ['jpg', 'png', 'webp']),
  ToolEntry(
      name: 'Crop Image',
      category: 'Image Tools',
      routePath: '/home/image/cropImage',
      icon: Icons.crop,
      color: Colors.green,
      formats: ['jpg', 'png', 'webp']),
  ToolEntry(
      name: 'Remove Background',
      category: 'Image Tools',
      routePath: '/home/image/removeBackground',
      icon: Icons.person_remove,
      color: Colors.green,
      formats: ['jpg', 'png', 'webp']),
];

// ---- Search Provider ----
class _SearchResults {
  final List<ToolEntry> tools;
  final List<HistoryItem> history;
  final List<RecentFile> recent;

  const _SearchResults(
      {required this.tools, required this.history, required this.recent});
}

final searchQueryProvider = StateProvider<String>((ref) => '');

final topHistoryProvider = FutureProvider<List<ToolEntry>>((ref) async {
  final history = await db.findAllHistory(limit: 100);

  if (history.isEmpty) return [];

  final Map<String, int> frequencies = {};
  for (final item in history) {
    frequencies[item.toolType] = (frequencies[item.toolType] ?? 0) + 1;
  }

  final sortedKeys = frequencies.keys.toList()
    ..sort((a, b) => frequencies[b]!.compareTo(frequencies[a]!));

  final List<ToolEntry> topTools = [];
  for (final key in sortedKeys.take(5)) {
    final match = _allTools.firstWhere(
      (t) =>
          t.routePath.endsWith(key) ||
          t.name.replaceAll(' ', '').toLowerCase() == key.toLowerCase(),
      orElse: () => _allTools.first,
    );
    if (!topTools.contains(match)) {
      topTools.add(match);
    }
  }
  return topTools;
});

final searchResultsProvider = FutureProvider<_SearchResults>((ref) async {
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  if (query.isEmpty)
    return const _SearchResults(tools: [], history: [], recent: []);

  final tools = _allTools
      .where((t) =>
          t.name.toLowerCase().contains(query) ||
          t.category.toLowerCase().contains(query) ||
          t.formats.any((f) => f.contains(query)))
      .toList();

  final history = await db.searchHistory(query, limit: 10);
  final recent = await db.searchRecentFiles(query, limit: 10);

  return _SearchResults(tools: tools, history: history, recent: recent);
});

// ---- Search Screen ----
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search tools, files, formats...',
            border: InputBorder.none,
            filled: false,
            suffixIcon: query.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      ref.read(searchQueryProvider.notifier).state = '';
                    },
                  )
                : null,
          ),
          onChanged: (val) =>
              ref.read(searchQueryProvider.notifier).state = val,
        ),
      ),
      body: query.isEmpty
          ? const _MostUsedToolsWidget()
          : results.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (r) => _SearchResultsList(results: r),
            ),
    );
  }
}

class _MostUsedToolsWidget extends ConsumerWidget {
  const _MostUsedToolsWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topToolsAsync = ref.watch(topHistoryProvider);

    return topToolsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => const _SearchEmptyState(), // fallback
      data: (topTools) {
        if (topTools.isEmpty) {
          return const _SearchEmptyState();
        }
        return ListView(
          padding: EdgeInsets.all(AppSpacing.md),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.bolt,
                      size: 16, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text('Most Used Conversions',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          )),
                ],
              ),
            ),
            ...topTools.map((t) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: t.color.withValues(alpha: 0.15),
                    child: Icon(t.icon, color: t.color),
                  ),
                  title: Text(t.name),
                  subtitle: Text(t.category),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(t.routePath),
                )),
          ],
        );
      },
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          Text('Search tools, files, or formats',
              style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 8),
          Text('e.g. "PDF", "JPG", "compress"',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )),
        ],
      ),
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  final _SearchResults results;
  const _SearchResultsList({required this.results});

  @override
  Widget build(BuildContext context) {
    if (results.tools.isEmpty &&
        results.history.isEmpty &&
        results.recent.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off,
                size: 64,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            const Text('No results found'),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.all(AppSpacing.md),
      children: [
        if (results.tools.isNotEmpty) ...[
          _sectionHeader(context, 'Tools', Icons.build_outlined),
          ...results.tools.map((t) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: t.color.withValues(alpha: 0.15),
                  child: Icon(t.icon, color: t.color),
                ),
                title: Text(t.name),
                subtitle: Text(t.category),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(t.routePath),
              )),
          const Divider(),
        ],
        if (results.history.isNotEmpty) ...[
          _sectionHeader(context, 'History', Icons.history),
          ...results.history.map((h) => ListTile(
                leading: const CircleAvatar(child: Icon(Icons.transform)),
                title: Text(h.fileName,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(h.toolType),
              )),
          const Divider(),
        ],
        if (results.recent.isNotEmpty) ...[
          _sectionHeader(context, 'Recent Files', Icons.folder_open),
          ...results.recent.map((r) => ListTile(
                leading:
                    const CircleAvatar(child: Icon(Icons.insert_drive_file)),
                title: Text(r.fileName,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              )),
        ],
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  )),
        ],
      ),
    );
  }
}
