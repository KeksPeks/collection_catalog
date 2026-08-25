import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../collections/presentation/providers/collection_provider.dart';
import '../../items/presentation/providers/item_service_provider.dart';

/// Локальный обзор коллекционера. Все расчёты выполняются на устройстве.
class OverviewPage extends ConsumerWidget {
  const OverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Обзор')),
      body: collectionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Не удалось получить статистику: $error', textAlign: TextAlign.center))),
        data: (collections) => _OverviewBody(collections: collections),
      ),
    );
  }
}

class _OverviewBody extends ConsumerWidget {
  final List<dynamic> collections;
  const _OverviewBody({required this.collections});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final local = collections.where((item) => item.templateId != null).toList(growable: false);
    return FutureBuilder<_Stats>(
      future: _loadStats(ref, local),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Не удалось рассчитать статистику: ${snapshot.error}', textAlign: TextAlign.center)));
        final stats = snapshot.data ?? const _Stats(0, 0);
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(collectionsProvider);
            await ref.read(collectionsProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              _StatGrid(stats: stats),
              const SizedBox(height: 20),
              Text('Достижения', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              for (final achievement in _achievements(stats)) _AchievementTile(achievement: achievement),
            ],
          ),
        );
      },
    );
  }

  Future<_Stats> _loadStats(WidgetRef ref, List<dynamic> collections) async {
    final service = ref.read(itemServiceProvider);
    final counts = await Future.wait(collections.map((collection) async => (await service.getItems(collection.id)).length));
    return _Stats(collections.length, counts.fold<int>(0, (sum, value) => sum + value));
  }

  List<_Achievement> _achievements(_Stats stats) => [
    _Achievement('Первый шаг', 'Создай первую локальную коллекцию.', Icons.flag_outlined, stats.collections >= 1),
    _Achievement('Коллекционер', 'Сохрани 10 предметов.', Icons.inventory_2_outlined, stats.items >= 10),
    _Achievement('Большая коллекция', 'Сохрани 100 предметов.', Icons.auto_awesome_outlined, stats.items >= 100),
    _Achievement('Мастер коллекций', 'Создай 5 локальных коллекций.', Icons.workspace_premium_outlined, stats.collections >= 5),
    _Achievement('Тысяча предметов', 'Собери каталог из 1000 предметов.', Icons.military_tech_outlined, stats.items >= 1000),
    _Achievement('Ветеран', 'Сохрани 500 предметов локально.', Icons.emoji_events_outlined, stats.items >= 500),
    _Achievement('Легенда', 'Сохрани 5000 предметов локально.', Icons.stars_rounded, stats.items >= 5000),
  ];
}

class _Stats {
  final int collections;
  final int items;
  const _Stats(this.collections, this.items);
}

class _Achievement {
  final String title;
  final String description;
  final IconData icon;
  final bool unlocked;
  const _Achievement(this.title, this.description, this.icon, this.unlocked);
}

class _StatGrid extends StatelessWidget {
  final _Stats stats;
  const _StatGrid({required this.stats});

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final columns = constraints.maxWidth >= 560 ? 2 : 1;
    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: columns == 1 ? 3.2 : 2.4,
      children: [_StatCard(Icons.collections_bookmark_outlined, 'Коллекции', stats.collections), _StatCard(Icons.inventory_2_outlined, 'Предметы', stats.items)],
    );
  });
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int value;
  const _StatCard(this.icon, this.title, this.value);

  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 14), Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text('$value', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)), Text(title)])])));
}

class _AchievementTile extends StatelessWidget {
  final _Achievement achievement;
  const _AchievementTile({required this.achievement});

  @override
  Widget build(BuildContext context) => Card(child: ListTile(leading: CircleAvatar(child: Icon(achievement.icon)), title: Text(achievement.title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(achievement.description), trailing: Icon(achievement.unlocked ? Icons.check_circle_rounded : Icons.lock_outline_rounded, color: achievement.unlocked ? Theme.of(context).colorScheme.primary : null)));
}
