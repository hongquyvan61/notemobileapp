import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:notemobileapp/DAL/FB_DAL/FB_Note.dart';
import 'package:notemobileapp/DAL/FB_DAL/FB_NoteContent.dart';
import 'package:notemobileapp/DAL/NoteContentDAL.dart';
import 'package:notemobileapp/DAL/NoteDAL.dart';
import 'package:notemobileapp/model/SqliteModel/FirebaseModel/FBNoteModel.dart';
import 'package:notemobileapp/model/SqliteModel/NoteContentModel.dart';
import 'package:notemobileapp/model/SqliteModel/initializeDB.dart';
import 'package:notemobileapp/newnote/newnote.dart';
import 'package:notemobileapp/router.dart';
import 'package:notemobileapp/test/component/popup_menu.dart';

import '../model/SqliteModel/NoteModel.dart';
import '../test/authservice/auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
     Key? key, required this.userID
  }) : super(key: key);

  final int userID;

  @override
  State<StatefulWidget> createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> {
  bool loginState = false;
  NoteDAL nDAL = NoteDAL();
  NoteContentDAL noteContentDAL = NoteContentDAL();
  FB_Note fb_noteDAL = FB_Note();
  FB_NoteContent fb_noteContentDAL = FB_NoteContent();

  late List<NoteModel> listofnote = <NoteModel>[];
  late List<NoteModel> foundedNote = <NoteModel>[];

  late List<FBNoteModel> fb_listofnote = <FBNoteModel>[];
  late List<FBNoteModel> fb_foundednote = <FBNoteModel>[];

  late List<String> fb_listofimglink = <String>[];

  late List<String> listofBriefContent = <String>[];
  late List<File> listofTitleImage = <File>[];

  late List<String> fb_listofBriefContent = <String>[];
  bool isConnected = false;
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

    //AssignSubscription();
    FirebaseDatabase.instance.ref("note").keepSynced(true);
    FirebaseDatabase.instance.ref("notecontent").keepSynced(true);
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
    // if (result != ConnectivityResult.none) {
    //   isOffline = await InternetConnectionChecker().hasConnection;
    // }
  }

  InitiateListOfNote() async {

      final connectedRef = FirebaseDatabase.instance.ref(".info/connected");
        connectedRef.onValue.listen((event) async {
          isConnected = event.snapshot.value as bool? ?? false;
          
          if(isConnected){
            if(widget.userID != -1){
              //debugPrint("Co mang ne!!");
              showToast("Đã có kết nối Internet trở lại");
              listofnote.clear();
              foundedNote.clear();
              listofTitleImage.clear();

              await EasyLoading.show(
                  status: "Đang load danh sách ghi chú...",
                  maskType: EasyLoadingMaskType.none,
              );

              fb_listofnote = await fb_noteDAL.FB_getAllNoteByUid(widget.userID);

              fb_foundednote = fb_listofnote;

              fb_listofimglink = await FB_generateTitleImage(fb_listofnote);

              setState(() {
                
              });

              await EasyLoading.dismiss();
            }
            else{
              showToast("Hiện đang không dùng tài khoản đăng nhập nào!");

              await EasyLoading.show(
                  status: "Đang load danh sách ghi chú...",
                  maskType: EasyLoadingMaskType.none,
              );

              listofnote = await nDAL.getAllNotesByUserID(widget.userID, InitDataBase.db).catchError((Object e, StackTrace stackTrace) {
                                                                                          debugPrint(e.toString());
                                                                                        },
                                                                                      );
              foundedNote = listofnote;
              listofTitleImage = await generateListTitleImage(listofnote);
              setState(() {
                      
              });

              await EasyLoading.dismiss();
            }
            
          }
          else{
            //debugPrint("Dang khong co mang!");
            showToast("Hiện không có kết nối mạng, hãy kết nối mạng nếu cần để đồng bộ dữ liệu ở cục bộ máy");

            await EasyLoading.show(
                status: "Đang load danh sách ghi chú...",
                maskType: EasyLoadingMaskType.none,
            );

            listofnote = await nDAL.getAllNotesByUserID(widget.userID, InitDataBase.db).catchError((Object e, StackTrace stackTrace) {
                                                                                        debugPrint(e.toString());
                                                                                      },
                                                                                    );
            foundedNote = listofnote;
            listofTitleImage = await generateListTitleImage(listofnote);
            setState(() {
                    
            });

            await EasyLoading.dismiss();
          }
      });

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
      if(isConnected){
        listofnote.clear();
        listofTitleImage.clear();

        fb_listofnote = await fb_noteDAL.FB_getAllNoteByUid(widget.userID);

        fb_foundednote = fb_listofnote;

        fb_listofimglink = await FB_generateTitleImage(fb_listofnote);

        setState(() {
              
        });
      }
      else{
        listofnote = await nDAL.getAllNotesByUserID(widget.userID, InitDataBase.db).catchError(
          (Object e, StackTrace stackTrace) {
            debugPrint(e.toString());
          },
        );

        foundedNote = listofnote;

        listofTitleImage = await generateListTitleImage(listofnote);
        setState((){
          
        });
      }
      await EasyLoading.dismiss();
    } else {
      debugPrint('Du lieu tra ve tu new note screen bi loi');
    }
  }

  Future<List<String>> FB_generateTitleImage(List<FBNoteModel> lst) async{
    late List<String> lstimage = <String>[];
    
    fb_listofBriefContent.clear();

    for (int i = 0; i < lst.length; i++) {
      int noteid = lst[i].note_id?.toInt() ?? -1;

      String imagestr = await fb_noteContentDAL.FB_getTitleImageOfNote(noteid);
      lstimage.add(imagestr);

      String briefcontent = await fb_noteContentDAL.FB_getBriefContentOfNote(noteid);
      fb_listofBriefContent.add(briefcontent);
    }
    return lstimage;
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
    List<FBNoteModel> fb_results = [];

    if (inputWord.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      if(isConnected){
        fb_results = fb_listofnote;
      }
      else{
        results = listofnote;
      }
    } else {
      if(isConnected){
        fb_results = fb_listofnote
                    .where(
                      (fbnote) => fbnote.title.toLowerCase().contains(inputWord.toLowerCase())
                    ).toList();
      }
      else{
        results = listofnote
          .where((note) =>
              note.title.toLowerCase().contains(inputWord.toLowerCase()))
          .toList();
      }
      // we use the toLowerCase() method to make it case-insensitive
    }

    if(isConnected){
      fb_foundednote = fb_results;
      fb_listofimglink = await FB_generateTitleImage(fb_foundednote);
    }
    else{
      foundedNote = results;
      listofTitleImage = await generateListTitleImage(foundedNote);
    }
    // Refresh the UI
    setState(() {

    });
  }

  Widget? displayImagefromFBOrLocal_list(int index){
    if(isConnected){
      return (fb_listofimglink[index]) == '' ? null : Image.network(fb_listofimglink[index], width: 290, height: 200, fit: BoxFit.cover,);
    }
    return (listofTitleImage[index]).path == '' ? null : Image.file(listofTitleImage[index], width: 290, height: 200, fit: BoxFit.cover,);
  }

  Widget? displayImagefromFBOrLocal_grid(int index){
    if(isConnected){
      return (fb_listofimglink[index]) == '' ? null : Image.network(fb_listofimglink[index], width: 140, height: 60, fit: BoxFit.cover,);
    }
    return (listofTitleImage[index]).path == '' ? null : Image.file(listofTitleImage[index], width: 140, height: 60, fit: BoxFit.cover,);  
  }

  int settingimgflex(int index){
    if(isConnected){
      return fb_listofimglink[index] == '' ? 0 : 3;
    }
    return listofTitleImage[index].path == '' ? 0 : 3;
  }

  int settingBriefContentflex(int index){
    if(isConnected){
      return fb_listofimglink[index] == '' ? 4 : 1;
    }
    return listofTitleImage[index].path == '' ? 4 : 1;
  }

  int settingBriefContentMaxLines(int index){
    if(isConnected){
      return fb_listofimglink[index] == '' ? 5 : 1;
    }
    return listofTitleImage[index].path == '' ? 5 : 1;
  }

  String FB_generateBriefContent_list(int index){
    try{
      if(isConnected){
        return fb_listofBriefContent[index];
      }
      return listofBriefContent[index];
    }
    on Exception catch (e){
      debugPrint(e.toString());
    }
    return "";
  }

  String FB_generateBriefContent_grid(int index){
    try{
      if(isConnected){
        return fb_listofBriefContent[index];
      }
      return listofBriefContent[index];
    }
    on Exception catch (e){
      debugPrint(e.toString());
    }
    return "";
  }

  void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
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
                              )
                            )
                          ),
                          onChanged: (value) => filterlist(value),
                        ),
                        SizedBox(height: 13,),
                        Expanded(
                          child: listState == true ? 
                               ListView.separated(
                                separatorBuilder: (BuildContext context, int index) => const Divider(height: 15),
                                itemCount: isConnected ? fb_foundednote.length : foundedNote.length,
                                
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
                                            onTap: () async{
                                              final resultfromNewNote = await Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) => NewNoteScreen(
                                                                              UserID: widget.userID, 
                                                                              noteIDedit: isConnected ? (fb_foundednote[index].note_id?.toInt() ?? 0) : (foundedNote[index].note_id?.toInt() ?? 0), 
                                                                              isEditState: true
                                                                            ),
                                                                          ),
                                                                      );
                                              ReloadNoteListAtLocal(resultfromNewNote);
                                            },
                                            leading: const CircleAvatar(

                                                backgroundColor:
                                                    Color.fromARGB(255, 97, 115, 239),
                                                child: Icon(
                                                  Icons.turned_in_not_outlined,
                                                  color: Colors.white,
                                                  size: 20,
                                                ),
                                                minRadius: 10,
                                                maxRadius: 17,
                                            ),
                                            title: Text(
                                                isConnected ? fb_foundednote[index].title : foundedNote[index].title,
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                            ),
                                            subtitle: Text(
                                                isConnected ? fb_foundednote[index].date_created : foundedNote[index].date_created,
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
                                              child: displayImagefromFBOrLocal_list(index)
                                          ),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.all(10),
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            FB_generateBriefContent_list(index),
                                            style:
                                                const TextStyle(fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        )
                                      ],
                                    ));
                              },
                              
                            )

                            :

                            GridView.builder(
                              itemCount: isConnected ? fb_foundednote.length : foundedNote.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 4.0,
                                mainAxisSpacing: 10.0
                              ),
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
                                              onTap: () async{
                                                final resultfromNewNote = await Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                              builder: (context) => NewNoteScreen(
                                                                                UserID: widget.userID, 
                                                                                noteIDedit: isConnected ? (fb_foundednote[index].note_id?.toInt() ?? 0) : (foundedNote[index].note_id?.toInt() ?? 0), 
                                                                                isEditState: true
                                                                              ),
                                                                            ),
                                                                        );
                                                ReloadNoteListAtLocal(resultfromNewNote);
                                              },
                                              title: Text(
                                                isConnected ? fb_foundednote[index].title : foundedNote[index].title,
                                                style: TextStyle(
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
                                                
                                                backgroundColor:
                                                    Color.fromARGB(255, 97, 115, 239),
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
                                          SizedBox(height: 10,),
                                          Expanded(
                                            flex: settingimgflex(index),
                                            child: ClipRRect(
                                              
                                                borderRadius: BorderRadius.circular(8.0),
                                                child: displayImagefromFBOrLocal_grid(index)
                                            ),
                                          ),
                                          Expanded(
                                            flex: settingBriefContentflex(index),
                                            child: Container(
                                              margin: EdgeInsets.only(left: 10, top: 5, right: 10),
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                  FB_generateBriefContent_grid(index),
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
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: Text(
                                                isConnected ? fb_foundednote[index].date_created : foundedNote[index].date_created,
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
                    margin: EdgeInsets.only(bottom: 10.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.add,
                          size: 16.0,
                        ),
                        onPressed: () async {
                          final resultfromNewNote = await Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) => NewNoteScreen(
                                                                              UserID: widget.userID, 
                                                                              noteIDedit: -1, 
                                                                              isEditState: false
                                                                            ),
                                                                          ),
                                                                      );
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
                ]
              )
                
                
            ),
          )

          
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
