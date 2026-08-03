import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/collection.dart';
import '../providers/collection_service_provider.dart';
import '../providers/collection_provider.dart';



class EditCollectionPage extends ConsumerStatefulWidget {


  final Collection collection;



  const EditCollectionPage({

    super.key,

    required this.collection,

  });



  @override
  ConsumerState<EditCollectionPage> createState()
      => _EditCollectionPageState();



}





class _EditCollectionPageState
    extends ConsumerState<EditCollectionPage> {



  late TextEditingController controller;




  @override
  void initState() {

    super.initState();


    controller =
        TextEditingController(
          text: widget.collection.name,
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
          'Редактировать коллекцию',
        ),

      ),




      body:
          Padding(

        padding:
            const EdgeInsets.all(
          16,
        ),


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
              height:30,
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



                  final name =
                      controller.text.trim();



                  if(name.isEmpty){

                    return;

                  }




                  final updated =
                      Collection(

                    id:
                        widget.collection.id,


                    name:
                        name,


                    templateId:
                        widget.collection.templateId,


                    createdAt:
                        widget.collection.createdAt,


                    updatedAt:
                        DateTime.now(),

                  );




                  await ref
                      .read(
                        collectionServiceProvider,
                      )
                      .updateCollection(
                        updated,
                      );




                  ref.invalidate(
                    collectionsProvider,
                  );



                  if(context.mounted){

                    Navigator.pop(
                      context,
                    );

                  }



                },


              ),

            ),




          ],


        ),


      ),


    );


  }


}