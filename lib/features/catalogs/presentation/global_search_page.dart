import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/catalog_registry.dart';
import '../domain/entities/catalog_definition.dart';
import '../../collections/domain/entities/collection.dart';
import '../../collections/presentation/providers/collection_provider.dart';
import '../../items/domain/entities/item.dart';
import '../../items/presentation/pages/item_detail_page.dart';
import '../../items/presentation/providers/item_provider.dart';
import '../../items/presentation/providers/item_service_provider.dart';
import '../../collections/data/collection_history_store.dart';
import 'catalog_online_page.dart';

class GlobalSearchPage extends ConsumerStatefulWidget {
  const GlobalSearchPage({super.key});

  @override
  ConsumerState<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends ConsumerState<GlobalSearchPage> {
  final _controller = TextEditingController();
  String _query = '';
  List<_SearchResult> _results = const [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _query = _controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _query.trim();
    if (query.isEmpty) {
      setState(() => _results = const []);
      return;
    }

    setState(() => _loading = true);
    final results = <_SearchResult>[];
    final normalized = _normalize(query);

    for (final catalog in CatalogRegistry.all) {
      final catalogText = _normalize('${catalog.name} ${catalog.description}');
      final score = _score(normalized, catalogText);
      if (score >= 0.55) {
        results.add(_SearchResult.catalog(catalog, score));
      }
      for (final entry in catalog.entries) {
        final text = _normalize('${entry.title} ${entry.primaryValue} ${entry.subtitle} ${entry.attributes.values.join(' ')}');
        final entryScore = _score(normalized, text);
        if (entryScore >= 0.55) {
          results.add(_SearchResult.entry(catalog, entry.title, entry.subtitle, entryScore));
        }
      }
    }

    final collections = ref.read(collectionsProvider).valueOrNull ?? const <Collection>[];
    final itemService = ref.read(itemServiceProvider);
    for (final collection in collections) {
      final items = await itemService.getItems(collection.id);
      final values = <String, Map<String, String>>{};
      for (final item in items) {
        final itemValues = await itemService.getValues(item.id);
        values[item.id] = {for (final value in itemValues) value.fieldId: value.value};
      }
      for (final item in items) {
        final text = _normalize('${collection.name} ${item.id} ${values[item.id]?.values.join(' ') ?? ''}');
        final itemScore = _score(normalized, text);
        if (itemScore >= 0.55) {
          results.add(_SearchResult.item(collection, item, itemScore));
        }
      }
    }

    results.sort((a, b) => b.score.compareTo(a.score));
    if (!mounted) return;
    setState(() {
      _results = results.take(100).toList(growable: false);
      _loading = false;
    });
  }

  String _normalize(String value) {
    var text = value.toLowerCase().trim();
    const replacements = {
      'q': 'й', 'w': 'ц', 'e': 'у', 'r': 'к', 't': 'е', 'y': 'н', 'u': 'г', 'i': 'ш', 'o': 'щ', 'p': 'з', '[': 'х', ']': 'ъ',
      'a': 'ф', 's': 'ы', 'd': 'в', 'f': 'а', 'g': 'п', 'h': 'р', 'j': 'о', 'k': 'л', 'l': 'д', ';': 'ж', "'": 'э',
      'z': 'я', 'x': 'ч', 'c': 'с', 'v': 'м', 'b': 'и', 'n': 'т', 'm': 'ь', ',': 'б', '.': 'ю',
    };
    if (text.codeUnits.every((unit) => unit < 128)) {
      text = text.split('').map((char) => replacements[char] ?? char).join();
    }
    return text.replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ');
  }

  double _score(String query, String text) {
    if (text.contains(query)) return 1;
    final tokens = text.split(' ').where((token) => token.isNotEmpty);
    if (tokens.isEmpty) return 0;
    var best = 0.0;
    for (final token in tokens) {
      final distance = _levenshtein(query, token);
      final maxLength = query.length > token.length ? query.length : token.length;
      if (maxLength == 0) continue;
      final score = 1 - distance / maxLength;
      if (score > best) best = score;
    }
    return best;
  }

  int _levenshtein(String a, String b) {
    final previous = List<int>.generate(b.length + 1, (index) => index);
    for (var i = 0; i < a.length; i++) {
      var current = i + 1;
      var diagonal = i;
      for (var j = 0; j < b.length; j++) {
        final old = previous[j + 1];
        final cost = a[i] == b[j] ? 0 : 1;
        previous[j + 1] = [previous[j + 1] + 1, previous[j] + 1, diagonal + cost].reduce((x, y) => x < y ? x : y);
        diagonal = old;
      }
      previous[0] = current;
    }
    return previous[b.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Глобальный поиск')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Предмет, серия, коллекция, заметка...',
                suffixIcon: _query.isEmpty ? null : IconButton(icon: const Icon(Icons.clear), onPressed: _controller.clear),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(onPressed: _loading ? null : _search, icon: const Icon(Icons.search), label: const Text('Найти')),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _query.isEmpty
                    ? const Center(child: Text('Введите запрос'))
                    : _results.isEmpty
                        ? const Center(child: Text('Ничего не найдено'))
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                            itemCount: _results.length,
                            separatorBuilder: (_, index) => const SizedBox(height: 8),
                            itemBuilder: (context, index) => _resultTile(context, _results[index]),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _resultTile(BuildContext context, _SearchResult result) {
    return Card(
      child: ListTile(
        leading: Icon(result.icon),
        title: Text(result.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(result.subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          if (result.catalog != null) {
            await Navigator.of(context).push(MaterialPageRoute(builder: (_) => CatalogOnlinePage(catalog: result.catalog!)));
          } else if (result.item != null) {
            await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ItemDetailPage(itemId: result.item!.id)));
          }
        },
      ),
    );
  }
}

class _SearchResult {
  final String title;
  final String subtitle;
  final double score;
  final IconData icon;
  final CatalogDefinition? catalog;
  final Item? item;

  const _SearchResult({required this.title, required this.subtitle, required this.score, required this.icon, this.catalog, this.item});

  factory _SearchResult.catalog(CatalogDefinition catalog, double score) => _SearchResult(title: catalog.name, subtitle: 'Коллекция · версия ${catalog.version}', score: score, icon: Icons.collections_bookmark_outlined, catalog: catalog);
  factory _SearchResult.entry(CatalogDefinition catalog, String title, String subtitle, double score) => _SearchResult(title: title, subtitle: '${catalog.name} · $subtitle', score: score, icon: Icons.inventory_2_outlined, catalog: catalog);
  factory _SearchResult.item(Collection collection, Item item, double score) => _SearchResult(title: item.id, subtitle: 'Моя коллекция · ${collection.name}', score: score, icon: Icons.check_circle_outline, item: item);
}
