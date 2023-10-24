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
import 'package:provider/provider.dart';

import '../model/SqliteModel/NoteModel.dart';
import '../test/component/side_menu.dart';
import '../test/model/note_receive.dart';
import '../test/services/count_down_state.dart';
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

  // late List<dynamic> listofimglink_cloud = [];
  // late List<dynamic> listofBriefContent_cloud = [];

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
    checkLogin();
  }

  @override
  void dispose() {
    SetTrue().setCanReset(); //Set lại canResent để user mới vào bấm được,vì bộ delay chưa xong không thể set True.
    super.dispose();
  }

  Future<void> CheckInternetConnection() async {
    _networkConnectivity.initialise();
    _networkConnectivity.myStream.listen((source) {
      _source = source;
      // 1.
      switch (_source.keys.toList()[0]) {
        case ConnectivityResult.mobile:
          isConnected = _source.values.toList()[0] ? true : false;
          break;
        case ConnectivityResult.wifi:
          isConnected = _source.values.toList()[0] ? true : false;
          break;
        case ConnectivityResult.none:
        default:
          isConnected = false;
      }

      InitiateListOfNote();
    });
  }

  Future<void> InitiateListOfNote() async {
    email = FirebaseAuth.instance.currentUser?.email;

    if (loginState) {
      debugPrint("Co dang nhap ne!!");
      listofnote.clear();
      listofTitleImage.clear();
      foundedNote.clear();
      listofBriefContent.clear();

      refreshNoteListFromCloud();
    }
    else {
      debugPrint("Khong co dang nhap!");

      listofnote =
          await nDAL.getAllNotesByUserID(-1, InitDataBase.db).catchError(
        (Object e, StackTrace stackTrace) {
          debugPrint(e.toString());
        },
      );
      foundedNote = listofnote;
      listofTitleImage = await generateListTitleImage(listofnote);

      setState(() {});
    }
  }

  Future<void> reloadNoteListAtLocal(Object? result) async {
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
      if(loginState){
        noteList = await FireStorageService().getAllNote();
      }
      else{
        results = listofnote;
      }
    } else {
      if(loginState){
        noteList = noteList.where((note) => note.title.toLowerCase().contains(inputWord.toLowerCase())).toList();
      }
      else{
        results = listofnote
          .where((note) =>
              note.title.toLowerCase().contains(inputWord.toLowerCase()))
          .toList();
      }
      // we use the toLowerCase() method to make it case-insensitive
    }
    if(loginState){
      
    }
    else{
      foundedNote = results;
      listofTitleImage = await generateListTitleImage(foundedNote);
    }
    // Refresh the UI
    setState(() {});
  }

  Widget? displayImagefromCloudOrLocal_list(int index) {
    if (loginState) {
      Map? map = noteList[index].content.firstWhere((element) => element.containsKey("local_image"), orElse:  () => null);
      return map == null ? 
            null 
            : 
            Image.file(
              File(map["local_image"]),
              width: 290,
              height: 200,
              fit: BoxFit.cover,
            );
    }
    else{
      if(listofTitleImage[index].path == ""){
        return null;
      }
      return Image.file(
              listofTitleImage[index],
              width: 290,
              height: 200,
              fit: BoxFit.cover,
            );
    }

  }

  Widget? displayImagefromCloudOrLocal_grid(int index) {
    if (loginState) {
      Map? map = noteList[index].content.firstWhere((element) => element.containsKey("local_image"), orElse:  () => null);
      return map == null ? 
            null 
            : 
            Image.file(
              File(map["local_image"]),
              width: 140,
              height: 60,
              fit: BoxFit.cover,
            );
    }
    else{
      if(listofTitleImage[index].path == ""){
        return null;
      }
      return Image.file(
              listofTitleImage[index],
              width: 140,
              height: 60,
              fit: BoxFit.cover,
            );
    }
  }

  int settingimgflex(int index) {
    if (loginState) {
      Map? map = noteList[index].content.firstWhere((element) => element.containsKey("local_image"), orElse: () => null);
      return map == null ? 0 : 3;
    }
    return listofTitleImage[index].path == '' ? 0 : 3;
  }

  int settingBriefContentflex(int index) {
    if (loginState) {
      Map? map = noteList[index].content.firstWhere((element) => element.containsKey("local_image"), orElse: () => null);
      return map == null ? 4 : 1;
    }
    return listofTitleImage[index].path == '' ? 4 : 1;
  }

  int settingBriefContentMaxLines(int index) {
    if (loginState) {
      Map? map = noteList[index].content.firstWhere((element) => element.containsKey("local_image"), orElse: () => null);
      return map == null ? 5 : 1;
    }
    return listofTitleImage[index].path == '' ? 5 : 1;
  }

  ////ahihi

  Widget buildListView() {
    if (noteList.isNotEmpty || foundedNote.isNotEmpty) {
      return ListView.separated(
        separatorBuilder: (BuildContext context, int index) =>
            const Divider(height: 15),
        itemCount: loginState ? noteList.length : foundedNote.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 212, 253, 244),
                //color: Color.fromARGB(255, 255, 255, 255),
                //border: Border.all(width: 0.5, color: Colors.grey),
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(25, 10), // changes position of shadow
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
                      final resultFromNewNote = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewNoteScreen(
                            noteId: loginState
                                ? noteList[index].noteId
                                : (foundedNote[index]
                                        .note_id
                                        ?.toInt()
                                        .toString() ??
                                    0.toString()),
                            isEdit: true,
                            email: email == null ? "" : email?.toString(),
                          ),
                        ),
                      );
                      if (loginState) {
                        await refreshNoteListFromCloud();
                      } else {
                        await reloadNoteListAtLocal(resultFromNewNote);
                      }
                    },
                    leading: const CircleAvatar(
                      backgroundColor: Color.fromARGB(255, 97, 115, 239),
                      minRadius: 10,
                      maxRadius: 17,
                      child: Icon(
                        Icons.turned_in_not_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      loginState
                          ? noteList[index].title
                          : foundedNote[index].title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    subtitle: Text(
                      loginState
                          ? noteList[index].timeStamp
                          : foundedNote[index].date_created,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(3, 0, 3, 0),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: displayImagefromCloudOrLocal_list(index)),
                  ),
                  Container(
                    margin: const EdgeInsets.all(10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      loginState
                          ? noteList[index].content.firstWhere((element) => element.containsKey("text") && element["text"] != "")['text']
                          : listofBriefContent[index],
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  )
                ],
              ));
        },
      );
    }
    return const Center(
      child: Text(
          "Danh sách ghi chú trống hoặc do chưa kịp hiển thị danh sách, xin đợi chút hoặc kéo thả để tải lại danh sách!"),
    );
  }

  Widget buildGridView() {
    if (noteList.isNotEmpty || foundedNote.isNotEmpty) {
      return GridView.builder(
        itemCount: loginState ? noteList.length : foundedNote.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 4.0, mainAxisSpacing: 10.0),
        itemBuilder: (context, index) {
          return Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 212, 253, 244),
                //border: Border.all(width: 0.5, color: Colors.grey),
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: Offset(15, 10), // changes position of shadow
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: ListTile(
                      onTap: () async {
                        final resultfromNewNote = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewNoteScreen(
                                email: email == null ? "" : email?.toString(),
                                noteId: loginState
                                    ? noteList[index].noteId
                                    : (foundedNote[index]
                                            .note_id
                                            ?.toInt()
                                            .toString() ??
                                        0.toString()),
                                isEdit: true),
                          ),
                        );
                        if (loginState) {
                          await refreshNoteListFromCloud();
                        } else {
                          await reloadNoteListAtLocal(resultfromNewNote);
                        }
                      },
                      title: Text(
                        loginState
                            ? noteList[index].title
                            : foundedNote[index].title,
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      // subtitle: Text(
                      //   foundedNote[index].date_created,
                      //   style: const TextStyle(
                      //       fontSize: 11, color: Colors.grey),
                      // ),
                      trailing: const CircleAvatar(
                        backgroundColor: Color.fromARGB(255, 97, 115, 239),
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
                  SizedBox(
                    height: 10,
                  ),
                  noteList[index].content.firstWhere((element) => element.containsKey("local_image"), orElse: () => null) != null ? 
                  Expanded(
                    flex: settingimgflex(index),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: displayImagefromCloudOrLocal_grid(index)),
                  )

                  :

                  Text(""),

                  Expanded(
                    flex: settingBriefContentflex(index),
                    child: Container(
                      margin: EdgeInsets.only(left: 10, top: 5, right: 10),
                      alignment: Alignment.topLeft,
                      child: Text(
                        loginState
                            ? noteList[index].content.firstWhere((element) => element.containsKey("text") && element["text"] != "")["text"]
                            : listofBriefContent[index],
                        style: const TextStyle(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                        maxLines: settingBriefContentMaxLines(index),
                      ),
                    ),
                  ),
                  
                  Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 10),
                        child: Text(
                          loginState
                              ? noteList[index].timeStamp
                              : foundedNote[index].date_created,
                          style:
                              const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ))
                ],
              ));
        },
      );
    }
    return const Center(
      child: Text(
          "Danh sách ghi chú trống hoặc do chưa kịp hiển thị danh sách, xin đợi chút hoặc kéo thả để tải lại danh sách!"),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => CountdownState(),
      child: SafeArea(
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
              ],
            ),
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
                              ? RefreshIndicator(
                                  onRefresh: () async {
                                    if (loginState) {
                                      await refreshNoteListFromCloud();
                                    } else {
                                      await reloadNoteListAtLocal("RELOAD_LIST");
                                    }
                                  },
                                  child: buildListView())
                              : RefreshIndicator(
                                  onRefresh: () async {
                                    if (loginState) {
                                      refreshNoteListFromCloud();
                                    } else {
                                      reloadNoteListAtLocal("RELOAD_LIST");
                                    }
                                  },
                                  child: buildGridView()),
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
                            final resultFromNewNote = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NewNoteScreen(
                                  noteId: '',
                                  isEdit: false,
                                  email: email == null ? "" : email?.toString(),
                                ),
                              ),
                            );
                            if (loginState) {
                              await refreshNoteListFromCloud();
                            } else {
                              await reloadNoteListAtLocal(resultFromNewNote);
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
      ),
    );
  }

  checkLogin() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        loginState = true;
      } else {
        loginState = false;
        InitiateListOfNote();
      }
      
    });
  }

  Future<void> refreshNoteListFromCloud() async {
    // listofimglink_cloud.clear();
    // listofBriefContent_cloud.clear();
    noteList = await FireStorageService().getAllNote();
    setState(() {});
        // for (int i = 0; i < noteList.length; i++) {
        //   if(noteList[i].content.elementAtOrNull(1) != null){
        //     if(noteList[i].content[1].containsKey("image")){
        //       listofimglink_cloud.add(noteList[i].content[1]["image"].toString());
        //     }
        //     else{
        //       listofimglink_cloud.add("");
        //     }
        //   }
        //   else{
        //     listofimglink_cloud.add("");
        //   }
        //   listofBriefContent_cloud.add(noteList[i].content[0]["text"].toString());
        // }
  }

}
