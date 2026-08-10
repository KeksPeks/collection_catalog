import 'package:flutter/material.dart';

import '../../domain/entities/field_definition.dart';
import 'field_component.dart';

/// Компонент выбора даты.
class DateFieldComponent implements FieldComponent {
  const DateFieldComponent();

  @override
  Widget build({
    required FieldDefinition definition,
    required String? value,
    required ValueChanged<String> onChanged,
  }) {
    DateTime? selectedDate = DateTime.tryParse(value ?? '');

    return StatefulBuilder(
      builder: (context, setState) {
        return InputDecorator(
          decoration: InputDecoration(
            labelText: definition.label,
            border: const OutlineInputBorder(),
          ),
          child: InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime(2100),
              );

              if (date == null) {
                return;
              }

              selectedDate = date;
              setState(() {});
              onChanged(date.toIso8601String().split('T').first);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedDate == null
                          ? 'Выберите дату'
                          : selectedDate!.toIso8601String().split('T').first,
                    ),
                  ),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
