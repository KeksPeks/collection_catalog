import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/settings/ui_layout_settings.dart';
import '../../../catalogs/data/catalog_registry.dart';
import '../../../catalogs/data/catalog_version_store.dart';
import '../../../collections/data/backup_export_service.dart';
import '../../../collections/data/collection_history_store.dart';
import '../../../collections/domain/entities/collection.dart';
import '../../../collections/presentation/providers/collection_provider.dart';
import '../../../items/data/item_state_store.dart';
import '../../../items/presentation/providers/item_service_provider.dart';

/// Основной экран настроек приложения.
///
/// Здесь собраны настройки интерфейса, версии каталогов и резервное копирование.
/// Вспомогательные инструменты коллекционера больше не содержат эти пункты.
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  @override
  void initState() {
    super.initState();
    UiLayoutSettings.ensureLoaded();
  }

  Future<void> _showInterfaceSettings() async {
    await UiLayoutSettings.ensureLoaded();
    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _InterfaceSettingsSheet(),
    );
    if (mounted) setState(() {});
  }

  Future<void> _showCatalogVersions() async {
    final rows = <Widget>[];
    for (final catalog in CatalogRegistry.all) {
      final installed = await CatalogVersionStore.installedVersion(catalog.id);
      rows.add(
        ListTile(
          leading: const Icon(Icons.new_releases_outlined),
          title: Text(catalog.name),
          subtitle: Text('Опубликовано v${catalog.version} · На устройстве ${installed ?? '—'}'),
          trailing: installed != null && installed < catalog.version
              ? const Chip(label: Text('Обновить'))
              : null,
        ),
      );
    }

    if (!mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text('Версии каталогов', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ),
            ...rows,
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _buildBackup() async {
    final collections = ref.read(collectionsProvider).valueOrNull ?? const <Collection>[];
    final service = ref.read(itemServiceProvider);
    final states = await ItemStateStore.loadAll();
    final history = await CollectionHistoryStore.load();
    final collectionsData = <Map<String, dynamic>>[];

    for (final collection in collections) {
      final items = await service.getItems(collection.id);
      collectionsData.add({
        'id': collection.id,
        'name': collection.name,
        'templateId': collection.templateId,
        'total': items.length,
      });
    }

    return {
      'format': 'collection_catalog_backup_v1',
      'createdAt': DateTime.now().toIso8601String(),
      'catalogVersions': {for (final catalog in CatalogRegistry.all) catalog.id: catalog.version},
      'collections': collectionsData,
      'itemStates': states.map((key, value) => MapEntry(key, value.toJson())),
      'history': history.map((entry) => entry.toJson()).toList(),
    };
  }

  Future<void> _exportBackup({required bool zip}) async {
    try {
      final snapshot = await _buildBackup();
      if (zip) {
        await BackupExportService.exportZip(snapshot);
      } else {
        await BackupExportService.exportJson(snapshot);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Резервная копия сформирована.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка резервного копирования: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SettingsHeader(
            title: 'Интерфейс',
            icon: Icons.palette_outlined,
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.grid_view_rounded),
              title: const Text('Настройки интерфейса'),
              subtitle: const Text('Колонки, плотность и высота карточек'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showInterfaceSettings,
            ),
          ),
          const SizedBox(height: 18),
          const _SettingsHeader(
            title: 'Каталоги',
            icon: Icons.library_books_outlined,
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.new_releases_outlined),
              title: const Text('Версии каталогов'),
              subtitle: const Text('Информация о версиях опубликованных и установленных каталогов'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showCatalogVersions,
            ),
          ),
          const SizedBox(height: 18),
          const _SettingsHeader(
            title: 'Данные',
            icon: Icons.storage_outlined,
          ),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.backup_outlined),
                  title: Text('Резервная копия'),
                  subtitle: Text('Сохранить данные коллекций и состояния предметов'),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _exportBackup(zip: false),
                          icon: const Icon(Icons.data_object),
                          label: const Text('JSON'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _exportBackup(zip: true),
                          icon: const Icon(Icons.archive_outlined),
                          label: const Text('ZIP'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Настройки приложения',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SettingsHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _InterfaceSettingsSheet extends StatefulWidget {
  const _InterfaceSettingsSheet();

  @override
  State<_InterfaceSettingsSheet> createState() => _InterfaceSettingsSheetState();
}

class _InterfaceSettingsSheetState extends State<_InterfaceSettingsSheet> {
  late String density = UiLayoutSettings.density;
  late int columns = UiLayoutSettings.columns;
  late String navigation = UiLayoutSettings.navigation;
  late double cardHeight = UiLayoutSettings.cardHeight;

  Future<void> _save() async {
    await UiLayoutSettings.save(
      density: density,
      columns: columns,
      navigation: navigation,
      cardHeight: cardHeight,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Настройки интерфейса', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: density,
            decoration: const InputDecoration(labelText: 'Плотность', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'auto', child: Text('Авто')),
              DropdownMenuItem(value: 'compact', child: Text('Компактная')),
              DropdownMenuItem(value: 'normal', child: Text('Обычная')),
              DropdownMenuItem(value: 'spacious', child: Text('Просторная')),
            ],
            onChanged: (value) => setState(() => density = value ?? 'auto'),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            initialValue: columns,
            decoration: const InputDecoration(labelText: 'Колонки', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 0, child: Text('Авто')),
              DropdownMenuItem(value: 1, child: Text('1')),
              DropdownMenuItem(value: 2, child: Text('2')),
              DropdownMenuItem(value: 3, child: Text('3')),
              DropdownMenuItem(value: 4, child: Text('4')),
            ],
            onChanged: (value) => setState(() => columns = value ?? 0),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<double>(
            initialValue: cardHeight,
            decoration: const InputDecoration(labelText: 'Высота карточек', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 140, child: Text('Компактная — 140')),
              DropdownMenuItem(value: 150, child: Text('Обычная — 150')),
              DropdownMenuItem(value: 180, child: Text('Высокая — 180')),
              DropdownMenuItem(value: 220, child: Text('Очень высокая — 220')),
            ],
            onChanged: (value) => setState(() => cardHeight = value ?? 150),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: navigation,
            decoration: const InputDecoration(labelText: 'Навигация', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'auto', child: Text('Авто')),
              DropdownMenuItem(value: 'bottom', child: Text('Нижняя панель')),
              DropdownMenuItem(value: 'side', child: Text('Боковая панель')),
            ],
            onChanged: (value) => setState(() => navigation = value ?? 'auto'),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _save, child: const Text('Сохранить')),
        ],
      ),
    );
  }
}
