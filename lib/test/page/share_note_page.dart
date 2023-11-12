// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notemobileapp/newnote/newnote.dart';
import 'package:notemobileapp/newnote/showShareNote.dart';
import 'package:notemobileapp/test/notifi_service.dart';
import 'package:notemobileapp/test/services/change_invite_state.dart';
import 'package:provider/provider.dart';

import '../model/note_receive.dart';
import '../model/receive.dart';
import '../services/firebase_firestore_service.dart';

class ShareNotePage extends StatefulWidget {
  const ShareNotePage({super.key, required this.navNotification});
  final bool navNotification;
  @override
  State<ShareNotePage> createState() => _ShareNotePageState();
}

class _ShareNotePageState extends State<ShareNotePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  List<Receive> listReceive = [];
  List<NoteReceive> listNote = [];
  String? currentUser = FirebaseAuth.instance.currentUser?.email;

  // bool isChange = false;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String test = '';
  bool isShare = true;

  @override
  void initState() {
    if(widget.navNotification){
      setState(() {
        isShare = false;
      });
    }
    // TODO: implement initState
    super.initState();
    getAllReceive();
  }

  Widget cardWidget(NoteReceive note) {
    String contentString = '';
    String urlImage = '';
    String rule = note.rule;
    Map<String, dynamic> content = {};

    for (var element in note.content) {
      content = element;
      if (content.containsKey('text')) {
        contentString += content['text'];
      } else if (content.containsKey('image')) {
        urlImage = content['image'];
      }
      if (urlImage != '') {
        break;
      }
    }


    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ShowShareNote(
                    noteId: note.noteId, isEdit: true, email: note.owner, rule: rule,)));
      },
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        color: Colors.yellow,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                note.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                child: Text(
                  contentString,
                  maxLines: 5,
                  style: TextStyle(fontFamily: 'Roboto', fontSize: 15),
                ),
              ),
              urlImage != ''
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        urlImage,
                        width: 300,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    )
                  : SizedBox(height: 0, width: 0,),
              Divider(thickness: 1,),
              Align(
                alignment: AlignmentDirectional(1.00, 0.00),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                  child: Text(
                    note.timeStamp,
                    style: TextStyle(fontFamily: 'Roboto',fontWeight: FontWeight.w500, fontSize: 10),
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(1.00, 0.00),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                  child: Text(
                    note.owner,
                    style: TextStyle(fontFamily: 'Roboto' ,fontWeight: FontWeight.w500, fontSize: 10),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget cardWidgetShare(NoteReceive note) {
    String contentString = '';
    String urlImage = '';
    Map<String, dynamic> content = {};
    String userShared = '';

    if (note.rules.isNotEmpty) {
      note.rules.forEach((key, value) {
        if (key != 'timestamp') {
          userShared += '$key\n';
        }
      });
    } else if (note.rules.isEmpty) {
      return SizedBox(
        width: 0.0,
        height: 0.0,
      );
    }

    for (var element in note.content) {
      content = element;
      if (content.containsKey('text')) {
        contentString += content['text'];
      } else if (content.containsKey('image')) {
        urlImage = content['image'];
      }
      if (urlImage != '') {
        break;
      }
    }
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NewNoteScreen(
                    noteId: note.noteId,
                    isEdit: true,
                    email: currentUser!.isNotEmpty ? currentUser : '')));
      },
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        color: Colors.yellow,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                note.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 18,
                    fontWeight: FontWeight.w500),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                child: Text(
                  contentString,
                  maxLines: 5,
                  style: TextStyle(fontFamily: 'Roboto', fontSize: 15),
                ),
              ),
              urlImage != ''
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        urlImage,
                        width: 300,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    )
                  : SizedBox(width: 0, height: 0,),
              Divider(thickness: 1,),
              Align(
                alignment: AlignmentDirectional(1.00, 0.00),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                  child: Text(
                    note.timeStamp,
                    style: TextStyle(fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 10),
                  ),
                ),
              ),
              Align(
                alignment: AlignmentDirectional(1.00, 0.00),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                  child: Text(
                    userShared,
                    style: TextStyle(fontFamily: 'Roboto',fontWeight: FontWeight.w500, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text(
            'Chia sẻ ghi chú',
            style: TextStyle(
                fontFamily: 'Roboto', color: Colors.white, fontSize: 22),
          ),
          actions: const [],
          centerTitle: true,
          elevation: 2,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(8, 0, 8, 0),
                      child: GestureDetector(
                        onTap: () => setState(() {
                          isShare = true;
                        }),
                        child: Container(
                          width: 150,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isShare ? Colors.grey : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: AlignmentDirectional(0.00, 0.00),
                          child: Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
                            child: Text(
                              'Đang chia sẻ',
                              style:
                                  TextStyle(fontFamily: 'Roboto', fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(8, 0, 8, 0),
                      child: GestureDetector(
                        onTap: () => setState(() {
                          isShare = false;
                        }),
                        child: Container(
                          width: 150,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isShare ? Colors.white : Colors.grey,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: AlignmentDirectional(0.00, 0.00),
                          child: Padding(
                            padding:
                                EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
                            child: Text(
                              'Được chia sẻ',
                              style:
                                  TextStyle(fontFamily: 'Roboto', fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey,
                endIndent: 20,
                indent: 20,
              ),
              isShare
                  ? FutureBuilder(
                      future: getNoteShare(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // Nếu đang tải dữ liệu, hiển thị màn hình xoay
                          return OrientationBuilder(
                            builder: (context, orientation) {
                              return Center(child: CircularProgressIndicator());
                            },
                          );
                        } else if (snapshot.hasError) {
                          // Nếu có lỗi, hiển thị thông báo lỗi
                          return Text('Đã xảy ra lỗi: ${snapshot.error}');
                        } else {
                          // Nếu dữ liệu đã tải xong, hiển thị nội dung
                          return Expanded(
                            child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                              child: RefreshIndicator(
                                onRefresh: () => refresh(),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {},
                                  child: MasonryGridView.count(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    itemCount: snapshot.data?.length,
                                    itemBuilder: (context, index) {
                                      return cardWidgetShare(
                                          snapshot.data![index]);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    )
                  : FutureBuilder(
                      future: getAllReceive(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // Nếu đang tải dữ liệu, hiển thị màn hình xoay
                          return OrientationBuilder(
                            builder: (context, orientation) {
                              return Center(child: CircularProgressIndicator());
                            },
                          );
                        } else if (snapshot.hasError) {
                          // Nếu có lỗi, hiển thị thông báo lỗi
                          return Text('Đã xảy ra lỗi: ${snapshot.error}');
                        } else {
                          // Nếu dữ liệu đã tải xong, hiển thị nội dung
                          return Expanded(
                            child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
                              child: RefreshIndicator(
                                onRefresh: () => refresh(),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () async {},
                                  child: MasonryGridView.count(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    itemCount: snapshot.data?.length,
                                    itemBuilder: (context, index) {
                                      return cardWidget(snapshot.data![index]);
                                    },
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<NoteReceive>> getAllReceive() async {
    listReceive = await FireStorageService().getAllReceive();
    await getNote();
    return listNote;
  }

  Future<void> getNote() async {
    listNote = await FireStorageService().getNoteByOwner(listReceive);
  }

  Future<List<NoteReceive>> getNoteShare() async {
    List<NoteReceive> idNote = [];
    idNote = await FireStorageService().getNoteShare();
    return idNote;
  }

  Future<void> refresh () async {
    setState(() {

    });
  }
}
