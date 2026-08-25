import 'package:flutter/material.dart';

import '../../../../core/settings/ui_layout_settings.dart';

/// Резервный экран настроек для отдельных маршрутов.
/// Основной экран приложения находится в CollectionCatalogApp.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    UiLayoutSettings.ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.grid_view_rounded),
              title: const Text('Настройки интерфейса'),
              subtitle: Text('${UiLayoutSettings.columns == 0 ? 'Авто' : UiLayoutSettings.columns} колонок · ${_densityName(UiLayoutSettings.density)}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: _showInterfaceSettings,
            ),
          ),
        ],
      ),
    );
  }

  String _densityName(String value) {
    switch (value) {
      case 'compact': return 'Компактная плотность';
      case 'normal': return 'Обычная плотность';
      case 'spacious': return 'Просторная плотность';
      default: return 'Авто';
    }
  }

  Future<void> _showInterfaceSettings() async {
    await UiLayoutSettings.ensureLoaded();
    if (!mounted) return;
    var columns = UiLayoutSettings.columns;
    var density = UiLayoutSettings.density;
    var navigation = UiLayoutSettings.navigation;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setState) => SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Настройки интерфейса', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
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
              FilledButton(
                onPressed: () async {
                  await UiLayoutSettings.save(columns: columns, density: density, navigation: navigation);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
                child: const Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
    if (mounted) setState(() {});
  }
}
