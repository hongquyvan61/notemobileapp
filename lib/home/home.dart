import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:notemobileapp/DAL/NoteContentDAL.dart';
import 'package:notemobileapp/DAL/NoteDAL.dart';
import 'package:notemobileapp/DAL/TagDAL.dart';
import 'package:notemobileapp/model/SqliteModel/initializeDB.dart';
import 'package:notemobileapp/newnote/newnote.dart';
import 'package:notemobileapp/router.dart';
import 'package:notemobileapp/test/services/firebase_dynamic_link.dart';
import 'package:notemobileapp/test/services/firebase_firestore_service.dart';
import 'package:notemobileapp/test/services/firebase_store_service.dart';
import 'package:path_provider/path_provider.dart';

//import 'package:notemobileapp/test/services/firebase_store_service.dart';
import 'package:provider/provider.dart';

import '../model/SqliteModel/NoteModel.dart';
import '../model/SqliteModel/TagModel.dart';
import '../test/component/side_menu.dart';
import '../test/model/note_receive.dart';
import '../test/model/tag_receive.dart';
import '../test/services/count_down_state.dart';
import '../test/services/firebase_message_service.dart';
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

  TagDAL tagDAL = TagDAL();

  // FB_Note fb_noteDAL = FB_Note();
  // FB_NoteContent fb_noteContentDAL = FB_NoteContent();
  late String? email;

  late List<NoteModel> listofnote = <NoteModel>[];
  late List<NoteModel> foundedNote = <NoteModel>[];

  //late List<FBNoteModel> fb_listofnote = <FBNoteModel>[];
  //late List<String> fb_listofimglink = <String>[];

  List<NoteReceive> noteList = [];
  List<TagReceive> lsttags = [];
  List<DropdownMenuEntry<TagReceive>> tagListEntries = [];

  List<TagModel> lsttagsLocal = [];
  List<DropdownMenuEntry<TagModel>> tagListEntriesLocal = [];

  TagModel? selectedtagLocal;
  TagReceive? selectedtag;

  TextEditingController filterTagController = TextEditingController();
  TextEditingController filterTagLocalController = TextEditingController();

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

    FireBaseMessageService().messageInnit(context);
    FireBaseMessageService().setupInteractMessage(context);
    FireBaseMessageService().requestNotificationPermission();
    FireBaseMessageService().getToken().then((value) => print(value));

    checkLogin();
    CheckInternetConnection();

    FirebaseDynamicLinkService().initDynamicLink(context);
  }

  @override
  void dispose() {
    SetTrue()
        .setCanReset(); //Set lại canResent để user mới vào bấm được,vì bộ delay chưa xong không thể set True.
    super.dispose();
  }

  Future<void> CheckInternetConnection() async {
    dynamic token;
    await FireBaseMessageService().getToken().then((value) async {
      token = value.toString();
    });


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

      if (loginState) {
        FireStorageService().addToken(token);
        InitiateListOfTag();
      } else {
        InitiateListOfTagAtLocal();
      }
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
    } else {
      debugPrint("Khong co dang nhap!");

      listofnote = await nDAL.getAllNotes(InitDataBase.db).catchError(
        (Object e, StackTrace stackTrace) {
          debugPrint(e.toString());
        },
      );
      foundedNote = listofnote;
      listofTitleImage = await generateListTitleImage(listofnote);

      if (mounted) {
        setState(() {});
      }
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
      listofnote = await nDAL.getAllNotes(InitDataBase.db).catchError(
        (Object e, StackTrace stackTrace) {
          debugPrint(e.toString());
        },
      );

      foundedNote = listofnote;

      listofTitleImage = await generateListTitleImage(listofnote);

      InitiateListOfTagAtLocal();

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
    noteList.clear();

    if (inputWord.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      if (loginState) {
        noteList = await FireStorageService().getAllNote();
      } else {
        results = listofnote;
      }
    } else {
      if (loginState) {
        noteList = await FireStorageService().getAllNote();

        noteList = noteList
            .where((note) =>
                note.title.toLowerCase().contains(inputWord.toLowerCase()))
            .toList();
      } else {
        results = listofnote
            .where((note) =>
                note.title.toLowerCase().contains(inputWord.toLowerCase()))
            .toList();
      }
      // we use the toLowerCase() method to make it case-insensitive
    }
    if (loginState) {
    } else {
      foundedNote = results;
      listofTitleImage = await generateListTitleImage(foundedNote);
    }
    // Refresh the UI
    setState(() {});
  }

  void filtertag(TagReceive? selected) async {
    if (selected!.tagid == "" || selected!.tagid == "all") {
      //CHUA TAO NHAN HOAC TAT CA

      noteList = await FireStorageService().getAllNote();

      setState(() {});
      return;
    }

    if (selected.tagid == "notag") {
      noteList.clear();
      noteList = await FireStorageService().getAllNote();

      noteList = noteList.where((note) => note.tagname == "").toList();

      setState(() {});
      return;
    }

    noteList.clear();
    noteList = await FireStorageService().getAllNote();

    noteList =
        noteList.where((note) => note.tagname == selected.tagname).toList();

    setState(() {});
  }

  void filtertagAtLocal(TagModel? selected) async {
    if (selected!.tag_id == -4 || selected!.tag_id == -3) {
      //CHUA TAO NHAN HOAC TAT CA

      foundedNote = await nDAL.getAllNotes(InitDataBase.db);

      listofTitleImage = await generateListTitleImage(foundedNote);
      setState(() {});
      return;
    }

    if (selected.tag_id == -2) {
      foundedNote.clear();

      foundedNote = await nDAL.getNotesWithoutTag(-1, InitDataBase.db);

      listofTitleImage = await generateListTitleImage(foundedNote);
      setState(() {});
      return;
    }

    foundedNote.clear();

    foundedNote =
        await nDAL.getNotesWithTagname(-1, selected.tag_name, InitDataBase.db);

    listofTitleImage = await generateListTitleImage(foundedNote);
    setState(() {});
    return;
  }

  Widget? displayImagefromCloudOrLocal_list(int index) {
    if (loginState) {
      Map? map = noteList[index].content.firstWhere(
          (element) => element.containsKey("local_image"),
          orElse: () => null);
      Map? mapImage = noteList[index].content.firstWhere(
          (element) => element.containsKey("image"),
          orElse: () => null);

      return map == null
          ? null
          : File(map["local_image"]).existsSync()
              ? Image.file(
                  File(map["local_image"]),
                  width: 290,
                  height: 200,
                  fit: BoxFit.cover,
                )
              : Image.network(
                  mapImage?['image'],
                  width: 290,
                  height: 200,
                  fit: BoxFit.cover,
                );
    } else {
      if (listofTitleImage.isEmpty || listofTitleImage[index].path == "") {
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
      Map? map = noteList[index].content.firstWhere(
          (element) => element.containsKey("local_image"),
          orElse: () => null);
      return map == null
          ? null
          : Image.file(
              File(map["local_image"]),
              width: 140,
              height: 60,
              fit: BoxFit.cover,
            );
    } else {
      if (listofTitleImage[index].path == "") {
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
      Map? map = noteList[index].content.firstWhere(
          (element) => element.containsKey("local_image"),
          orElse: () => null);
      return map == null ? 0 : 3;
    }
    return listofTitleImage[index].path == '' ? 0 : 3;
  }

  int settingBriefContentflex(int index) {
    if (loginState) {
      Map? map = noteList[index].content.firstWhere(
          (element) => element.containsKey("local_image"),
          orElse: () => null);
      return map == null ? 4 : 1;
    }
    return listofTitleImage[index].path == '' ? 4 : 1;
  }

  int settingBriefContentMaxLines(int index) {
    if (loginState) {
      Map? map = noteList[index].content.firstWhere(
          (element) => element.containsKey("local_image"),
          orElse: () => null);
      return map == null ? 5 : 1;
    }
    return listofTitleImage[index].path == '' ? 5 : 1;
  }

  Widget buildBriefContextTextWG(int index) {
    if (loginState) {
      return Text(
        noteList[index]
            .content
            .firstWhere((element) => element.containsKey("text"))['text'],
        style: const TextStyle(fontSize: 12),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      );
    } else {
      return Text(
        listofBriefContent.isNotEmpty ? listofBriefContent[index] : "",
        style: const TextStyle(fontSize: 12),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      );
    }
  }

  Widget buildNoteLeadingIcon(int index) {
    if (loginState) {
      if (noteList[index].tagname != "") {
        return const CircleAvatar(
          backgroundColor: Color.fromARGB(255, 97, 115, 239),
          minRadius: 10,
          maxRadius: 17,
          child: Icon(
            Icons.turned_in_not_outlined,
            color: Colors.white,
            size: 20,
          ),
        );
      } else {
        return const CircleAvatar(
          backgroundColor: Color.fromARGB(255, 251, 178, 37),
          minRadius: 10,
          maxRadius: 17,
          child: Icon(
            Icons.note_alt_outlined,
            color: Colors.white,
            size: 20,
          ),
        );
      }
    } else {
      if (foundedNote[index].tag_name != "") {
        return const CircleAvatar(
          backgroundColor: Color.fromARGB(255, 97, 115, 239),
          minRadius: 10,
          maxRadius: 17,
          child: Icon(
            Icons.turned_in_not_outlined,
            color: Colors.white,
            size: 20,
          ),
        );
      } else {
        return const CircleAvatar(
          backgroundColor: Color.fromARGB(255, 251, 178, 37),
          minRadius: 10,
          maxRadius: 17,
          child: Icon(
            Icons.note_alt_outlined,
            color: Colors.white,
            size: 20,
          ),
        );
      }
    }
  }

  Widget buildTagName(int index) {
    if (loginState) {
      if (noteList[index].tagname != "") {
        return Row(
          children: [
            const Icon(Icons.turned_in_outlined,
                size: 13, color: Color.fromARGB(255, 97, 115, 239)),
            const SizedBox(width: 5),
            Text(
              noteList[index].tagname,
              style: TextStyle(
                  fontSize: 12, color: Color.fromARGB(255, 97, 115, 239)),
            ),
          ],
        );
      } else {
        return const Text("");
      }
    } else {
      if (foundedNote[index].tag_name != "") {
        return Row(
          children: [
            const Icon(Icons.turned_in_outlined,
                size: 13, color: Color.fromARGB(255, 97, 115, 239)),
            const SizedBox(width: 5),
            Text(
              foundedNote[index].tag_name?.toString() ?? "",
              style: TextStyle(
                  fontSize: 12, color: Color.fromARGB(255, 97, 115, 239)),
            ),
          ],
        );
      } else {
        return const Text("");
      }
    }
  }

  Widget buildSpaceAboveNoteTitle_Grid(int index) {
    if (loginState) {
      if (noteList[index].tagname == "") {
        return const Expanded(flex: 0, child: SizedBox());
      } else {
        return const SizedBox();
      }
    } else {
      if (foundedNote[index].tag_name == "") {
        return const Expanded(flex: 0, child: SizedBox());
      } else {
        return const SizedBox();
      }
    }
  }

  Widget buildNoteTitle_Grid(int index) {
    if (loginState) {
      return Expanded(
        flex: noteList[index].tagname == "" ? 1 : 0,
        child: Container(
          alignment: Alignment.centerLeft,
          child: Text(
            noteList[index].title,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      );
    } else {
      return Expanded(
        flex: foundedNote[index].tag_name == "" ? 1 : 0,
        child: Container(
          alignment: Alignment.centerLeft,
          child: Text(
            foundedNote[index].title,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      );
    }
  }

  Widget buildTagName_Grid(int index) {
    if (loginState) {
      if (noteList[index].tagname != "") {
        return Container(
          child: Row(
            children: [
              const Icon(Icons.turned_in_outlined,
                  size: 13, color: Color.fromARGB(255, 97, 115, 239)),
              const SizedBox(width: 5),
              Expanded(
                flex: 1,
                child: Text(
                  noteList[index].tagname,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12, color: Color.fromARGB(255, 97, 115, 239)),
                ),
              ),
            ],
          ),
        );
      } else {
        return const SizedBox();
      }
    } else {
      if (foundedNote[index].tag_name != "") {
        return Container(
          child: Row(
            children: [
              const Icon(Icons.turned_in_outlined,
                  size: 13, color: Color.fromARGB(255, 97, 115, 239)),
              const SizedBox(width: 5),
              Text(
                foundedNote[index].tag_name?.toString() ?? "",
                style: TextStyle(
                    fontSize: 12, color: Color.fromARGB(255, 97, 115, 239)),
              ),
            ],
          ),
        );
      } else {
        return const SizedBox();
      }
    }
  }

  Widget buildTrailingIcon_Grid(int index) {
    if (loginState) {
      if (noteList[index].tagname != "") {
        return const CircleAvatar(
          backgroundColor: Color.fromARGB(255, 97, 115, 239),
          minRadius: 10,
          maxRadius: 17,
          child: Icon(
            Icons.turned_in_not_outlined,
            color: Colors.white,
            size: 20,
          ),
        );
      } else {
        return const CircleAvatar(
          backgroundColor: Color.fromARGB(255, 251, 178, 37),
          minRadius: 10,
          maxRadius: 17,
          child: Icon(
            Icons.note_alt_outlined,
            color: Colors.white,
            size: 20,
          ),
        );
      }
    } else {
      if (foundedNote[index].tag_name != "") {
        return const CircleAvatar(
          backgroundColor: Color.fromARGB(255, 97, 115, 239),
          minRadius: 10,
          maxRadius: 17,
          child: Icon(
            Icons.turned_in_not_outlined,
            color: Colors.white,
            size: 20,
          ),
        );
      } else {
        return const CircleAvatar(
          backgroundColor: Color.fromARGB(255, 251, 178, 37),
          minRadius: 10,
          maxRadius: 17,
          child: Icon(
            Icons.note_alt_outlined,
            color: Colors.white,
            size: 20,
          ),
        );
      }
    }
  }

  Widget buildExpandedImage_Grid(int index) {
    if (loginState) {
      return noteList[index].content.firstWhere(
                  (element) => element.containsKey("local_image"),
                  orElse: () => null) !=
              null
          ? Expanded(
              flex: settingimgflex(index),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: displayImagefromCloudOrLocal_grid(index)),
            )
          : Text("");
    } else {
      if (listofTitleImage[index].path != "") {
        return Expanded(
          flex: settingimgflex(index),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: displayImagefromCloudOrLocal_grid(index)),
        );
      } else {
        return const Text("");
      }
    }
  }

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
                    leading: buildNoteLeadingIcon(index),
                    title: Text(
                      loginState
                          ? noteList[index].title
                          : foundedNote[index].title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loginState
                              ? noteList[index].getTimeStamp()
                              : foundedNote[index].dateCreateToString(),
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        buildTagName(index)
                      ],
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
                      child: buildBriefContextTextWG(index))
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
                        title: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            buildSpaceAboveNoteTitle_Grid(index),
                            buildNoteTitle_Grid(index),
                            buildTagName_Grid(index)
                          ],
                        ),
                        // subtitle: Text(
                        //   foundedNote[index].date_created,
                        //   style: const TextStyle(
                        //       fontSize: 11, color: Colors.grey),
                        // ),
                        trailing: buildTrailingIcon_Grid(index)),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  buildExpandedImage_Grid(index),
                  Expanded(
                    flex: settingBriefContentflex(index),
                    child: Container(
                      margin: EdgeInsets.only(left: 10, top: 5, right: 10),
                      alignment: Alignment.topLeft,
                      child: Text(
                        loginState
                            ? noteList[index].content.firstWhere((element) =>
                                element.containsKey("text"))["text"]
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
                              ? noteList[index].getTimeStamp()
                              : foundedNote[index].date_created.toString(),
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
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextField(
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                                decoration: const InputDecoration(
                                    hintText: "Tìm kiếm nè...",
                                    prefixIcon: Icon(Icons.search),
                                    filled: true,
                                    fillColor:
                                        Color.fromARGB(255, 239, 241, 243),
                                    border: InputBorder.none
                                    // enabledBorder: OutlineInputBorder(
                                    //     borderSide: BorderSide(
                                    //   width: 0.5,
                                    // ))
                                  ),
                                onChanged: (value) => filterlist(value),
                              ),
                            ),

                            loginState
                                ? Expanded(
                                    flex: 0,
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton2<TagReceive>(
                                        hint: Text('Lọc theo nhãn'),
                                        items: lsttags
                                            .map((TagReceive item) =>
                                                DropdownMenuItem<TagReceive>(
                                                  value: item,
                                                  child: Text(
                                                    item.tagname,
                                                    style: const TextStyle(
                                                      fontFamily: 'Roboto',
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ))
                                            .toList(),
                                        onChanged: (value) {
                                          filtertag(value);
                                    
                                          selectedtag = value;
                                          setState(() {});
                                        },
                                        value: selectedtag,
                                      ),
                                    ))
                                : Expanded(
                                    flex: 0,
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton2<TagModel>(
                                        hint: Text('Lọc theo nhãn'),
                                        items: lsttagsLocal
                                            .map((TagModel item) =>
                                                DropdownMenuItem<TagModel>(
                                                  value: item,
                                                  child: Text(
                                                    item.tag_name,
                                                    style: const TextStyle(
                                                      fontFamily: 'Roboto',
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ))
                                            .toList(),
                                        onChanged: (value) {
                                          filtertagAtLocal(value);
                                    
                                          selectedtagLocal = value;
                                          setState(() {});
                                        },
                                        value: selectedtagLocal,
                                      ),
                                    ))
                            // loginState
                            //     ? Expanded(
                            //         flex: 1,
                            //         child: DropdownMenu<TagReceive>(
                            //           initialSelection:
                            //               lsttags.isEmpty ? null : lsttags[0],
                            //           controller: filterTagController,
                            //           label: const Text('Nhãn'),
                            //           dropdownMenuEntries: tagListEntries,
                            //           onSelected: (TagReceive? tag) {
                            //             filtertag(tag);
                            //           },
                            //         ),
                            //       )
                            //     : Expanded(
                            //         flex: 1,
                            //         child: DropdownMenu<TagModel>(
                            //           initialSelection: lsttagsLocal.isEmpty
                            //               ? null
                            //               : lsttagsLocal[0],
                            //           controller: filterTagLocalController,
                            //           label: const Text('Nhãn'),
                            //           dropdownMenuEntries: tagListEntriesLocal,
                            //           onSelected: (TagModel? tag) {
                            //             filtertagAtLocal(tag);
                            //           },
                            //         ),
                            //       )
                          ],
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
                                      await reloadNoteListAtLocal(
                                          "RELOAD_LIST");
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
    if (mounted) {
      setState(() {});
      if (loginState) {
        checkImageAtLocal();
      }
    }
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

  Future<void> InitiateListOfTag() async {
    lsttags = await FireStorageService().getTagsForFilter();
    //tagListEntries.clear();

    if (lsttags.isNotEmpty) {
      TagReceive tr = TagReceive();
      tr.tagname = "Không nhãn";
      tr.tagid = "notag";

      // tagListEntries.add(DropdownMenuEntry<TagReceive>(
      //   value: tr,
      //   label: "Không nhãn",
      // ));

      TagReceive trall = TagReceive();
      trall.tagname = "Tất cả";
      trall.tagid = "all";

      // tagListEntries.add(DropdownMenuEntry<TagReceive>(
      //   value: trall,
      //   label: "Tất cả",
      // ));

      lsttags.insert(0, tr);
      lsttags.insert(0, trall);

      // for (int i = 2; i < lsttags.length; i++) {
      //   tagListEntries.add(DropdownMenuEntry<TagReceive>(
      //       value: lsttags[i], label: lsttags[i].tagname));
      // }
    } else {
      TagReceive tr = TagReceive();
      tr.tagname = "*Chưa tạo nhãn*";
      tr.tagid = "";

      //tagListEntries.add(DropdownMenuEntry(value: tr, label: tr.tagname));

      lsttags.add(tr);
    }

    if (lsttags.isNotEmpty) {
      selectedtag = lsttags[0];
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> InitiateListOfTagAtLocal() async {
    lsttagsLocal = await tagDAL.getTagsForFilter_Local(-1, InitDataBase.db);
    //tagListEntriesLocal.clear();

    if (lsttagsLocal.isNotEmpty) {
      TagModel tr = TagModel(tag_id: -2, tag_name: "Không nhãn");

      // tagListEntriesLocal.add(DropdownMenuEntry<TagModel>(
      //   value: tr,
      //   label: "Không nhãn",
      // ));

      TagModel trall = TagModel(tag_id: -3, tag_name: "Tất cả");

      // tagListEntriesLocal.add(DropdownMenuEntry<TagModel>(
      //   value: trall,
      //   label: "Tất cả",
      // ));

      lsttagsLocal.insert(0, tr);
      lsttagsLocal.insert(0, trall);

      // for (int i = 2; i < lsttagsLocal.length; i++) {
      //   tagListEntriesLocal.add(DropdownMenuEntry<TagModel>(
      //       value: lsttagsLocal[i], label: lsttagsLocal[i].tag_name));
      // }
    } else {
      TagModel tr = TagModel(tag_id: -4, tag_name: "*Chưa tạo nhãn*");

      //tagListEntriesLocal.add(DropdownMenuEntry(value: tr, label: tr.tag_name));

      lsttagsLocal.add(tr);
    }

    if (lsttagsLocal.isNotEmpty) {
      selectedtagLocal = lsttagsLocal[0];
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> checkImageAtLocal() async {
    if (noteList.isNotEmpty) {
      for (int i = 0; i < noteList.length; i++) {
        for (int j = 0; j < noteList[i].content.length; j++) {
          if (noteList[i].content[j].containsKey("local_image") &&
              !File(noteList[i].content[j]["local_image"]).existsSync()) {
            await downloadImage(noteList[i].content[j]['image'],
                noteList[i].content[j]["local_image"]);
          }
        }
      }
    }
  }

  Future<void> downloadImage(String url, String localUrl) async {
    StorageService().downloadImage(url, localUrl);

  }
}
