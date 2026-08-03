import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/field_definition.dart';
import '../../domain/types/field_type.dart';

import '../providers/field_provider.dart';
import '../providers/field_service_provider.dart';


class AddFieldPage extends ConsumerStatefulWidget {
  final String collectionId;

  const AddFieldPage({
    super.key,
    required this.collectionId,
  });

  @override
  ConsumerState<AddFieldPage> createState() =>
      _AddFieldPageState();
}


class _AddFieldPageState
    extends ConsumerState<AddFieldPage> {

  final TextEditingController controller =
      TextEditingController();

  FieldType selectedType =
      FieldType.text;


  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }


  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Добавить поле',
        ),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          children: [
            TextField(
              controller:
                  controller,

              decoration:
                  const InputDecoration(
                labelText:
                    'Название поля',
              ),
            ),

            const SizedBox(
              height:20,
            ),

            DropdownButtonFormField<FieldType>(
              initialValue:
                  selectedType,

              decoration:
                  const InputDecoration(
                labelText:
                    'Тип поля',
              ),

              items:
                  FieldType.values
                      .map(
                        (type) =>
                            DropdownMenuItem(
                          value:type,
                          child:
                              Text(type.name),
                        ),
                      )
                      .toList(),

              onChanged:
                  (value) {
                if(value == null){
                  return;
                }

                setState(() {
                  selectedType =
                      value;
                });
              },
            ),

            const Spacer(),

            SizedBox(
              width:
                  double.infinity,

              child:
                  ElevatedButton(

                child:
                    const Text(
                  'Создать',
                ),

                onPressed:
                    () async {

                  final label =
                      controller.text.trim();

                  if(label.isEmpty){
                    return;
                  }

                  final navigator =
                      Navigator.of(
                        context,
                      );

                  final field =
                      FieldDefinition(
                    id:
                        DateTime.now()
                            .microsecondsSinceEpoch
                            .toString(),

                    collectionId:
                        widget.collectionId,

                    label:
                        label,

                    type:
                        selectedType,
                  );


                  final service =
                      await ref.read(
                    fieldServiceProvider.future,
                  );


                  await service.addField(
                    field,
                  );


                  ref.invalidate(
                    fieldsProvider(
                      widget.collectionId,
                    ),
                  );


                  if(!mounted){
                    return;
                  }


                  navigator.pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}