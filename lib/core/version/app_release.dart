import 'package:flutter/material.dart';

class AppRelease {
  AppRelease._();

  static const version = '1.1.0';
  static const build = 2;

  static const _changes = <String, List<String>>{
    'ru': [
      'Добавлены 31 направления коллекционирования.',
      'Исправлено отображение избранных каталогов на главном экране.',
      'Добавлена локализованная система названий направлений.',
      'Добавлен выбор валюты: USD, EUR, RUB, GBP, CHF.',
      'Сохранены централизованная структура каталога и режим только для чтения.',
    ],
    'en': [
      'Added 31 collection directions.',
      'Fixed favorite catalogs on the main screen.',
      'Added localized direction names.',
      'Added currency selection: USD, EUR, RUB, GBP, CHF.',
      'Preserved centralized catalog structure and read-only mode.',
    ],
  };

  static List<String> changes(Locale locale) =>
      _changes[locale.languageCode] ?? _changes['en']!;

  static String summary(Locale locale) => changes(locale).join(' ');
}
