import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/api/server_media_service.dart';
import '../domain/entities/catalog_definition.dart';
import '../domain/entities/catalog_entry_definition.dart';

class CatalogEntryDetailPage extends StatefulWidget {
  final CatalogDefinition catalog;
  final CatalogEntryDefinition entry;

  const CatalogEntryDetailPage({super.key, required this.catalog, required this.entry});

  @override
  State<CatalogEntryDetailPage> createState() => _CatalogEntryDetailPageState();
}

class _CatalogEntryDetailPageState extends State<CatalogEntryDetailPage> {
  final ServerMediaService _mediaService = ServerMediaService();
  late Future<_ServerMediaData> _mediaFuture;

  @override
  void initState() {
    super.initState();
    _mediaFuture = _loadServerMedia();
  }

  Future<_ServerMediaData> _loadServerMedia() async {
    final itemId = int.tryParse(widget.entry.id);
    if (itemId == null) return const _ServerMediaData.empty();
    try {
      final results = await Future.wait([
        _mediaService.getImages(itemId),
        _mediaService.getFiles(itemId),
      ]);
      return _ServerMediaData(
        images: results[0] as List<ServerImage>,
        files: results[1] as List<ServerFile>,
      );
    } catch (_) {
      return const _ServerMediaData.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.entry.imageUrl?.trim();
    final flag = countryCodeToFlag(widget.entry.countryCode) ?? countryNameToFlag(widget.entry.attributes['Страна'] ?? widget.entry.primaryValue);
    return Scaffold(
      appBar: AppBar(title: Text(widget.entry.title, maxLines: 2, overflow: TextOverflow.ellipsis)),
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
          Text(widget.entry.title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          if (widget.entry.subtitle.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(widget.entry.subtitle, style: Theme.of(context).textTheme.titleMedium),
          ],
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Информация', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                _InfoRow(label: 'Каталог', value: widget.catalog.name),
                _InfoRow(label: 'Основное значение', value: widget.entry.primaryValue),
                for (final item in widget.entry.attributes.entries) _InfoRow(label: item.key, value: item.value),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<_ServerMediaData>(
            future: _mediaFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
              }
              final media = snapshot.data;
              if (media == null || (media.images.isEmpty && media.files.isEmpty)) return const SizedBox.shrink();
              return _ServerMediaSection(service: _mediaService, media: media);
            },
          ),
        ],
      ),
    );
  }
}

class _ServerMediaData {
  final List<ServerImage> images;
  final List<ServerFile> files;
  const _ServerMediaData({required this.images, required this.files});
  const _ServerMediaData.empty() : images = const [], files = const [];
}

class _ServerMediaSection extends StatelessWidget {
  final ServerMediaService service;
  final _ServerMediaData media;
  const _ServerMediaSection({required this.service, required this.media});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (media.images.isNotEmpty) ...[
          Text('Изображения', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: media.images.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = media.images[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 0.85,
                    child: Image.network(service.imageUrl(item), fit: BoxFit.contain, errorBuilder: (_, __, ___) => const _NoImage()),
                  ),
                );
              },
            ),
          ),
        ],
        if (media.files.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Файлы', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: media.files.map((file) {
                return ListTile(
                  leading: const Icon(Icons.insert_drive_file_outlined),
                  title: Text('Файл ${file.id}'),
                  subtitle: Text(file.fileType),
                  trailing: const Icon(Icons.download_rounded),
                  onTap: () async {
                    await launchUrl(Uri.parse(service.fileUrl(file)), mode: LaunchMode.externalApplication);
                  },
                );
              }).toList(growable: false),
            ),
          ),
        ],
      ],
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
