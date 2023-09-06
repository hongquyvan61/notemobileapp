import 'package:flutter/material.dart';
import 'package:notemobileapp/router.dart';

class HomeScreen extends StatefulWidget{
  const HomeScreen({super.key});
  
  @override
  State<StatefulWidget> createState() {
    return HomeScreenState();
  }
  
}

class HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(

          child: Scaffold(
            
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(131, 0, 0, 0),
              elevation: 0.0,
              title: const Text('Ghi chú của tôi', style: TextStyle(fontWeight: FontWeight.bold),),
              centerTitle: true,
            ),

            // body: Container(
            //   alignment: Alignment.center,
            //   // child: Column(
            //   //   children: [
            //   //      Text(
            //   //       'Nhan giu de viet ghi chu bang giong noi!',
            //   //       style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
            //   //       ),

            //   //       ElevatedButton(
            //   //         onPressed: () {
            //   //           print('button pressed!');
            //   //         },
            //   //         child: Text('Next'),
            //   //       ),

            //   //   ],
            //   // ) ,
            //   child: ElevatedButton(
            //           onPressed: ()
            //           {
            //           print('button pressed!');
            //           }, 
            //           child: Text('ahihi'),
            //   ),
              
            // )

            body: 
             Container(
              margin: const EdgeInsets.all(5),
              child: 
                Container(
                  padding: const EdgeInsets.all(5),
                  child: Stack(
                  children: [
                    Container(
                      child: 
                      const Expanded(
                        flex: 3,
                        child: SizedBox(),
                      )
                    ),
                    Container(
                      child: Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: ElevatedButton.icon(
                                  icon: const Icon(
                                    Icons.add,
                                    size: 16.0,
                                  ),
                                  onPressed: (){
                                    Navigator.of(context).pushNamed(RoutePaths.newnote);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    shape: const StadiumBorder(),
                                    backgroundColor: const Color.fromARGB(255,97,115,239)),
                                  label: const Text('Tạo ghi chú', style: TextStyle(fontSize: 16),),
                                ),
                        ),
                      ),
                    )
                    // const Row(
                    //   children: [
                    //     Expanded(
                    //       flex: 2,
                    //       child: Text('Username', style: TextStyle(color: Colors.grey),)
                    //     ),
                    //     Expanded(
                    //       flex: 3,
                    //       child: Text('abcxyz', style: TextStyle(fontWeight: FontWeight.bold),)
                    //     ),
                    //   ],
                    // ),

                    // const Row(children: [SizedBox(height: 10),],),

                    // const Row(
                    //   children: [
                    //     Expanded(
                    //       flex: 2,
                    //       child: Text('email', style: TextStyle(color: Colors.grey),)
                    //     ),
                    //     Expanded(
                    //       flex: 3,
                    //       child: Text('abcxyz@gmail.com', style: TextStyle(fontWeight: FontWeight.bold),)
                    //     ),
                    //   ],
                    // ),

                    // const Row(children: [SizedBox(height: 10),],),
                
                    // const Row(
                    //   children: [
                    //     Expanded(
                    //       flex: 2,
                    //       child: Text('Address', style: TextStyle(color: Colors.grey),)
                    //     ),
                    //     Expanded(
                    //       flex: 3,
                    //       child: Text('abcxyz 1284712jnj', style: TextStyle(fontWeight: FontWeight.bold),)
                    //     ),
                    //   ],
                    // ),

                    // const Row(children: [SizedBox(height: 10),],),

                    // const Row(
                    //   children: [
                    //      Expanded(
                    //       flex: 1,
                    //       child: ElevatedButton(
                    //           onPressed: null,
                    //           child: Text('Tạo ghi chú'),
                    //         ),
                    //     ),
                    //      SizedBox(width: 10),
                    //      Expanded(
                    //       flex: 1,
                    //       child: ElevatedButton(
                    //           onPressed: null,
                    //           child: Text('ahihi 3'),
                    //         ),
                    //     )
                    //   ],
                      
                    // ),

                    
                  ]
                  ),
                ),
              )

              
              // Row(
              //   mainAxisSize: MainAxisSize.max,
              //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //   children: [
              //       ElevatedButton(
              //               onPressed: ()
              //               {
              //                 print('button pressed!');
              //               }, 
              //               child: const Text('ahihi'),
              //       ),

              //     ElevatedButton(
              //               onPressed: ()
              //               {
              //                 print('button pressed!');
              //               }, 
              //               child: const Text('ahihi 2'),
              //       ),

              //     ElevatedButton(
              //               onPressed: ()
              //               {
              //                 print('button pressed!');
              //               }, 
              //               child: const Text('ahihi 3'),
              //       ),
              //   ],
              // ),


              // Column(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     Container(
              //       padding: const EdgeInsets.all(10),
              //       child: Row(
              //         mainAxisSize: MainAxisSize.min,
              //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //         children: [
              //             Expanded(
              //               flex: 2,
              //               child: Container(
              //                 color: Colors.green,
              //                 child: ElevatedButton(
              //                     onPressed: ()
              //                     {
              //                       print('button pressed!');
              //                     }, 
              //                     child: const Text('ahihi'),
              //                 ),
              //               )
              //             ),
                  
              //             Expanded(
              //               flex: 1,
              //               child: Container(
              //                 color: Colors.red,
              //                 child: ElevatedButton(
              //                     onPressed: ()
              //                     {
              //                       print('button pressed!');
              //                     }, 
              //                     child: const Text('ahihi 2'),
              //                 ),
              //               )
              //             ),
                  
              //             Expanded(
              //               flex: 2,
              //               child: Container(
              //                 child: ElevatedButton(
              //                     onPressed: ()
              //                     {
              //                       print('button pressed!');
              //                     }, 
              //                     child: const Text('ahihi 3'),
              //                 ),
              //               )
              //             )
              //         ],
              //       ),
              //     ),
              //     Center(
              //        child: ElevatedButton(
              //             onPressed: ()
              //             {
              //               print('button pressed!');
              //             }, 
              //             child: const Text('ahihi'),
              //         ),
              //     ),
                  
              //   ],
              // )
            

           
          ),

    );
  }

}