import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Единые настройки навигации и сетки каталога.
/// Высота карточек не является пользовательской настройкой: она рассчитывается экраном.
class UiLayoutSettings {
  UiLayoutSettings._();

  static const columnsKey = 'ui.columns';
  static const densityKey = 'ui.density';
  static const navigationKey = 'ui.navigation';

  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  /// 0 = автоматически, 1..4 = выбранное число колонок.
  static int columns = 0;
  static String density = 'auto';
  static String navigation = 'auto';
  static bool _loaded = false;

  static Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.reload();
    final savedColumns = preferences.getInt(columnsKey) ?? 0;
    columns = savedColumns.clamp(0, 4);
    density = preferences.getString(densityKey) ?? 'auto';
    navigation = preferences.getString(navigationKey) ?? 'auto';
    _loaded = true;
    revision.value++;
  }

  static Future<void> ensureLoaded() async {
    if (!_loaded) await load();
  }

  static Future<void> save({int? columns, String? density, String? navigation}) async {
    final preferences = await SharedPreferences.getInstance();
    if (columns != null) {
      UiLayoutSettings.columns = columns.clamp(0, 4);
      if (UiLayoutSettings.columns == 0) {
        await preferences.remove(columnsKey);
      } else {
        await preferences.setInt(columnsKey, UiLayoutSettings.columns);
      }
    }
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

  static int resolveColumns(double width) {
    final selected = columns;
    if (selected >= 1 && selected <= 4) return selected;
    if (width < 420) return 1;
    if (width < 700) return 2;
    if (width < 1050) return 3;
    return 4;
  }
}
