import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/settings/currency_settings.dart';
import '../../../catalogs/presentation/barcode_scanner_page.dart';
import '../../../catalogs/presentation/global_search_page.dart';
import '../../../gamification/presentation/gamification_page.dart';
import '../../data/collection_history_store.dart';
import '../../domain/entities/collection.dart';
import '../providers/collection_provider.dart';
import '../../../items/data/item_state_store.dart';
import '../../../items/presentation/providers/item_service_provider.dart';

class CollectionToolsPage extends ConsumerStatefulWidget {
  const CollectionToolsPage({super.key});

  @override
  ConsumerState<CollectionToolsPage> createState() => _CollectionToolsPageState();
}

class _CollectionToolsPageState extends ConsumerState<CollectionToolsPage> {
  bool _loading = true;
  String? _error;
  List<_Summary> _summaries = const [];
  List<CollectionHistoryEntry> _history = const [];
  VoidCallback? _currencyListener;

  @override
  void initState() {
    super.initState();
    _currencyListener = () { if (mounted) setState(() {}); };
    CurrencySettings.revision.addListener(_currencyListener!);
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await CurrencySettings.load();
    } finally {
      if (mounted) await _load();
    }
  }

  @override
  void dispose() {
    final listener = _currencyListener;
    if (listener != null) CurrencySettings.revision.removeListener(listener);
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) setState(() { _loading = true; _error = null; });
    try {
      // Обзор может быть первым экраном приложения. Ждём готовности Drift,
      // а затем заново получаем коллекции, чтобы не читать провайдер в loading.
      await ref.read(databaseProvider.future);
      ref.invalidate(collectionsProvider);
      final collections = await ref.read(collectionsProvider.future);
      final service = ref.read(itemServiceProvider);
      final states = await ItemStateStore.loadAll();

      final summaries = await Future.wait(
        collections.map((collection) async {
          final items = await service.getItems(collection.id);
          var owned = 0;
          var wanted = 0;
          var ordered = 0;
          var quantity = 0;
          var cost = 0.0;
          for (final item in items) {
            final state = states[item.id] ?? ItemState(updatedAt: item.updatedAt);
            if (state.status == CollectionItemStatus.owned || state.status == CollectionItemStatus.storage) owned++;
            if (state.status == CollectionItemStatus.wanted) wanted++;
            if (state.status == CollectionItemStatus.ordered) ordered++;
            quantity += state.quantity;
            cost += (state.purchasePrice ?? 0) * state.quantity;
          }
          return _Summary(collection, items.length, owned, wanted, ordered, quantity, cost);
        }),
      );

      final history = await CollectionHistoryStore.load();
      if (!mounted) return;
      setState(() {
        _summaries = summaries;
        _history = history;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _notify() async {
    try {
      final ok = await NotificationService.requestPermission();
      if (ok) await NotificationService.show(title: 'Collection Catalog', body: 'Уведомления включены.');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(ok ? 'Уведомления разрешены.' : 'Разрешение не выдано.')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Уведомления недоступны: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Обзор')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                const Text('Не удалось загрузить обзор', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Повторить')),
              ],
            ),
          ),
        ),
      );
    }

    final total = _summaries.fold(0, (sum, item) => sum + item.total);
    final owned = _summaries.fold(0, (sum, item) => sum + item.owned);
    final wanted = _summaries.fold(0, (sum, item) => sum + item.wanted);
    final ordered = _summaries.fold(0, (sum, item) => sum + item.ordered);
    final cost = _summaries.fold(0.0, (sum, item) => sum + item.cost);
    final progress = total == 0 ? 0.0 : owned / total;
    final currency = CurrencySettings.selected.symbol;

    return Scaffold(
      appBar: AppBar(title: const Text('Инструменты коллекционера'), actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))]),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Прогресс коллекции', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 12), LinearProgressIndicator(value: progress, minHeight: 10), const SizedBox(height: 8), Text('${(progress * 100).round()}% собрано · $owned из $total')]))) ,
            const SizedBox(height: 10),
            Row(children: [Expanded(child: _Metric('Всего', '$total', Icons.inventory_2_outlined)), const SizedBox(width: 8), Expanded(child: _Metric('Есть', '$owned', Icons.check_circle_outline)), const SizedBox(width: 8), Expanded(child: _Metric('Не хватает', '${total - owned}', Icons.remove_circle_outline))]),
            const SizedBox(height: 8),
            Row(children: [Expanded(child: _Metric('Хочу', '$wanted', Icons.shopping_cart_outlined)), const SizedBox(width: 8), Expanded(child: _Metric('Заказано', '$ordered', Icons.local_shipping_outlined)), const SizedBox(width: 8), Expanded(child: _Metric('Расходы', '$currency${cost.toStringAsFixed(2)}', Icons.currency_exchange_rounded))]),
            const SizedBox(height: 12),
            _Tool('Достижения', 'XP, уровни и прогресс коллекционера', Icons.emoji_events_outlined, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GamificationPage()))),
            _Tool('Глобальный поиск', 'По каталогам, сериям и предметам', Icons.search, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GlobalSearchPage()))),
            _Tool('QR / штрихкод', 'Сканировать код предмета', Icons.qr_code_scanner, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BarcodeScannerPage()))),
            _Tool('Уведомления', 'Новости каталогов и прогресса', Icons.notifications_active_outlined, _notify),
            Card(child: ExpansionTile(title: const Text('История изменений'), leading: const Icon(Icons.history), children: _history.isEmpty ? [const ListTile(title: Text('История пока пуста'))] : _history.take(30).map((entry) => ListTile(title: Text(entry.title), subtitle: Text('${entry.details}\n${entry.timestamp}'))).toList())),
            Card(child: ExpansionTile(title: const Text('Осталось собрать'), leading: const Icon(Icons.playlist_add_check), children: _summaries.map((summary) => ListTile(title: Text(summary.collection.name), subtitle: Text('Не хватает ${summary.total - summary.owned} из ${summary.total}'), trailing: Text('${summary.percent.round()}%'))).toList())),
          ],
        ),
      ),
    );
  }
}

class _Summary {
  final Collection collection;
  final int total;
  final int owned;
  final int wanted;
  final int ordered;
  final int quantity;
  final double cost;
  const _Summary(this.collection, this.total, this.owned, this.wanted, this.ordered, this.quantity, this.cost);
  double get percent => total == 0 ? 0 : owned * 100 / total;
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _Metric(this.label, this.value, this.icon);
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(10), child: Column(children: [Icon(icon), Text(value, style: const TextStyle(fontWeight: FontWeight.w900)), Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall)])));
}

class _Tool extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  const _Tool(this.title, this.subtitle, this.icon, this.onTap);
  @override
  Widget build(BuildContext context) => Card(child: ListTile(leading: CircleAvatar(child: Icon(icon)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(subtitle), trailing: const Icon(Icons.chevron_right), onTap: onTap));
}
