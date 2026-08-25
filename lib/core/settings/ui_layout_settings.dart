import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Единые настройки навигации и адаптивной сетки.
/// Фиксированный размер интерфейса и пользовательское число колонок не используются.
class UiLayoutSettings {
  UiLayoutSettings._();

  static const columnsKey = 'ui.columns';
  static const densityKey = 'ui.density';
  static const navigationKey = 'ui.navigation';

  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static int columns = 0;
  static String density = 'auto';
  static String navigation = 'auto';
  static bool _loaded = false;

  static Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.reload();
    // Старое значение columns читаем только для совместимости с сохранёнными данными.
    columns = 0;
    density = preferences.getString(densityKey) ?? 'auto';
    navigation = preferences.getString(navigationKey) ?? 'auto';
    _loaded = true;
    revision.value++;
  }

  static Future<void> ensureLoaded() async {
    if (!_loaded) await load();
  }

  static Future<void> save({
    int? columns,
    String? density,
    String? navigation,
    @Deprecated('Фиксированная высота карточек больше не поддерживается') double? cardHeight,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    // Параметр columns оставлен в сигнатуре для совместимости со старыми вызовами.
    if (columns != null) await preferences.remove(columnsKey);
    if (density != null) {
      UiLayoutSettings.density = density;
      await preferences.setString(densityKey, density);
    }
    if (navigation != null) {
      UiLayoutSettings.navigation = navigation;
      await preferences.setString(navigationKey, navigation);
    }
    _loaded = true;
    revision.value++;
  }

  /// Количество колонок всегда определяется доступной шириной.
  /// Пользовательское значение из старых версий намеренно игнорируется.
  static int resolveColumns(double width, {int? requested}) {
    if (width < 420) return 1;
    if (width < 700) return 2;
    if (width < 1050) return 3;
    return 4;
  }

  /// Совместимое значение для старого кода. Новые экраны его не используют.
  static double get cardHeight => 148.0;

  /// Адаптивная высота для старых экранов, где ещё используется этот метод.
  static double resolveCardHeight({required double width, required int columns, double textScale = 1.0}) {
    final safeColumns = columns.clamp(1, 4);
    final spacing = (safeColumns - 1) * 12.0;
    final columnWidth = ((width - spacing) / safeColumns).clamp(80.0, 1000.0);
    final compact = columnWidth < 150;
    final base = compact ? 132.0 : columnWidth < 220 ? 140.0 : 148.0;
    final scale = textScale.clamp(0.75, 1.40).toDouble();
    return (base * scale).clamp(108.0, 210.0).toDouble();
  }
}
