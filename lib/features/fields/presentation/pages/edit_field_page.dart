import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/field_definition.dart';

import '../providers/field_provider.dart';
import '../providers/field_service_provider.dart';


class EditFieldPage extends ConsumerStatefulWidget {
  final FieldDefinition field;

  const EditFieldPage({
    super.key,
    required this.field,
  });

  @override
  ConsumerState<EditFieldPage> createState() =>
      _EditFieldPageState();
}


class _EditFieldPageState
    extends ConsumerState<EditFieldPage> {

  late final TextEditingController controller;


  @override
  void initState() {
    super.initState();

    controller =
        TextEditingController(
          text:
              widget.field.label,
        );
  }


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
      appBar:
          AppBar(
        title:
            const Text(
          'Редактирование поля',
        ),
      ),

      body:
          Padding(
        padding:
            const EdgeInsets.all(16),

        child:
            Column(
          children: [

            TextField(
              controller:
                  controller,

              decoration:
                  const InputDecoration(
                labelText:
                    'Название',
              ),
            ),

            const SizedBox(
              height:24,
            ),

            SizedBox(
              width:
                  double.infinity,

              child:
                  ElevatedButton(

                child:
                    const Text(
                  'Сохранить',
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


                  final service =
                      await ref.read(
                    fieldServiceProvider.future,
                  );


                  await service.updateField(
                    widget.field.copyWith(
                      label:
                          label,
                    ),
                  );


                  ref.invalidate(
                    fieldsProvider(
                      widget.field.collectionId,
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