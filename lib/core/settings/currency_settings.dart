import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyOption {
  final String code;
  final String symbol;
  final Map<String, String> names;
  const CurrencyOption(this.code, this.symbol, this.names);
  String name(Locale locale) => names[locale.languageCode] ?? names['en'] ?? code;
}

class CurrencySettings {
  CurrencySettings._();
  static const key = 'settings.currency';

  static const options = <CurrencyOption>[
    CurrencyOption('USD', r'$', {'ru':'Доллар США','en':'US dollar','de':'US-Dollar','fr':'Dollar américain','es':'Dólar estadounidense','it':'Dollaro USA','pt':'Dólar americano','zh':'美元','ja':'米ドル','ko':'미국 달러','ar':'الدولار الأمريكي'}),
    CurrencyOption('EUR', '€', {'ru':'Евро','en':'Euro','de':'Euro','fr':'Euro','es':'Euro','it':'Euro','pt':'Euro','zh':'欧元','ja':'ユーロ','ko':'유로','ar':'اليورو'}),
    CurrencyOption('RUB', '₽', {'ru':'Рубль','en':'Russian ruble','de':'Russischer Rubel','fr':'Rouble russe','es':'Rublo ruso','it':'Rublo russo','pt':'Rublo russo','zh':'俄罗斯卢布','ja':'ロシアルーブル','ko':'러시아 루블','ar':'الروبل الروسي'}),
    CurrencyOption('GBP', '£', {'ru':'Фунт стерлингов','en':'British pound','de':'Britisches Pfund','fr':'Livre sterling','es':'Libra esterlina','it':'Sterlina britannica','pt':'Libra esterlina','zh':'英镑','ja':'英ポンド','ko':'영국 파운드','ar':'الجنيه الإسترليني'}),
    CurrencyOption('CHF', 'CHF', {'ru':'Швейцарский франк','en':'Swiss franc','de':'Schweizer Franken','fr':'Franc suisse','es':'Franco suizo','it':'Franco svizzero','pt':'Franco suíço','zh':'瑞士法郎','ja':'スイスフラン','ko':'스위스 프랑','ar':'الفرنك السويسري'}),
  ];

  static String code = 'EUR';

  static CurrencyOption get selected => options.firstWhere((item) => item.code == code);

  static Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    final saved = preferences.getString(key);
    if (options.any((item) => item.code == saved)) {
      code = saved!;
    }
  }

  static Future<void> setCode(String value) async {
    if (!options.any((item) => item.code == value)) return;
    code = value;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(key, value);
  }

  static String label(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return '${selected.symbol} ${selected.name(locale)}';
  }
}
