import 'app_localizations.dart';

/// Дополнительные строки интерфейса без изменения существующего словаря локализации.
extension AppLocalizationsUiExtension on AppLocalizations {
  String get overview => _value('overview', 'Обзор', 'Overview');
  String get columns => _value('columns', 'Количество колонок', 'Columns');
  String get theme => _value('theme', 'Тема', 'Theme');
  String get colorScheme => _value('colorScheme', 'Цветовая схема', 'Color scheme');

  String _value(String key, String ru, String en) {
    if (locale.languageCode == 'ru') return ru;
    if (locale.languageCode == 'en') return en;
    return en;
  }
}
