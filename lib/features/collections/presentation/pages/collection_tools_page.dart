import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/notifications/notification_service.dart';
import '../../../catalogs/data/catalog_registry.dart';
import '../../../catalogs/data/catalog_version_store.dart';
import '../../../catalogs/data/favorites_store.dart';
import '../../../catalogs/presentation/barcode_scanner_page.dart';
import '../../../catalogs/presentation/global_search_page.dart';
import '../../data/backup_export_service.dart';
import '../../data/collection_history_store.dart';
import '../../domain/entities/collection.dart';
import '../../domain/entities/collection_section.dart';
import '../providers/collection_provider.dart';
import '../providers/collection_section_provider.dart';
import '../../../items/data/item_state_store.dart';
import '../../../items/domain/entities/item.dart';
import '../../../items/domain/entities/item_value.dart';
import '../../../items/presentation/providers/item_service_provider.dart';

class CollectionToolsPage extends ConsumerStatefulWidget {
  const CollectionToolsPage({super.key});

  @override
  ConsumerState<CollectionToolsPage> createState() => _CollectionToolsPageState();
}

class _CollectionToolsPageState extends ConsumerState<CollectionToolsPage> {
  bool _loading = true;
  List<_CollectionSummary> _summaries = const [];
  List<CollectionHistoryEntry> _history = const [];
  Map<String, ItemState> _states = const {};
  Set<String> _favorites = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final collections = ref.read(collectionsProvider).valueOrNull ?? const <Collection>[];
    final itemService = ref.read(itemServiceProvider);
    final summaries = <_CollectionSummary>[];
    for (final collection in collections.where((item) => item.templateId != null)) {
      final items = await itemService.getItems(collection.id);
      var owned = 0;
      var wanted = 0;
      var ordered = 0;
      var quantity = 0;
      var cost = 0.0;
      for (final item in items) {
        final state = await ItemStateStore.load(item.id);
        switch (state.status) {
          case CollectionItemStatus.owned:
          case CollectionItemStatus.storage:
            owned++;
            break;
          case CollectionItemStatus.wanted:
            wanted++;
            break;
          case CollectionItemStatus.ordered:
            ordered++;
            break;
          case CollectionItemStatus.missing:
          case CollectionItemStatus.trade:
            break;
        }
        quantity += state.quantity;
        cost += (state.purchasePrice ?? 0) * state.quantity;
      }
      summaries.add(_CollectionSummary(collection: collection, total: items.length, owned: owned, wanted: wanted, ordered: ordered, quantity: quantity, cost: cost));
    }
    final history = await CollectionHistoryStore.load();
    final states = await ItemStateStore.loadAll();
    final favorites = await FavoritesStore.loadKeys();
    if (!mounted) return;
    setState(() {
      _summaries = summaries;
      _history = history;
      _states = states;
      _favorites = favorites;
      _loading = false;
    });
  }

  Map<String, dynamic> _snapshot() {
    return {
      'format': 'collection_catalog_backup_v1',
      'createdAt': DateTime.now().toIso8601String(),
      'catalogVersions': {for (final catalog in CatalogRegistry.all) catalog.id: catalog.version},
      'collections': [
        for (final summary in _summaries)
          {
            'id': summary.collection.id,
            'name': summary.collection.name,
            'templateId': summary.collection.templateId,
            'total': summary.total,
            'owned': summary.owned,
            'wanted': summary.wanted,
            'ordered': summary.ordered,
          },
      ],
      'itemStates': _states.map((key, value) => MapEntry(key, value.toJson())),
      'favorites': _favorites.toList()..sort(),
      'history': _history.map((entry) => entry.toJson()).toList(),
    };
  }

  List<List<dynamic>> _csvRows() {
    final rows = <List<dynamic>>[
      ['Коллекция', 'Всего', 'Есть', 'Хочу', 'Заказано', 'Экземпляров', 'Расходы'],
    ];
    rows.addAll(_summaries.map((summary) => [summary.collection.name, summary.total, summary.owned, summary.wanted, summary.ordered, summary.quantity, summary.cost.toStringAsFixed(2)]));
    return rows;
  }

  Future<void> _export(String type) async {
    try {
      final snapshot = _snapshot();
      if (type == 'json') await BackupExportService.exportJson(snapshot);
      if (type == 'csv') await BackupExportService.exportCsv(_csvRows());
      if (type == 'xlsx') await BackupExportService.exportExcel(_csvRows());
      if (type == 'pdf') await BackupExportService.exportPdf(_csvRows(), title: 'Collection Catalog');
      if (type == 'zip') await BackupExportService.exportZip(snapshot);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Файл сформирован и передан в системное меню обмена.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка экспорта: $error')));
    }
  }

  Future<void> _notifications() async {
    try {
      final allowed = await NotificationService.requestPermission();
      if (allowed) {
        await NotificationService.show(title: 'Collection Catalog', body: 'Уведомления включены.');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(allowed ? 'Уведомления разрешены.' : 'Разрешение не выдано.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Уведомления недоступны: $error')));
    }
  }

  Future<void> _versions() async {
    final rows = <Widget>[];
    for (final catalog in CatalogRegistry.all) {
      final installed = await CatalogVersionStore.installedVersion(catalog.id);
      rows.add(ListTile(
        leading: const Icon(Icons.new_releases_outlined),
        title: Text(catalog.name),
        subtitle: Text('Опубликовано: v${catalog.version} · На устройстве: ${installed == null ? 'не отмечено' : 'v$installed'}'),
        trailing: installed != null && installed < catalog.version ? const Chip(label: Text('Обновить')) : null,
      ));
    }
    if (!mounted) return;
    await showModalBottomSheet<void>(context: context, builder: (sheet) => SafeArea(child: ListView(children: [const Padding(padding: EdgeInsets.all(16), child: Text('Версии каталогов', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800))), ...rows])));
  }

  Future<void> _showSettings() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    await showModalBottomSheet<void>(context: context, isScrollControlled: true, builder: (sheet) => _InterfaceSettingsSheet(preferences: preferences));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final total = _summaries.fold<int>(0, (sum, item) => sum + item.total);
    final owned = _summaries.fold<int>(0, (sum, item) => sum + item.owned);
    final wanted = _summaries.fold<int>(0, (sum, item) => sum + item.wanted);
    final ordered = _summaries.fold<int>(0, (sum, item) => sum + item.ordered);
    final progress = total == 0 ? 0.0 : owned / total;

    return Scaffold(
      appBar: AppBar(title: const Text('Инструменты коллекционера'), actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))]),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Прогресс коллекции', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 12), LinearProgressIndicator(value: progress, minHeight: 10), const SizedBox(height: 10), Text('${(progress * 100).round()}% собрано · $owned из $total')]))) ,
            const SizedBox(height: 12),
            Row(children: [Expanded(child: _MetricCard(label: 'Всего', value: '$total', icon: Icons.inventory_2_outlined)), const SizedBox(width: 8), Expanded(child: _MetricCard(label: 'Есть', value: '$owned', icon: Icons.check_circle_outline)), const SizedBox(width: 8), Expanded(child: _MetricCard(label: 'Не хватает', value: '${total - owned}', icon: Icons.remove_circle_outline))]),
            const SizedBox(height: 8),
            Row(children: [Expanded(child: _MetricCard(label: 'Хочу', value: '$wanted', icon: Icons.shopping_cart_outlined)), const SizedBox(width: 8), Expanded(child: _MetricCard(label: 'Заказано', value: '$ordered', icon: Icons.local_shipping_outlined)), const SizedBox(width: 8), Expanded(child: _MetricCard(label: 'Расходы', value: '€${_summaries.fold<double>(0, (sum, item) => sum + item.cost).toStringAsFixed(2)}', icon: Icons.euro_outlined))]),
            const SizedBox(height: 16),
            _ToolCard(icon: Icons.search, title: 'Глобальный поиск', subtitle: 'По коллекциям, сериям, предметам и значениям с учётом раскладки и опечаток.', onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GlobalSearchPage()))),
            _ToolCard(icon: Icons.qr_code_scanner, title: 'Сканер QR / штрихкода', subtitle: 'Найти код товара и передать его в каталог.', onTap: () async { await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BarcodeScannerPage())); }),
            _ToolCard(icon: Icons.notifications_active_outlined, title: 'Уведомления', subtitle: 'Новости каталогов и напоминания о прогрессе.', onTap: _notifications),
            _ToolCard(icon: Icons.tune, title: 'Настройки интерфейса', subtitle: 'Плотность, колонки и способ навигации. Основной режим — автоматически.', onTap: _showSettings),
            _ToolCard(icon: Icons.new_releases_outlined, title: 'Версии каталогов', subtitle: 'Сравнить опубликованную и установленную версию.', onTap: _versions),
            const SizedBox(height: 10),
            Card(child: ExpansionTile(title: const Text('Резервная копия и экспорт'), leading: const Icon(Icons.backup_outlined), children: [Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [FilledButton.tonalIcon(onPressed: () => _export('json'), icon: const Icon(Icons.data_object), label: const Text('JSON')), FilledButton.tonalIcon(onPressed: () => _export('csv'), icon: const Icon(Icons.table_chart_outlined), label: const Text('CSV')), FilledButton.tonalIcon(onPressed: () => _export('xlsx'), icon: const Icon(Icons.grid_on), label: const Text('Excel')), FilledButton.tonalIcon(onPressed: () => _export('pdf'), icon: const Icon(Icons.picture_as_pdf_outlined), label: const Text('PDF')), FilledButton.icon(onPressed: () => _export('zip'), icon: const Icon(Icons.archive_outlined), label: const Text('ZIP'))]), const SizedBox(height: 14)])),
            const SizedBox(height: 10),
            Card(child: ExpansionTile(title: const Text('История изменений'), leading: const Icon(Icons.history), children: _history.isEmpty ? [const ListTile(title: Text('История пока пуста'))] : _history.take(30).map((entry) => ListTile(leading: const Icon(Icons.timeline), title: Text(entry.title), subtitle: Text('${entry.details}\n${entry.timestamp}'))).toList())),
            const SizedBox(height: 10),
            Card(child: ExpansionTile(title: const Text('Осталось собрать'), leading: const Icon(Icons.playlist_add_check), children: _summaries.map((summary) => ListTile(title: Text(summary.collection.name), subtitle: Text('Не хватает ${summary.total - summary.owned} из ${summary.total}'), trailing: Text('${summary.percent.round()}%'))).toList())),
          ],
        ),
      ),
    );
  }
}

class _CollectionSummary {
  final Collection collection;
  final int total;
  final int owned;
  final int wanted;
  final int ordered;
  final int quantity;
  final double cost;
  const _CollectionSummary({required this.collection, required this.total, required this.owned, required this.wanted, required this.ordered, required this.quantity, required this.cost});
  double get percent => total == 0 ? 0 : owned * 100 / total;
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _MetricCard({required this.label, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [Icon(icon), const SizedBox(height: 5), Text(value, style: const TextStyle(fontWeight: FontWeight.w900)), const SizedBox(height: 2), Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall)])));
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ToolCard({required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(child: ListTile(contentPadding: const EdgeInsets.all(12), leading: CircleAvatar(child: Icon(icon)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(subtitle), trailing: const Icon(Icons.chevron_right), onTap: onTap));
}

class _InterfaceSettingsSheet extends StatefulWidget {
  final SharedPreferences preferences;
  const _InterfaceSettingsSheet({required this.preferences});
  @override
  State<_InterfaceSettingsSheet> createState() => _InterfaceSettingsSheetState();
}

class _InterfaceSettingsSheetState extends State<_InterfaceSettingsSheet> {
  late String density = widget.preferences.getString('ui.density') ?? 'auto';
  late int columns = widget.preferences.getInt('ui.columns') ?? 0;
  late String navigation = widget.preferences.getString('ui.navigation') ?? 'auto';

  Future<void> _save() async {
    await widget.preferences.setString('ui.density', density);
    await widget.preferences.setInt('ui.columns', columns);
    await widget.preferences.setString('ui.navigation', navigation);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => SafeArea(child: ListView(shrinkWrap: true, padding: const EdgeInsets.all(16), children: [const Text('Настройки интерфейса', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 12), DropdownButtonFormField<String>(initialValue: density, decoration: const InputDecoration(labelText: 'Плотность интерфейса', border: OutlineInputBorder()), items: const [DropdownMenuItem(value: 'auto', child: Text('Автоматически')), DropdownMenuItem(value: 'compact', child: Text('Компактная')), DropdownMenuItem(value: 'normal', child: Text('Обычная')), DropdownMenuItem(value: 'spacious', child: Text('Просторная'))], onChanged: (value) => setState(() => density = value ?? 'auto')), const SizedBox(height: 12), DropdownButtonFormField<int>(initialValue: columns, decoration: const InputDecoration(labelText: 'Количество колонок', border: OutlineInputBorder()), items: const [DropdownMenuItem(value: 0, child: Text('Авто')), DropdownMenuItem(value: 1, child: Text('1')), DropdownMenuItem(value: 2, child: Text('2')), DropdownMenuItem(value: 3, child: Text('3')), DropdownMenuItem(value: 4, child: Text('4'))], onChanged: (value) => setState(() => columns = value ?? 0)), const SizedBox(height: 12), DropdownButtonFormField<String>(initialValue: navigation, decoration: const InputDecoration(labelText: 'Навигация', border: OutlineInputBorder()), items: const [DropdownMenuItem(value: 'auto', child: Text('Автоматически')), DropdownMenuItem(value: 'bottom', child: Text('Нижняя панель')), DropdownMenuItem(value: 'side', child: Text('Боковая панель'))], onChanged: (value) => setState(() => navigation = value ?? 'auto')), const SizedBox(height: 16), FilledButton(onPressed: _save, child: const Text('Сохранить'))]));
}
