import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../collections/presentation/providers/collection_provider.dart';
import '../../gamification/data/gamification_store.dart';
import '../../gamification/domain/entities/achievement.dart';
import '../../items/data/item_state_store.dart';

/// Локальный обзор коллекционера. Тяжёлый перебор предметов не выполняется при открытии.
class OverviewPage extends ConsumerStatefulWidget {
  const OverviewPage({super.key});
  @override
  ConsumerState<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends ConsumerState<OverviewPage> {
  static const achievements = <Achievement>[
    Achievement(id: 'first_collection', title: 'Начало пути', description: 'Создайте первую коллекцию', icon: '🌱', target: 1, rewardXp: 25),
    Achievement(id: 'first_item', title: 'Первый предмет', description: 'Добавьте первый предмет', icon: '📦', target: 1, rewardXp: 25),
    Achievement(id: 'ten_items', title: 'Первые шаги', description: 'Добавьте 10 отслеживаемых предметов', icon: '🧩', target: 10, rewardXp: 50),
    Achievement(id: 'hundred_items', title: 'Собиратель', description: 'Добавьте 100 отслеживаемых предметов', icon: '🗃️', target: 100, rewardXp: 150),
    Achievement(id: 'five_collections', title: 'Коллекционер коллекций', description: 'Создайте 5 коллекций', icon: '🗂️', target: 5, rewardXp: 100),
    Achievement(id: 'five_hundred_items', title: 'Архивариус', description: 'Добавьте 500 отслеживаемых предметов', icon: '🏛️', target: 500, rewardXp: 500),
    Achievement(id: 'thousand_items', title: 'Великий коллекционер', description: 'Добавьте 1000 отслеживаемых предметов', icon: '👑', target: 1000, rewardXp: 1000),
  ];

  Future<_Stats> _loadStats(int collectionCount) async {
    final states = await ItemStateStore.loadAll();
    final items = states.length;
    final store = GamificationStore();
    for (final achievement in achievements) {
      final value = _valueFor(achievement.id, collectionCount, items);
      if (value >= achievement.target) await store.unlockIfNeeded(achievement.id, achievement.rewardXp);
    }
    return _Stats(collectionCount, items, await store.getXp(), await store.getUnlocked());
  }

  int _valueFor(String id, int collections, int items) => id == 'first_collection' || id == 'five_collections' ? collections : items;

  @override
  Widget build(BuildContext context) {
    final asyncCollections = ref.watch(collectionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Обзор')),
      body: asyncCollections.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _OverviewError(error: error, onRetry: () => ref.invalidate(collectionsProvider)),
        data: (collections) => FutureBuilder<_Stats>(
          future: _loadStats(collections.where((item) => item.templateId != null).length),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return _OverviewError(error: snapshot.error!, onRetry: () => setState(() {}));
            final stats = snapshot.data ?? const _Stats(0, 0, 0, <String>{});
            return RefreshIndicator(
              onRefresh: () async { ref.invalidate(collectionsProvider); await ref.read(collectionsProvider.future); if (mounted) setState(() {}); },
              child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 32), physics: const AlwaysScrollableScrollPhysics(), children: [
                _ProfileCard(stats: stats),
                const SizedBox(height: 16),
                Text('Достижения', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                for (final achievement in achievements) _AchievementTile(achievement: achievement, value: _valueFor(achievement.id, stats.collections, stats.items), unlocked: stats.unlocked.contains(achievement.id)),
                const SizedBox(height: 8),
                const Text('Статистика и достижения рассчитываются локально на устройстве и не требуют сервера.', textAlign: TextAlign.center),
              ]),
            );
          },
        ),
      ),
    );
  }
}

class _Stats {
  final int collections;
  final int items;
  final int xp;
  final Set<String> unlocked;
  const _Stats(this.collections, this.items, this.xp, this.unlocked);
}

class _ProfileCard extends StatelessWidget {
  final _Stats stats;
  const _ProfileCard({required this.stats});
  @override
  Widget build(BuildContext context) {
    final level = stats.xp ~/ 100 + 1;
    final progress = stats.xp % 100;
    return Card(child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [CircleAvatar(radius: 28, child: Text('$level')), const SizedBox(width: 14), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Коллекционер', style: Theme.of(context).textTheme.titleMedium), Text('Уровень $level · ${stats.xp} XP')]))]), const SizedBox(height: 14), LinearProgressIndicator(value: progress / 100, minHeight: 8), const SizedBox(height: 6), Text('$progress / 100 XP до следующего уровня'), const SizedBox(height: 14), Wrap(spacing: 16, runSpacing: 8, children: [Text('${stats.collections} коллекций'), Text('${stats.items} отслеживаемых предметов'), Text('${stats.unlocked.length} достижений')])]));
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;
  final int value;
  final bool unlocked;
  const _AchievementTile({required this.achievement, required this.value, required this.unlocked});
  @override
  Widget build(BuildContext context) {
    final progress = (value / achievement.target).clamp(0.0, 1.0).toDouble();
    return Card(child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), leading: Text(achievement.icon, style: const TextStyle(fontSize: 28)), title: Text(achievement.title), subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const SizedBox(height: 3), Text(achievement.description), const SizedBox(height: 7), LinearProgressIndicator(value: progress), const SizedBox(height: 4), Text(unlocked ? 'Получено · +${achievement.rewardXp} XP' : '$value / ${achievement.target} · +${achievement.rewardXp} XP')]), trailing: unlocked ? const Icon(Icons.check_circle_rounded) : const Icon(Icons.lock_outline_rounded)));
  }
}

class _OverviewError extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  const _OverviewError({required this.error, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.insights_outlined, size: 52), const SizedBox(height: 12), const Text('Не удалось открыть локальный обзор', textAlign: TextAlign.center), const SizedBox(height: 8), Text('$error', textAlign: TextAlign.center), const SizedBox(height: 16), FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Повторить'))])));
}
