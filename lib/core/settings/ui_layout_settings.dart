import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Единые настройки сетки и высоты карточек для экранов каталога.
///
/// Настройки хранятся локально и сразу сообщают всем открытым экранам
/// об изменении через [revision]. Это важно для IndexedStack: экран может
/// оставаться смонтированным, пока пользователь меняет настройки в другом.
class UiLayoutSettings {
  UiLayoutSettings._();

  static const columnsKey = 'ui.columns';
  static const densityKey = 'ui.density';
  static const navigationKey = 'ui.navigation';
  static const cardHeightKey = 'ui.cardHeight';

  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static int columns = 0;
  static String density = 'auto';
  static String navigation = 'auto';
  static double cardHeight = 150;
  static bool _loaded = false;

  static Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.reload();
    columns = (preferences.getInt(columnsKey) ?? 0).clamp(0, 4);
    density = preferences.getString(densityKey) ?? 'auto';
    navigation = preferences.getString(navigationKey) ?? 'auto';
    cardHeight = (preferences.getDouble(cardHeightKey) ?? 150).clamp(110, 220).toDouble();
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
      UiLayoutSettings.columns = columns.clamp(0, 4);
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
    if (cardHeight != null) {
      UiLayoutSettings.cardHeight = cardHeight.clamp(110, 220).toDouble();
      await preferences.setDouble(cardHeightKey, UiLayoutSettings.cardHeight);
    }
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
}
