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
import 'package:notemobileapp/newnote/newnote.dart';
import 'package:notemobileapp/router.dart';
import 'package:notemobileapp/test/component/popup_menu.dart';

import '../model/NoteModel.dart';
import '../test/authservice/auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {
  bool loginState = false;
  NoteDAL nDAL = NoteDAL();
  NoteContentDAL noteContentDAL = NoteContentDAL();
  late List<NoteModel> listofnote = <NoteModel>[];
  late List<NoteModel> foundedNote = <NoteModel>[];
  late List<String> listofBriefContent = <String>[];
  late List<File> listofTitleImage = <File>[];
  bool isOffline = false;
  bool listState = true;
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
    checkLogin();
  }

  @override
  void dispose() {
    super.dispose();
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
      foundedNote = listofnote;
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

      //SUA USERID O DAY
      //SUA USERID O DAY
      //SUA USERID O DAY
      listofnote =
          await nDAL.getAllNotesByUserID(1, InitDataBase.db).catchError(
        (Object e, StackTrace stackTrace) {
          debugPrint(e.toString());
        },
      );

      foundedNote = listofnote;

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

    listofBriefContent.clear();
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

  void filterlist(String inputWord) async {
    List<NoteModel> results = [];
    if (inputWord.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      results = listofnote;
    } else {
      results = listofnote
          .where((note) =>
              note.title.toLowerCase().contains(inputWord.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }

    foundedNote = results;
    listofTitleImage = await generateListTitleImage(foundedNote);
    // Refresh the UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: const Color.fromARGB(63, 249, 253, 255),
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(0, 0, 0, 0),
            elevation: 0.0,
            title: const Text(
              'Ghi chú của tôi',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  if (listState) {
                    listState = false;
                  } else {
                    listState = true;
                  }
                  setState(() {});
                },
                icon: listState == true
                    ? const Icon(Icons.list)
                    : const Icon(Icons.grid_view),
                color: Colors.black,
              ),
              PopupMenuButton(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(6))),
                  offset: const Offset(0, 50),
                  icon: const Icon(
                    Icons.account_circle,
                    color: Colors.black,
                  ),
                  itemBuilder: (context) => loginState
                      ? PopUpMenu().accountPopupMenu(context)
                      : PopUpMenu().loginPopupMenu(context))
            ],
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
                  child: Column(children: [
                    TextField(
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                      decoration: const InputDecoration(
                          hintText: "Tìm kiếm nè...",
                          prefixIcon: Icon(Icons.search),
                          filled: true,
                          fillColor: Color.fromARGB(255, 239, 241, 243),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                            width: 0.5,
                          ))),
                      onChanged: (value) => filterlist(value),
                    ),
                    const SizedBox(
                      height: 13,
                    ),
                    Expanded(
                      child: listState == true
                          ? ListView.separated(
                              itemBuilder: (BuildContext context, int index) {
                                return Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 212, 253, 244),
                                      //color: Color.fromARGB(255, 255, 255, 255),
                                      //border: Border.all(width: 0.5, color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 5,
                                          blurRadius: 7,
                                          offset: const Offset(25,
                                              10), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        ListTile(
                                          ///CODE SU KIEN NHAN VAO DE CHUYEN SANG MAN HINH EDIT NOTE
                                          ///CODE SU KIEN NHAN VAO DE CHUYEN SANG MAN HINH EDIT NOTE
                                          ///CODE SU KIEN NHAN VAO DE CHUYEN SANG MAN HINH EDIT NOTE
                                          onTap: () async {
                                            final resultfromNewNote =
                                                await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    NewNoteScreen(
                                                        UserID: 1,
                                                        noteIDedit:
                                                            foundedNote[index]
                                                                    .note_id
                                                                    ?.toInt() ??
                                                                0,
                                                        isEditState: true),
                                              ),
                                            );
                                            ReloadNoteListAtLocal(
                                                resultfromNewNote);
                                          },
                                          leading: const CircleAvatar(
                                            backgroundColor: Color.fromARGB(
                                                255, 97, 115, 239),
                                            child: Icon(
                                              Icons.turned_in_not_outlined,
                                              color: Colors.white,
                                              size: 20,
                                            ),
                                            minRadius: 10,
                                            maxRadius: 17,
                                          ),
                                          title: Text(
                                            foundedNote[index].title,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          subtitle: Text(
                                            foundedNote[index].date_created,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.fromLTRB(
                                              3, 0, 3, 0),
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: (listofTitleImage[index])
                                                          .path ==
                                                      ''
                                                  ? null
                                                  : Image.file(
                                                      listofTitleImage[index],
                                                      width: 290,
                                                      height: 200,
                                                      fit: BoxFit.cover,
                                                    )),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.all(10),
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            listofBriefContent[index],
                                            style:
                                                const TextStyle(fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        )
                                      ],
                                    ));
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) =>
                                      const Divider(height: 15),
                              itemCount: foundedNote.length,
                            )
                          : GridView.builder(
                              itemCount: foundedNote.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 4.0,
                                      mainAxisSpacing: 10.0),
                              itemBuilder: (context, index) {
                                return Container(
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 212, 253, 244),
                                      //border: Border.all(width: 0.5, color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 3,
                                          blurRadius: 7,
                                          offset: const Offset(15,
                                              10), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: ListTile(
                                            onTap: () async {
                                              final resultfromNewNote =
                                                  await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      NewNoteScreen(
                                                          UserID: 1,
                                                          noteIDedit:
                                                              foundedNote[index]
                                                                      .note_id
                                                                      ?.toInt() ??
                                                                  0,
                                                          isEditState: true),
                                                ),
                                              );
                                              ReloadNoteListAtLocal(
                                                  resultfromNewNote);
                                            },
                                            title: Text(
                                              foundedNote[index].title,
                                              style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                            // subtitle: Text(
                                            //   foundedNote[index].date_created,
                                            //   style: const TextStyle(
                                            //       fontSize: 11, color: Colors.grey),
                                            // ),
                                            trailing: const CircleAvatar(
                                              backgroundColor: Color.fromARGB(
                                                  255, 97, 115, 239),
                                              child: Icon(
                                                Icons.turned_in_not_outlined,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              minRadius: 10,
                                              maxRadius: 17,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Expanded(
                                          flex:
                                              listofTitleImage[index].path == ''
                                                  ? 0
                                                  : 3,
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              child: (listofTitleImage[index])
                                                          .path ==
                                                      ''
                                                  ? null
                                                  : Image.file(
                                                      listofTitleImage[index],
                                                      width: 140,
                                                      height: 60,
                                                      fit: BoxFit.cover,
                                                    )),
                                        ),
                                        Expanded(
                                          flex:
                                              listofTitleImage[index].path == ''
                                                  ? 4
                                                  : 1,
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                left: 10, top: 5, right: 10),
                                            alignment: Alignment.topLeft,
                                            child: Text(
                                              listofBriefContent[index],
                                              style:
                                                  const TextStyle(fontSize: 11),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: listofTitleImage[index]
                                                          .path ==
                                                      ''
                                                  ? 5
                                                  : 1,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                            flex: 1,
                                            child: Container(
                                              alignment: Alignment.centerRight,
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: Text(
                                                foundedNote[index].date_created,
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey),
                                              ),
                                            ))
                                      ],
                                    ));
                              },
                            ),
                    ),
                  ]),
                ),

                Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
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

  checkLogin() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          loginState = true;
        });
      } else {
        setState(() {
          loginState = false;
        });
      }
    });
  }
}
