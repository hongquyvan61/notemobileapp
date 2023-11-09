// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  bool isSetStage = true;

  @override
  void initState() {
    // TODO: implement initState
    getAllReceive();
    super.initState();
  }

  String? currentUser = FirebaseAuth.instance.currentUser?.email;

  Widget isNewNotification(var document, int index) {
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
            style: TextButton.styleFrom(foregroundColor: Colors.black),
            onPressed: () {
              setState(() {
                // listReceive[index].hadSeen = true;
                // updateHasSeen(listReceive[index]);
              });
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
                    title: Text('${document.get('owner')} đã chia sẻ ghi chú'),
                    subtitle: listNote.length > index
                        ? Text(listNote[index].title)
                        : Text(''),
                    // style:
                    // FlutterFlowTheme.of(context).bodyLarge.override(
                    //   fontFamily: 'Plus Jakarta Sans',
                    //   color: Color(0xFF14181B),
                    //   fontSize: 16,
                    //   fontWeight: FontWeight.normal,
                    // ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                  child: Text(
                    document.get('timestamp'),
                    // style:
                    // FlutterFlowTheme.of(context).labelMedium.override(
                    //   fontFamily: 'Plus Jakarta Sans',
                    //   color: Color(0xFF57636C),
                    //   fontSize: 14,
                    //   fontWeight: FontWeight.normal,
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

  Widget isOldNotification(var document, int index) {
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
                  title: Text('${document['owner']} đã chia sẻ ghi chú'),
                  subtitle: listNote.length > index
                      ? Text(listNote[index].title)
                      : Text(''),
                  // style:
                  // FlutterFlowTheme.of(context).bodyLarge.override(
                  //   fontFamily: 'Plus Jakarta Sans',
                  //   color: Color(0xFF14181B),
                  //   fontSize: 16,
                  //   fontWeight: FontWeight.normal,
                  // ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                child: Text(
                  document['timestamp'],
                  // style:
                  // FlutterFlowTheme.of(context).labelMedium.override(
                  //   fontFamily: 'Plus Jakarta Sans',
                  //   color: Color(0xFF57636C),
                  //   fontSize: 14,
                  //   fontWeight: FontWeight.normal,
                  // ),
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
    final Stream _userStream = FirebaseFirestore.instance
        .collection('notes')
        .doc(currentUser)
        .collection('receive')
        .orderBy('hadseen', descending: false)
        .snapshots();
    return StreamBuilder(
        stream: _userStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }

          // snapshot.data?.docs.forEach((element) {
          //   test = element.get('rule');
          // });

          // return Scaffold(
          //   appBar: AppBar(title: Text('Chia sẻ ghi chú'), centerTitle: true,),
          //   body: Center(child: Text(test)),
          // );
          if (isSetStage == true) {
            getNote();
          }
          var documents = snapshot.data?.docs ?? [];
          return Scaffold(
            appBar: AppBar(
              title: Text('Thông báo'),
              centerTitle: true,
            ),
            body: ListView.builder(
              itemBuilder: (context, index) {
                var document = documents[index];
                var test = document['hadseen'];

                return test
                    ? isOldNotification(document, index)
                    : isNewNotification(document, index);
              },
              itemCount: documents.length,
            ),
          );
        });

    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text('Thông báo'),
    //     centerTitle: true,
    //   ),
    //   body: ListView.builder(
    //     itemBuilder: (context, index) {
    //       return listReceive[index].hadSeen
    //           ? isOldNotification(index)
    //           : isNewNotification(index);
    //     },
    //     itemCount: listReceive.length,
    //   ),
    // );
  }

  Future<void> getAllReceive() async {
    listReceive = await FireStorageService().getAllReceive();
    setState(() {
      isSetStage = true;
    });
  }

  Future<void> updateHasSeen(Receive receives) async {
    await FireStorageService().setTrueHasSeen(receives);
    setState(() {});
  }

  Future<void> getNote() async {
    listNote = await FireStorageService().getNoteByOwner(listReceive);
    setState(() {
      isSetStage = false;
    });
  }
}
