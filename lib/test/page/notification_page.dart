// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:notemobileapp/test/services/firebase_firestore_service.dart';

import '../model/receive.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<Receive> listReceive = [];

  @override
  void initState() {
    // TODO: implement initState
    getAllReceive();
    super.initState();
  }

  Widget isNewNotification(String content,String time,int index) {
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
                listReceive[index].hadSeen = true;
                updateHasSeen(listReceive[index]);
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
                  child: Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                    child: Text(
                      content,
                      // style:
                      // FlutterFlowTheme.of(context).bodyLarge.override(
                      //   fontFamily: 'Plus Jakarta Sans',
                      //   color: Color(0xFF14181B),
                      //   fontSize: 16,
                      //   fontWeight: FontWeight.normal,
                      // ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                  child: Text(
                    time,
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

  Widget isOldNotification(String content,String time) {
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
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                  child: Text(
                    content,
                    // style: FlutterFlowTheme.of(context)
                    //     .labelLarge
                    //     .override(
                    //   fontFamily: 'Plus Jakarta Sans',
                    //   color: Color(0xFF57636C),
                    //   fontSize: 16,
                    //   fontWeight: FontWeight.normal,
                    // ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                child: Text(
                  time,
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông báo'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {

          return listReceive[index].hadSeen
              ? isOldNotification('${listReceive[index].owner}đã chia sẻ ghi chú với bạn', listReceive[index].timeStamp)
              : isNewNotification('${listReceive[index].owner} đã chia sẻ ghi chú với bạn', listReceive[index].timeStamp, index);
        },
        itemCount: listReceive.length,
      ),
    );
  }

  Future<void> getAllReceive() async {
    listReceive = await FireStorageService().getAllReceive();
    setState(() {
    });
  }

  Future<void> updateHasSeen(Receive receives)async {
    await FireStorageService().setTrueHasSeen(receives);
    setState(() {
    });
  }
}
