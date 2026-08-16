import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../data/catalog_registry.dart';
import '../data/favorites_store.dart';
import '../domain/entities/catalog_definition.dart';
import 'catalog_online_page.dart';

/// Отдельный экран избранных каталогов.
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  Set<String> _favoriteIds = <String>{};
  VoidCallback? _revisionListener;

  @override
  void initState() {
    super.initState();
    _revisionListener = _load;
    FavoritesStore.revision.addListener(_revisionListener!);
    _load();
  }

  @override
  void dispose() {
    final listener = _revisionListener;
    if (listener != null) {
      FavoritesStore.revision.removeListener(listener);
    }
    super.dispose();
  }

  Future<void> _load() async {
    final ids = await FavoritesStore.load();
    if (!mounted) return;
    setState(() => _favoriteIds = ids);
  }

  Future<void> _remove(CatalogDefinition catalog) async {
    await FavoritesStore.remove(catalog.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final catalogs = CatalogRegistry.all
        .where((catalog) => _favoriteIds.contains(catalog.id))
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.favorites),
        actions: [
          IconButton(
            tooltip: l10n.search,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _load,
          ),
        ],
      ),
      body: catalogs.isEmpty
          ? _EmptyFavorites(l10n: l10n)
          : LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 1000
                    ? 3
                    : constraints.maxWidth >= 620
                        ? 2
                        : 1;
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                  itemCount: catalogs.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: columns == 1 ? 2.45 : 1.35,
                  ),
                  itemBuilder: (context, index) {
                    final catalog = catalogs[index];
                    return _FavoriteCatalogCard(
                      catalog: catalog,
                      onOpen: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CatalogOnlinePage(catalog: catalog),
                          ),
                        );
                        _load();
                      },
                      onRemove: () => _remove(catalog),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  final AppLocalizations l10n;
  const _EmptyFavorites({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(Icons.star_border_rounded, size: 48, color: colors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.noFavorites,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Text(l10n.noFavoritesDescription, textAlign: TextAlign.center),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteCatalogCard extends StatelessWidget {
  final CatalogDefinition catalog;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  const _FavoriteCatalogCard({
    required this.catalog,
    required this.onOpen,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(color: colors.primaryContainer, borderRadius: BorderRadius.circular(18)),
                child: Icon(_icon(catalog.id), color: colors.primary, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.catalogName(catalog.id), maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 5),
                    Text(l10n.recordsCount(catalog.entries.length), style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              IconButton(tooltip: l10n.removeFavorite, onPressed: onRemove, icon: const Icon(Icons.star_rounded)),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }

  IconData _icon(String id) {
    switch (id) {
      case 'lego': return Icons.extension_rounded;
      case 'coins': return Icons.monetization_on_outlined;
      case 'banknotes': return Icons.payments_outlined;
      case 'pokemon_tcg': return Icons.style_outlined;
      case 'games': return Icons.sports_esports_outlined;
      case 'discs': return Icons.album_outlined;
      case 'movies': return Icons.movie_outlined;
      case 'figurines': return Icons.toys_outlined;
      default: return Icons.inventory_2_outlined;
    }
  }
}
