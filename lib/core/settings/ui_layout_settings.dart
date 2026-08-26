import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Единые настройки сетки для экранов каталога и избранного.
///
/// Высота карточек не хранится: интерфейс рассчитывает её адаптивно
/// от размера текста и доступной ширины.
class UiLayoutSettings {
  UiLayoutSettings._();

  static const columnsKey = 'ui.columns';
  static const densityKey = 'ui.density';
  static const navigationKey = 'ui.navigation';

  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  /// 0 — автоматически, 1..4 — принудительное число колонок.
  static int columns = 0;
  static String density = 'auto';
  static String navigation = 'auto';
  static bool _loaded = false;

  /// Временная совместимость со старыми экранами.
  /// Фактическая высота карточек больше не является настройкой пользователя.
  static double get cardHeight => 150.0;

  static Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.reload();
    columns = (preferences.getInt(columnsKey) ?? 0).clamp(0, 4).toInt();
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
    double? cardHeight,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    if (columns != null) {
      UiLayoutSettings.columns = columns.clamp(0, 4).toInt();
      await preferences.setInt(columnsKey, UiLayoutSettings.columns);
    }
    if (density != null) {
      UiLayoutSettings.density = density;
      await preferences.setString(densityKey, density);
    }
    if (navigation != null) {
      UiLayoutSettings.navigation = navigation;
      await preferences.setString(navigationKey, navigation);
    }
    // cardHeight намеренно не сохраняется: высота карточек вычисляется адаптивно.
    _loaded = true;
    revision.value++;
  }

  static int resolveColumns(double width, {int? requested}) {
    final configured = requested ?? columns;
    if (configured >= 1 && configured <= 4) return configured;
    if (width < 420) return 1;
    if (width < 700) return 2;
    if (width < 1050) return 3;
    return 4;
  }

  /// Высота карточки адаптируется к ширине колонки и масштабу текста.
  static double resolveCardHeight({
    required double width,
    required int columns,
    required double textScale,
  }) {
    final safeColumns = columns.clamp(1, 4).toDouble();
    final columnWidth = (width - ((safeColumns - 1) * 12)) / safeColumns;
    final base = columnWidth < 150
        ? 122.0
        : columnWidth < 220
            ? 128.0
            : 136.0;
    final scaleAdjustment = (textScale - 1.0).clamp(-0.3, 0.8) * 32;
    return (base + scaleAdjustment).clamp(112.0, 170.0).toDouble();
  }
}
