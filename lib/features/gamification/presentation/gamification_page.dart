import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../collections/presentation/providers/collection_service_provider.dart';
import '../../items/presentation/providers/item_service_provider.dart';
import '../data/gamification_store.dart';
import '../domain/entities/achievement.dart';

final gamificationStoreProvider = Provider<GamificationStore>((ref) => GamificationStore());

class GamificationPage extends ConsumerStatefulWidget {
  const GamificationPage({super.key});

  @override
  ConsumerState<GamificationPage> createState() => _GamificationPageState();
}

class _GamificationPageState extends ConsumerState<GamificationPage> {
  int _collections = 0;
  int _items = 0;
  int _xp = 0;
  Set<String> _unlocked = <String>{};
  bool _loading = true;

  static const _achievements = <Achievement>[
    Achievement(id: 'first_collection', title: 'Начало пути', description: 'Создайте первую коллекцию', icon: '🌱', target: 1, rewardXp: 25),
    Achievement(id: 'first_item', title: 'Первый предмет', description: 'Добавьте первый предмет', icon: '📦', target: 1, rewardXp: 25),
    Achievement(id: 'ten_items', title: 'Первые шаги', description: 'Добавьте 10 предметов', icon: '🧩', target: 10, rewardXp: 50),
    Achievement(id: 'hundred_items', title: 'Собиратель', description: 'Добавьте 100 предметов', icon: '🗃️', target: 100, rewardXp: 150),
    Achievement(id: 'five_collections', title: 'Коллекционер коллекций', description: 'Создайте 5 коллекций', icon: '🗂️', target: 5, rewardXp: 100),
    Achievement(id: 'five_hundred_items', title: 'Архивариус', description: 'Добавьте 500 предметов', icon: '🏛️', target: 500, rewardXp: 500),
    Achievement(id: 'thousand_items', title: 'Великий коллекционер', description: 'Добавьте 1000 предметов', icon: '👑', target: 1000, rewardXp: 1000),
  ];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    try {
      final collections = await ref.read(collectionServiceProvider).getCollections();
      var items = 0;
      final itemService = ref.read(itemServiceProvider);
      for (final collection in collections) {
        items += (await itemService.getItems(collection.id)).length;
      }

      final store = ref.read(gamificationStoreProvider);
      for (final achievement in _achievements) {
        final value = _valueFor(achievement.id, collections.length, items);
        if (value >= achievement.target) {
          await store.unlockIfNeeded(achievement.id, achievement.rewardXp);
        }
      }
      if (!mounted) return;
      setState(() {
        _collections = collections.length;
        _items = items;
        _xp = 0;
        _unlocked = <String>{};
      });
      _xp = await store.getXp();
      _unlocked = await store.getUnlocked();
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    if (mounted) setState(() => _loading = false);
  }

  int _valueFor(String id, int collections, int items) {
    switch (id) {
      case 'first_collection':
      case 'five_collections':
        return collections;
      default:
        return items;
    }
  }

  int get _level => (_xp ~/ 100) + 1;
  int get _levelProgress => _xp % 100;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Достижения'),
        actions: [IconButton(onPressed: _refresh, tooltip: 'Обновить', icon: const Icon(Icons.refresh))],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _profileCard(context),
            const SizedBox(height: 16),
            Text('Достижения', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (_loading)
              const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))
            else
              ..._achievements.map((achievement) => _achievementCard(context, achievement)),
          ],
        ),
      ),
    );
  }

  Widget _profileCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(radius: 28, child: Text('$_level', style: theme.textTheme.titleLarge)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Коллекционер', style: theme.textTheme.titleMedium),
              Text('Уровень $_level · $_xp XP'),
            ])),
          ]),
          const SizedBox(height: 14),
          ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: _levelProgress / 100, minHeight: 8)),
          const SizedBox(height: 6),
          Text('$_levelProgress / 100 XP до следующего уровня'),
          const SizedBox(height: 14),
          Wrap(spacing: 16, runSpacing: 8, children: [
            _stat(Icons.collections_bookmark_outlined, '$_collections коллекций'),
            _stat(Icons.inventory_2_outlined, '$_items предметов'),
            _stat(Icons.emoji_events_outlined, '${_unlocked.length} достижений'),
          ]),
        ]),
      ),
    );
  }

  Widget _stat(IconData icon, String text) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 18), const SizedBox(width: 5), Text(text)]);

  Widget _achievementCard(BuildContext context, Achievement achievement) {
    final value = _valueFor(achievement.id, _collections, _items);
    final unlocked = _unlocked.contains(achievement.id);
    final progress = (value / achievement.target).clamp(0.0, 1.0).toDouble();
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Text(achievement.icon, style: const TextStyle(fontSize: 28)),
        title: Text(achievement.title),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 3),
          Text(achievement.description),
          const SizedBox(height: 7),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 4),
          Text(unlocked ? 'Получено · +${achievement.rewardXp} XP' : '$value / ${achievement.target} · +${achievement.rewardXp} XP'),
        ]),
        trailing: unlocked ? const Icon(Icons.check_circle, color: Colors.green) : null,
      ),
    );
  }
}
