import 'package:flutter/material.dart';

import '../domain/entities/catalog_definition.dart';
import '../domain/entities/catalog_entry_definition.dart';

class CatalogEntryDetailPage extends StatelessWidget {
  final CatalogDefinition catalog;
  final CatalogEntryDefinition entry;

  const CatalogEntryDetailPage({super.key, required this.catalog, required this.entry});

  @override
  Widget build(BuildContext context) {
    final image = entry.imageUrl?.trim();
    final flag = countryCodeToFlag(entry.countryCode) ?? countryNameToFlag(entry.attributes['Страна'] ?? entry.primaryValue);
    return Scaffold(
      appBar: AppBar(title: Text(entry.title, maxLines: 2, overflow: TextOverflow.ellipsis)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          AspectRatio(
            aspectRatio: 1.35,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: flag != null
                  ? ColoredBox(color: Theme.of(context).colorScheme.surfaceContainerHighest, child: Center(child: Text(flag, style: const TextStyle(fontSize: 92))))
                  : image != null && image.isNotEmpty
                      ? Image.network(image, fit: BoxFit.contain, errorBuilder: (_, __, ___) => const _NoImage())
                      : const _NoImage(),
            ),
          ),
          const SizedBox(height: 20),
          Text(entry.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          if (entry.subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(entry.subtitle, style: Theme.of(context).textTheme.titleMedium),
          ],
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Информация', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                _InfoRow(label: 'Каталог', value: catalog.name),
                _InfoRow(label: 'Основное значение', value: entry.primaryValue),
                for (final item in entry.attributes.entries) _InfoRow(label: item.key, value: item.value),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 125, child: Text(label, style: Theme.of(context).textTheme.labelLarge)), Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyLarge))]));
}

class _NoImage extends StatelessWidget {
  const _NoImage();
  @override
  Widget build(BuildContext context) => ColoredBox(color: Theme.of(context).colorScheme.surfaceContainerHighest, child: Center(child: Text('NO IMAGES', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800))));
}

String? countryCodeToFlag(String? code) {
  if (code == null || code.trim().length != 2) return null;
  final normalized = code.trim().toUpperCase();
  final first = normalized.codeUnitAt(0);
  final second = normalized.codeUnitAt(1);
  if (first < 65 || first > 90 || second < 65 || second > 90) return null;
  return String.fromCharCodes([0x1F1E6 + first - 65, 0x1F1E6 + second - 65]);
}

String? countryNameToFlag(String name) {
  const flags = <String, String>{'Россия':'🇷🇺','Германия':'🇩🇪','Италия':'🇮🇹','Франция':'🇫🇷','Испания':'🇪🇸','Португалия':'🇵🇹','Великобритания':'🇬🇧','США':'🇺🇸','Канада':'🇨🇦','Япония':'🇯🇵','Китай':'🇨🇳','Польша':'🇵🇱','Чехия':'🇨🇿','Литва':'🇱🇹','Латвия':'🇱🇻','Эстония':'🇪🇪','Украина':'🇺🇦','Беларусь':'🇧🇾'};
  return flags[name.trim()];
}
