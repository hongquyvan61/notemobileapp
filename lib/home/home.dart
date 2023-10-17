import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:notemobileapp/DAL/FB_DAL.dart/FB_Note.dart';
import 'package:notemobileapp/DAL/FB_DAL.dart/FB_NoteContent.dart';
import 'package:notemobileapp/DAL/NoteContentDAL.dart';
import 'package:notemobileapp/DAL/NoteDAL.dart';
import 'package:notemobileapp/model/SqliteModel/FirebaseModel/FBNoteModel.dart';
import 'package:notemobileapp/model/SqliteModel/NoteContentModel.dart';
import 'package:notemobileapp/model/SqliteModel/initializeDB.dart';
import 'package:notemobileapp/newnote/newnote.dart';
import 'package:notemobileapp/router.dart';
import 'package:notemobileapp/test/component/popup_menu.dart';
import 'package:notemobileapp/test/services/firebase_firestore_service.dart';

import '../model/SqliteModel/NoteModel.dart';
import '../test/component/side_menu.dart';
import '../test/model/note_receive.dart';
import '../test/services/internet_connection.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {
  final _googleSignIn = GoogleSignIn();

  bool loginState = false;
  NoteDAL nDAL = NoteDAL();
  NoteContentDAL noteContentDAL = NoteContentDAL();

  // FB_Note fb_noteDAL = FB_Note();
  // FB_NoteContent fb_noteContentDAL = FB_NoteContent();
  late String? email;

  late List<NoteModel> listofnote = <NoteModel>[];
  late List<NoteModel> foundedNote = <NoteModel>[];

  //late List<FBNoteModel> fb_listofnote = <FBNoteModel>[];
  //late List<String> fb_listofimglink = <String>[];

  List<NoteReceive> noteList = [];

  late List<String> listofBriefContent = <String>[];
  late List<File> listofTitleImage = <File>[];

  late List<dynamic> listofimglink_cloud = [];
  late List<dynamic> listofBriefContent_cloud = [];

  //late List<String> fb_listofBriefContent = <String>[];
  bool isConnected = false;
  bool listState = true;
  late StreamSubscription subscription;

  Map _source = {ConnectivityResult.none: false};
  final NetworkConnectivity _networkConnectivity = NetworkConnectivity.instance;

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

    CheckInternetConnection();
    InitiateListOfNote();
    checkLogin();
  }

  @override
  void dispose() {
    _networkConnectivity.disposeStream();
    super.dispose();
  }

  void CheckInternetConnection(){
    _networkConnectivity.initialise();
    _networkConnectivity.myStream.listen((source) {
      _source = source;
      // 1.
      switch (_source.keys.toList()[0]) {
        case ConnectivityResult.mobile:
          isConnected = _source.values.toList()[0] ? true : false ;
          break;
        case ConnectivityResult.wifi:
          isConnected = _source.values.toList()[0] ? true : false ;
          break;
        case ConnectivityResult.none:
        default:
          isConnected = false;
      }

      setState(() {
        
      });
    });
  }


  InitiateListOfNote() async {
    

      if (isConnected) {
        
        debugPrint("Co mang ne!!");
        listofnote.clear();
        listofTitleImage.clear();
        foundedNote.clear();
        listofBriefContent.clear();

        email = FirebaseAuth.instance.currentUser!.email;
        refreshNoteListFromCloud();

        // fb_listofnote = await fb_noteDAL.FB_getAllNoteByUid(email);

        // fb_listofimglink = await FB_generateTitleImage(fb_listofnote);
      } else {
        debugPrint("Khong co mang!!!!");
        noteList.clear();
        listofimglink_cloud.clear();
        listofBriefContent_cloud.clear();

        listofnote = await nDAL.getAllNotesByUserID(-1, InitDataBase.db).catchError(
          (Object e, StackTrace stackTrace) {
            debugPrint(e.toString());
          },
        );
        foundedNote = listofnote;
        listofTitleImage = await generateListTitleImage(listofnote);
        email = "";
        setState(() {});
      }
  }

  void reloadNoteListAtLocal(Object? result) async {
    if (result.toString() == 'RELOAD_LIST') {
      await EasyLoading.show(
        status: "Đang load danh sách ghi chú...",
        maskType: EasyLoadingMaskType.none,
      );

      //SUA USERID O DAY
      //SUA USERID O DAY
      //SUA USERID O DAY
      listofnote =
          await nDAL.getAllNotesByUserID(-1, InitDataBase.db).catchError(
        (Object e, StackTrace stackTrace) {
          debugPrint(e.toString());
        },
      );

      foundedNote = listofnote;

      listofTitleImage = await generateListTitleImage(listofnote);

      ////REFRESH NOTE LIST FROM CLOUD
      ////REFRESH NOTE LIST FROM CLOUD
      ////REFRESH NOTE LIST FROM CLOUD
      // if (isConnected) {
      //   refreshNoteList();
      // }
      setState(() {});
      await EasyLoading.dismiss();
    } else {
      debugPrint('Du lieu tra ve tu new note screen bi loi');
    }
  }

  // Future<List<String>> FB_generateTitleImage(List<FBNoteModel> lst) async {
  //   late List<String> lstimage = <String>[];

  //   fb_listofBriefContent.clear();

  //   for (int i = 0; i < lst.length; i++) {
  //     int noteid = lst[i].note_id?.toInt() ?? -1;

  //     String imagestr = await fb_noteContentDAL.FB_getTitleImageOfNote(noteid);
  //     lstimage.add(imagestr);

  //     String briefcontent =
  //         await fb_noteContentDAL.FB_getBriefContentOfNote(noteid);
  //     fb_listofBriefContent.add(briefcontent);
  //   }
  //   return lstimage;
  // }

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

  Widget? displayImagefromCloudOrLocal_list(int index) {
    if (isConnected) {
      return Image.network(
              listofimglink_cloud[index],
              width: 290,
              height: 200,
              fit: BoxFit.cover,
            );
    }
    return (listofTitleImage[index]).path == ''
        ? null
        : Image.file(
            listofTitleImage[index],
            width: 290,
            height: 200,
            fit: BoxFit.cover,
          );
  }

  Widget? displayImagefromCloudOrLocal_grid(int index) {
    if (isConnected) {
      return Image.network(
              listofimglink_cloud[index],
              width: 140,
              height: 60,
              fit: BoxFit.cover,
            );
    }
    return (listofTitleImage[index]).path == ''
        ? null
        : Image.file(
            listofTitleImage[index],
            width: 140,
            height: 60,
            fit: BoxFit.cover,
          );
  }

  int settingimgflex(int index) {
    if (isConnected) {
      return listofimglink_cloud[index] == '' ? 0 : 3;
    }
    return listofTitleImage[index].path == '' ? 0 : 3;
  }

  int settingBriefContentflex(int index) {
    if (isConnected) {
      return listofBriefContent_cloud[index] == '' ? 4 : 1;
    }
    return listofTitleImage[index].path == '' ? 4 : 1;
  }

  int settingBriefContentMaxLines(int index) {
    if (isConnected) {
      return listofBriefContent_cloud[index] == '' ? 5 : 1;
    }
    return listofTitleImage[index].path == '' ? 5 : 1;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: const Color.fromARGB(63, 249, 253, 255),
          drawer: const NavBar(),

          appBar: AppBar(
            backgroundColor: const Color.fromARGB(0, 0, 0, 0),
            iconTheme: const IconThemeData(color: Colors.black),
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
              // PopupMenuButton(
              //     onSelected: (value) {
              //       if (value == "login") {
              //         Navigator.pushNamed(context, RoutePaths.login);
              //       }
              //       if (value == "logout") {
              //         _googleSignIn.signOut();
              //         FirebaseAuth.instance.signOut();
              //         setState(() {});
              //         Navigator.pushNamed(context, RoutePaths.login);
              //       }
              //     },
              //     shape: const RoundedRectangleBorder(
              //         borderRadius: BorderRadius.all(Radius.circular(6))),
              //     offset: const Offset(0, 50),
              //     icon: Icon(
              //       loginState ? Icons.manage_accounts : Icons.account_circle,
              //       color: Colors.black,
              //     ),
              //     itemBuilder: (context) => loginState
              //         ? PopUpMenu().accountPopupMenu(context)
              //         : PopUpMenu().loginPopupMenu(context))
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
                      SizedBox(
                        height: 13,
                      ),
                      Expanded(
                        child: listState == true
                            ? RefreshIndicator(
                                onRefresh: () async {
                                  if (isConnected) {
                                    refreshNoteListFromCloud();
                                  } else {
                                    reloadNoteListAtLocal("RELOAD_LIST");
                                  }
                                },
                                child: ListView.separated(
                                  separatorBuilder:
                                      (BuildContext context, int index) =>
                                          const Divider(height: 15),
                                  itemCount: isConnected
                                      ? noteList.length
                                      : foundedNote.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 0, 10, 0),
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                              255, 212, 253, 244),
                                          //color: Color.fromARGB(255, 255, 255, 255),
                                          //border: Border.all(width: 0.5, color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.2),
                                              spreadRadius: 5,
                                              blurRadius: 7,
                                              offset: Offset(25,
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
                                                final resultFromNewNote =
                                                    await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        NewNoteScreen(
                                                      noteId: isConnected
                                                          ? noteList[index].noteId
                                                          : (foundedNote[index].note_id?.toInt().toString() ?? 0.toString()),
                                                      isEdit: true,
                                                      email: isConnected ? email : "",
                                                    ),
                                                  ),
                                                );
                                                if(isConnected){

                                                }
                                                else{
                                                  reloadNoteListAtLocal(resultFromNewNote);
                                                }
                                              },
                                              leading: const CircleAvatar(
                                                backgroundColor: Color.fromARGB(
                                                    255, 97, 115, 239),
                                                minRadius: 10,
                                                maxRadius: 17,
                                                child: Icon(
                                                  Icons.turned_in_not_outlined,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                              ),
                                              title: Text(
                                                isConnected
                                                    ? "hihi" //noteList[index].title 
                                                    : foundedNote[index].title,
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                              subtitle: Text(
                                                isConnected
                                                    ? noteList[index].timeStamp
                                                    : foundedNote[index]
                                                        .date_created,
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
                                                      BorderRadius.circular(
                                                          8.0),
                                                  child:
                                                      displayImagefromCloudOrLocal_list(index)),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.all(10),
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                isConnected
                                                    ? noteList[index].content[0]
                                                        ['text']
                                                    : listofBriefContent[index],
                                                style: const TextStyle(
                                                    fontSize: 12),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            )
                                          ],
                                        ));
                                  },
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: () async {
                                  if (isConnected) {
                                    refreshNoteListFromCloud();
                                  } else {
                                    reloadNoteListAtLocal("RELOAD_LIST");
                                  }
                                },
                                child: GridView.builder(
                                  itemCount: isConnected
                                      ? noteList.length
                                      : foundedNote.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 4.0,
                                          mainAxisSpacing: 10.0),
                                  itemBuilder: (context, index) {
                                    return Container(
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                              255, 212, 253, 244),
                                          //border: Border.all(width: 0.5, color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.2),
                                              spreadRadius: 3,
                                              blurRadius: 7,
                                              offset: Offset(15,
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
                                                      builder: (context) => NewNoteScreen(
                                                          email: isConnected ? email : "",
                                                          noteId: isConnected
                                                              ? noteList[index]
                                                                  .noteId
                                                              : (foundedNote[
                                                                          index]
                                                                      .note_id
                                                                      ?.toInt()
                                                                      .toString() ??
                                                                  0.toString()),
                                                          isEdit: true),
                                                    ),
                                                  );
                                                  if(isConnected){

                                                  }
                                                  else{
                                                    reloadNoteListAtLocal(resultfromNewNote);
                                                  }
                                                  
                                                },
                                                title: Text(
                                                  isConnected
                                                      ? noteList[index].title
                                                      : foundedNote[index]
                                                          .title,
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                                // subtitle: Text(
                                                //   foundedNote[index].date_created,
                                                //   style: const TextStyle(
                                                //       fontSize: 11, color: Colors.grey),
                                                // ),
                                                trailing: const CircleAvatar(
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                          255, 97, 115, 239),
                                                  child: Icon(
                                                    Icons
                                                        .turned_in_not_outlined,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                  minRadius: 10,
                                                  maxRadius: 17,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Expanded(
                                              flex: settingimgflex(index),
                                              child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                  child:
                                                      displayImagefromCloudOrLocal_grid(index)),
                                            ),
                                            Expanded(
                                              flex: settingBriefContentflex(index),
                                              child: Container(
                                                margin: EdgeInsets.only(
                                                    left: 10,
                                                    top: 5,
                                                    right: 10),
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  isConnected ? listofBriefContent_cloud[index] : listofBriefContent[index],
                                                  style: const TextStyle(
                                                      fontSize: 11),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines:
                                                      settingBriefContentMaxLines(
                                                          index),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                                flex: 1,
                                                child: Container(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10),
                                                  child: Text(
                                                    isConnected ? noteList[index].timeStamp : foundedNote[index].date_created,
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
                      ),
                    ]),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.add,
                          size: 16.0,
                        ),
                        onPressed: () async {
                          final resultFromNewNote = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              // ignore: prefer_const_constructors
                              builder: (context) => NewNoteScreen(
                                noteId: '',
                                isEdit: false,
                                email: isConnected ? email : "",
                              ),
                            ),
                          );
                          if(isConnected){

                          }
                          else{
                            reloadNoteListAtLocal(resultFromNewNote);
                          }
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
                ])),
          )),
    );
  }

  checkLogin() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        loginState = true;
      } else {
        loginState = false;
      }
    });
  }

  Future<void> refreshNoteListFromCloud() async {
    
    noteList = await FireStorageService().getAllNote().whenComplete(() {
      for (int i = 0; i < noteList.length; i++) {
        listofBriefContent_cloud.add(noteList[i].content[0]["text"].toString());
        listofimglink_cloud.add(noteList[i].content[1]["image"].toString()); 
      }

      
    });

    setState(() {
      
    });
  }
}
