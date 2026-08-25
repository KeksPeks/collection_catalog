import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Единые настройки сетки для каталогов, избранного и моих коллекций.
///
/// Фиксированная высота строк больше не хранится: высота рассчитывается
/// от размера текста и доступной ширины конкретного экрана.
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
    @Deprecated('Фиксированная высота карточек больше не поддерживается') double? cardHeight,
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
    // Старый параметр cardHeight намеренно игнорируется: высота теперь адаптивная.
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

  /// Совместимое значение для старого adaptive_app.dart.
  /// Новые экраны не используют фиксированную высоту.
  static double get cardHeight => 148.0;

  /// Адаптивная высота карточки для сеток.
  ///
  /// Чем меньше ширина колонки и чем больше шрифт, тем больше места
  /// выделяется карточке. Это предотвращает Bottom overflow при 3–4 колонках.
  static double resolveCardHeight({
    required double width,
    required int columns,
    double textScale = 1.0,
  }) {
    final safeColumns = columns.clamp(1, 4);
    final spacing = (safeColumns - 1) * 12.0;
    final columnWidth = ((width - spacing) / safeColumns).clamp(80.0, 1000.0);
    final compact = columnWidth < 150;
    final base = compact ? 132.0 : columnWidth < 220 ? 140.0 : 148.0;
    final scale = textScale.clamp(0.75, 1.40);
    return (base * scale).clamp(108.0, 210.0);
  }
}
