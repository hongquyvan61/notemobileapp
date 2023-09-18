import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:notemobileapp/DAL/NoteContentDAL.dart';
import 'package:notemobileapp/DAL/NoteDAL.dart';
import 'package:notemobileapp/model/NoteContentModel.dart';
import 'package:notemobileapp/model/initializeDB.dart';
import 'package:notemobileapp/router.dart';

import '../model/NoteModel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {
  NoteDAL nDAL = NoteDAL();
  NoteContentDAL noteContentDAL = NoteContentDAL();
  late List<NoteModel> listofnote = <NoteModel>[];
  late List<String> listofBriefContent = <String>[];
  late List<File> listofTitleImage = <File>[];
  bool isOffline = false;
  late StreamSubscription subscription;

  @override
  void initState() {
    super.initState();
    //SUA USER ID O DAY
    //SUA USER ID O DAY
    //SUA USER ID O DAY
    //SUA USER ID O DAY
    //SUA USER ID O DAY
    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.chasingDots
      ..loadingStyle = EasyLoadingStyle.dark;

    AssignSubscription();
    InitiateListOfNote();
  }

  @override
  void dispose() {
    subscription.cancel();
  }

  AssignSubscription() {
    subscription =
        Connectivity().onConnectivityChanged.listen(ConnectionListener);
  }

  void ConnectionListener(ConnectivityResult result) async {
    if (result != ConnectivityResult.none) {
      isOffline = await InternetConnectionChecker().hasConnection;
    }
  }

  InitiateListOfNote() async {
    if (!isOffline) {
      listofnote =
          await nDAL.getAllNotesByUserID(1, InitDataBase.db).catchError(
        (Object e, StackTrace stackTrace) {
          debugPrint(e.toString());
        },
      );
      listofTitleImage = await generateListTitleImage(listofnote);
      setState(() {});
    }
  }

  void ReloadNoteListAtLocal(Object? result) async {
    if (result.toString() == 'RELOAD_LIST') {
      await EasyLoading.show(
        status: "Đang load danh sách ghi chú...",
        maskType: EasyLoadingMaskType.none,
      );
      listofnote =
          await nDAL.getAllNotesByUserID(1, InitDataBase.db).catchError(
        (Object e, StackTrace stackTrace) {
          debugPrint(e.toString());
        },
      );
      listofBriefContent.clear();
      listofTitleImage = await generateListTitleImage(listofnote);
      setState(() {});
      await EasyLoading.dismiss();
    } else {
      debugPrint('Du lieu tra ve tu new note screen bi loi');
    }
  }

  Future<List<File>> generateListTitleImage(List<NoteModel> lst) async {
    late List<File> lstimage = <File>[];
    // List<NoteContentModel> temp1 = await noteContentDAL.getAllNoteContentsById(InitDataBase.db, 1);
    // bool checkdel1 = await nDAL.deleteNote(6, InitDataBase.db);
    // bool checkdel2 = await nDAL.deleteNote(7, InitDataBase.db);
    // List<NoteModel> temp3 = await nDAL.getAllNotes(InitDataBase.db);
    for (int i = 0; i < lst.length; i++) {
      int? noteid = lst[i].note_id;
      String imagestr = await noteContentDAL.getTitleImageofNote(
          lst[i].note_id, InitDataBase.db);
      if (imagestr != '') {
        File imagetemp = File(imagestr);
        lstimage.add(imagetemp);
      } else {
        File emptyfile = File('');
        lstimage.add(emptyfile);
      }
      String briefcontent = await noteContentDAL.getBriefContentofNote(
          lst[i].note_id, InitDataBase.db);
      listofBriefContent.add(briefcontent);
    }
    return lstimage;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Color.fromARGB(255, 249, 253, 255),
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(0, 0, 0, 0),
            elevation: 0.0,
            title: const Text(
              'Ghi chú của tôi',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            actions: [IconButton(onPressed: (){
              FirebaseAuth.instance.signOut();
            }, icon: const Icon(Icons.account_circle), color: Colors.black,)],
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

          body: Container(
            margin: const EdgeInsets.all(5),
            child: Container(
              padding: const EdgeInsets.all(5),
              child: Stack(children: [
                Container(
                    child: Expanded(
                  flex: 3,
                  child: ListView.separated(
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 255, 255, 255),
                              border:
                                  Border.all(width: 1.0, color: Colors.grey),
                              borderRadius: BorderRadius.circular(8.0)),
                          // Text(listofnote[index].title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                          //                 SizedBox(height: 5,),
                          //                 Text(listofnote[index].date_created, style: const TextStyle(fontSize: 12, color: Colors.grey),)
                          // Image.file(listofTitleImage[index], width: 300, height: 300, fit: BoxFit.cover,)
                          child: Column(
                            children: [
                              ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor:
                                      Color.fromARGB(255, 68, 196, 140),
                                  child: Icon(
                                    Icons.turned_in_not_outlined,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  listofnote[index].title,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  listofnote[index].date_created,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(3, 0, 3, 0),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: (listofTitleImage[index]).path == ''
                                        ? null
                                        : Image.file(
                                            listofTitleImage[index],
                                            width: 330,
                                            height: 200,
                                            fit: BoxFit.cover,
                                          )),
                              ),
                              Container(
                                margin: EdgeInsets.all(10),
                                alignment: Alignment.centerLeft,
                                child: Text(listofBriefContent[index],
                                    style: const TextStyle(fontSize: 12)),
                              )
                            ],
                          ));
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        const Divider(),
                    itemCount: listofnote.length,
                  ),
                )),
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
                        onPressed: () async {
                          final resultfromNewNote = await Navigator.of(context)
                              .pushNamed(RoutePaths.newnote);
                          ReloadNoteListAtLocal(resultfromNewNote);
                        },
                        style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder(),
                            backgroundColor:
                                const Color.fromARGB(255, 97, 115, 239)),
                        label: const Text(
                          'Tạo ghi chú',
                          style: TextStyle(fontSize: 16),
                        ),
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
              ]),
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
