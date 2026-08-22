import 'package:flutter/material.dart';

import '../../domain/conditions/condition_grade.dart';
import '../../domain/conditions/condition_grade_catalog.dart';
import '../../domain/entities/field_definition.dart';
import 'field_component.dart';

/// Компонент выбора состояния предмета.
///
/// Шкала выбирается автоматически по направлению коллекции.
class ConditionFieldComponent implements FieldComponent {
  const ConditionFieldComponent();

  @override
  Widget build({
    required FieldDefinition definition,
    required String? value,
    required ValueChanged<String> onChanged,
  }) {
    final grades = ConditionGradeCatalog.forCollection(definition.collectionId);
    final selected = grades.where((grade) => grade.code == value).firstOrNull;

    return DropdownButtonFormField<String>(
      initialValue: selected?.code,
      decoration: InputDecoration(
        labelText: definition.label,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.verified_outlined),
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('—'),
        ),
        ...grades.map(
          (grade) => DropdownMenuItem<String>(
            value: grade.code,
            child: Text(_label(grade, WidgetsBinding.instance.platformDispatcher.locale)),
          ),
        ),
      ],
      onChanged: (next) {
        if (next != null && next.isNotEmpty) {
          onChanged(next);
        }
      },
    );
  }

  String _label(ConditionGrade grade, Locale locale) {
    final language = locale.languageCode.toLowerCase();
    final labels = <String, Map<String, String>>{
      'unc': {'ru': 'UNC — без следов обращения', 'en': 'UNC — Uncirculated'},
      'bunc': {'ru': 'BU/БUNC — улучшенное не бывшее в обращении', 'en': 'BU/BUNC — Brilliant Uncirculated'},
      'vf': {'ru': 'VF — очень хорошее', 'en': 'VF — Very Fine'},
      'xf': {'ru': 'XF — исключительно хорошее', 'en': 'XF — Extremely Fine'},
      'au': {'ru': 'AU — почти не бывшее в обращении', 'en': 'AU — About Uncirculated'},
      'proof': {'ru': 'Proof — пруф', 'en': 'Proof'},
      'bu': {'ru': 'BU — Brilliant Uncirculated', 'en': 'BU — Brilliant Uncirculated'},
      'circulated': {'ru': 'В обращении', 'en': 'Circulated'},
      'damaged': {'ru': 'Повреждённое', 'en': 'Damaged'},
      'nm': {'ru': 'NM — почти идеальное', 'en': 'NM — Near Mint'},
      'lp': {'ru': 'LP — лёгкие следы использования', 'en': 'LP — Lightly Played'},
      'mp': {'ru': 'MP — заметные следы использования', 'en': 'MP — Moderately Played'},
      'hp': {'ru': 'HP — сильные следы использования', 'en': 'HP — Heavily Played'},
      'dmg': {'ru': 'DMG — повреждённое', 'en': 'DMG — Damaged'},
      'sealed': {'ru': 'Sealed — запечатано', 'en': 'Sealed'},
      'cib': {'ru': 'CIB — комплект с коробкой и вложениями', 'en': 'CIB — Complete In Box'},
      'complete': {'ru': 'Complete — полный комплект', 'en': 'Complete'},
      'discOnly': {'ru': 'Disc Only — только диск', 'en': 'Disc Only'},
      'boxOnly': {'ru': 'Box Only — только коробка', 'en': 'Box Only'},
      'manualOnly': {'ru': 'Manual Only — только руководство', 'en': 'Manual Only'},
      'missingParts': {'ru': 'Не полный комплект', 'en': 'Missing Parts'},
      'opened': {'ru': 'Открыто', 'en': 'Opened'},
      'mint': {'ru': 'Идеальное', 'en': 'Mint'},
      'excellent': {'ru': 'Отличное', 'en': 'Excellent'},
      'veryGood': {'ru': 'Очень хорошее', 'en': 'Very Good'},
      'good': {'ru': 'Хорошее', 'en': 'Good'},
      'fair': {'ru': 'Удовлетворительное', 'en': 'Fair'},
      'poor': {'ru': 'Плохое', 'en': 'Poor'},
      'unknown': {'ru': 'Не указано', 'en': 'Not specified'},
    };

    final values = labels[grade.code];
    return values?[language] ?? values?['en'] ?? grade.code;
  }
}
