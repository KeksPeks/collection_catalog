import 'package:flutter/material.dart';


import '../../domain/entities/collection.dart';




class CollectionCard extends StatelessWidget {


  final Collection collection;



  final VoidCallback? onTap;



  const CollectionCard({


    super.key,


    required this.collection,


    this.onTap,


  });





  @override
  Widget build(BuildContext context) {


    return Card(


      margin:

          const EdgeInsets.all(12),



      child:

          ListTile(


            title:

                Text(

                  collection.name,

                ),



            subtitle:

                Text(

                  collection.templateId == null

                      ?

                      'Без шаблона'


                      :

                      'Шаблон: ${collection.templateId}',

                ),



            trailing:

                const Icon(

                  Icons.arrow_forward_ios,

                  size:16,

                ),



            onTap:onTap,

          ),


    );


  }


}