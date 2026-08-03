import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/collection_section_provider.dart';
import '../providers/collection_section_service_provider.dart';

import '../../domain/entities/collection_section.dart';



class CollectionSectionsPage extends ConsumerWidget {

  final String collectionId;

  final String collectionName;


  const CollectionSectionsPage({

    super.key,

    required this.collectionId,

    required this.collectionName,

  });



  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {


    final sections =
        ref.watch(
          collectionSectionsProvider(
            collectionId,
          ),
        );


    return Scaffold(

      appBar: AppBar(

        title: Text(
          collectionName,
        ),

      ),


      body:

          sections.when(

        loading: () =>
            const Center(
              child:
                  CircularProgressIndicator(),
            ),


        error: (error, stack) =>
            Center(
              child:
                  Text(
                error.toString(),
              ),
            ),


        data: (items) {


          if(items.isEmpty){

            return const Center(
              child:
                  Text(
                'Разделов пока нет',
              ),
            );

          }


          return ListView.builder(

            itemCount:
                items.length,


            itemBuilder:
                (context,index){


              final section =
                  items[index];


              return ListTile(

                title:
                    Text(
                  section.name,
                ),

              );


            },

          );

        },

      ),



      floatingActionButton:

          FloatingActionButton(

        child:
            const Icon(
          Icons.add,
        ),


        onPressed: () async {


          final controller =
              TextEditingController();


          final name =
              await showDialog<String>(

            context: context,


            builder:
                (dialogContext){

              return AlertDialog(

                title:
                    const Text(
                  'Новый раздел',
                ),


                content:
                    TextField(

                  controller:
                      controller,

                  decoration:
                      const InputDecoration(
                    hintText:
                        'Название',
                  ),

                ),



                actions: [

                  TextButton(

                    onPressed: (){

                      Navigator.pop(
                        dialogContext,
                      );

                    },


                    child:
                        const Text(
                      'Отмена',
                    ),

                  ),


                  ElevatedButton(

                    onPressed: (){

                      Navigator.pop(
                        dialogContext,
                        controller.text.trim(),
                      );

                    },


                    child:
                        const Text(
                      'Создать',
                    ),

                  ),

                ],

              );

            },

          );


          controller.dispose();


          if(name == null ||
             name.isEmpty){

            return;

          }



          final service =
              await ref.read(
                collectionSectionServiceProvider.future,
              );



          final now =
              DateTime.now();



          final section =
              CollectionSection(

            id:
                now.microsecondsSinceEpoch.toString(),

            collectionId:
                collectionId,

            name:
                name,

            createdAt:
                now,

            updatedAt:
                now,

          );



          await service.createSection(
            section,
          );


          ref.invalidate(
            collectionSectionsProvider(
              collectionId,
            ),
          );


        },

      ),

    );

  }

}