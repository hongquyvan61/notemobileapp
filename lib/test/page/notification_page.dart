// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notemobileapp/newnote/showShareNote.dart';
import 'package:notemobileapp/test/services/firebase_firestore_service.dart';

import '../model/note_receive.dart';
import '../model/receive.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Receive> listReceive = [];
  List<NoteReceive> listNote = [];
  NoteReceive noteReceive = NoteReceive();
  bool isSetStage = false;
  bool completeLoad = false;
  bool end = false;

  @override
  void initState() {
    // TODO: implement initState
    getAllReceive();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    end = true;
    super.dispose();
  }

  String? currentUser = FirebaseAuth.instance.currentUser?.email;

  Widget isNewNotification(var document, int index) {
    Receive receive = Receive();

    receive.rule = document.get('rule');
    receive.hadSeen = document.get('hadseen');
    receive.isNew = document.get('isNew');
    receive.owner = document.get('owner');
    receive.timeStamp = document.get('timestamp');
    receive.noteId = document.id;

    DateTime dateTime = document.get('timestamp').toDate();
    String day = dateTime.day.toString();
    String month = dateTime.month.toString();
    String year = dateTime.year.toString();
    String hour = dateTime.hour.toString().padLeft(2, '0');
    String minute = dateTime.minute.toString().padLeft(2, '0');


    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 1),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 0,
              color: Color(0xFFE0E3E7),
              offset: Offset(0, 1),
            )
          ],
          borderRadius: BorderRadius.circular(0),
          shape: BoxShape.rectangle,
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
          child: TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              // textStyle: TextStyle(
              //   fontFamily: 'Roboto',
              //   fontWeight: FontWeight.normal,
              //   color: Color(0xFF57636C),
              // )
            ),
            onPressed: () async {
              receive.hadSeen = true;

              await updateHasSeen(receive);

              final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ShowShareNote(
                          noteId: listNote[index].noteId,
                          isEdit: true,
                          email: listNote[index].owner,
                          rule: listNote[index].rule)));

              getAllReceive();
            },
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 4,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xFF4B39EF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(
                      '${document.get('owner')} đã chia sẻ ghi chú',
                      // style: TextStyle(
                      //   fontFamily: 'Roboto',
                      //   fontSize: 14,
                      //   fontWeight: FontWeight.w900,
                      //   color: Color(0xFF57636C),
                      // )
                    ),
                    subtitle: listNote.length > index
                        ? Text(
                            '\nTiêu đề: ${listNote[index].title}',
                            // style: TextStyle(
                            //   fontFamily: 'Roboto',
                            //   fontSize: 14,
                            //   fontWeight: FontWeight.normal,
                            //   color: Color(0xFF57636C),
                            // )
                          )
                        : Text(''),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                  child: Text(
                    '$day/$month/$year $hour:$minute',
                    // style: TextStyle(
                    //   fontFamily: 'Roboto',
                    //   fontSize: 12,
                    //   fontWeight: FontWeight.normal,
                    //   color: Color(0xFF57636C),
                    // )
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget isOldNotification(var document, int index) {

    DateTime dateTime = document.get('timestamp').toDate();
    String day = dateTime.day.toString();
    String month = dateTime.month.toString();
    String year = dateTime.year.toString();
    String hour = dateTime.hour.toString().padLeft(2, '0');
    String minute = dateTime.minute.toString().padLeft(2, '0');


    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 1),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xFFF1F4F8),
          boxShadow: [
            BoxShadow(
              blurRadius: 0,
              color: Color(0xFFE0E3E7),
              offset: Offset(0, 1),
            )
          ],
          borderRadius: BorderRadius.circular(0),
          shape: BoxShape.rectangle,
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
          child: TextButton(
            onPressed: () async {
              final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ShowShareNote(
                          noteId: listNote[index].noteId,
                          isEdit: true,
                          email: listNote[index].owner,
                          rule: listNote[index].rule)));

              getAllReceive();
            },
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: 4,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Color(0xFFE0E3E7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(
                      '${document['owner']} đã chia sẻ ghi chú',
                      // style: TextStyle(
                      //   fontFamily: 'Roboto',
                      //   fontSize: 14,
                      //   fontWeight: FontWeight.w900,
                      //   color: Color(0xFF57636C),
                      // )
                    ),
                    subtitle: listNote.length > index
                        ? Text(
                            '\nTiêu đề: ${listNote[index].title}',
                            // style: TextStyle(
                            //   fontFamily: 'Roboto',
                            //   fontSize: 14,
                            //   fontWeight: FontWeight.normal,
                            //   color: Color(0xFF57636C),
                            // )
                          )
                        : SizedBox(
                            height: 0,
                            width: 0,
                          ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                  child: Text(
                    '$day/$month/$year $hour:$minute',
                    // style: TextStyle(
                    //   fontFamily: 'Roboto',
                    //   fontSize: 12,
                    //   fontWeight: FontWeight.normal,
                    //   color: Color(0xFF57636C),
                    // ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Stream _userStream = FirebaseFirestore.instance
        .collection('notes')
        .doc(currentUser)
        .collection('receive')
        .orderBy('hadseen', descending: false).orderBy('timestamp', descending: true)
        .snapshots();
    return StreamBuilder(
        stream: _userStream,
        builder: (context, snapshot) {
          getAllReceive();

          if (isSetStage == true) {
            getListNote();
          }

          var documents = snapshot.data?.docs ?? [];

          return completeLoad
              ? Scaffold(
                  appBar: AppBar(
                    title: Text('Thông báo'),
                    centerTitle: true,
                  ),
                  body: listNote.isNotEmpty
                      ? ListView.builder(
                          itemBuilder: (context, index) {
                            var document = documents[index];
                            var test = document['hadseen'];

                            return test
                                ? isOldNotification(document, index)
                                : isNewNotification(document, index);
                          },
                          itemCount: documents.length,
                        )
                      : SizedBox(
                          width: 0,
                          height: 0,
                        ),
                )
              : Scaffold(
                  appBar: AppBar(
                    title: Text('Thông báo'),
                    centerTitle: true,
                  ),
                  body: Center(child: CircularProgressIndicator()),
                );
        });
  }

  Future<void> getAllReceive() async {
    listReceive = await FireStorageService().getAllReceive().whenComplete(() {
      if(!end) {
        setState(() {
          isSetStage = true;
        });
      }
    });
  }

  Future<void> updateHasSeen(Receive receives) async {
    await FireStorageService().setTrueHasSeen(receives);
    setState(() {});
  }

  Future<void> getListNote() async {
    listNote = await FireStorageService().getListNoteByOwner(listReceive);
    if (!end) {
      setState(() {
        isSetStage = false;
        completeLoad = true;
      });
    }
  }

  Future<NoteReceive> getNote(Receive receive) async {
    NoteReceive noteReceive = NoteReceive();
    noteReceive = await FireStorageService().getNoteByOwner(receive);
    return noteReceive;
  }
}
