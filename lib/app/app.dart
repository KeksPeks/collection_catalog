import 'package:flutter/material.dart';


import '../features/collections/presentation/pages/collections_page.dart';



class MyApp extends StatelessWidget {


  const MyApp({

    super.key,

  });



  @override
  Widget build(BuildContext context) {


    return MaterialApp(

      debugShowCheckedModeBanner:false,


      title:
          'Collection Catalog',



      theme:
          ThemeData(

            colorScheme:
                ColorScheme.fromSeed(

                  seedColor:
                      Colors.blue,

                ),


            useMaterial3:true,

          ),



      home:
          const MainNavigation(),


    );


  }


}





class MainNavigation extends StatefulWidget {


  const MainNavigation({

    super.key,

  });



  @override
  State<MainNavigation> createState() =>
      _MainNavigationState();


}





class _MainNavigationState
    extends State<MainNavigation> {


  int currentIndex = 0;



  final pages = <Widget>[


    const Center(

      child:
          Text(

            'Каталог',

          ),

    ),



    const Center(

      child:
          Text(

            'Загрузки',

          ),

    ),



    const CollectionsPage(),



    const Center(

      child:
          Text(

            'Настройки',

          ),

    ),


  ];



  @override
  Widget build(BuildContext context) {


    return Scaffold(

      body:
          pages[currentIndex],



      bottomNavigationBar:
          NavigationBar(


            selectedIndex:
                currentIndex,



            onDestinationSelected:
                (index){


                  setState(() {


                    currentIndex =
                        index;


                  });


                },



            destinations:[


              const NavigationDestination(

                icon:
                    Icon(

                      Icons.menu_book,

                    ),

                label:
                    'Каталог',

              ),



              const NavigationDestination(

                icon:
                    Icon(

                      Icons.download,

                    ),

                label:
                    'Загрузки',

              ),



              const NavigationDestination(

                icon:
                    Icon(

                      Icons.collections,

                    ),

                label:
                    'Коллекция',

              ),



              const NavigationDestination(

                icon:
                    Icon(

                      Icons.settings,

                    ),

                label:
                    'Настройки',

              ),


            ],


          ),


    );


  }


}