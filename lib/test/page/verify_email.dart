import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notemobileapp/DAL/NoteContentDAL.dart';
import 'package:notemobileapp/DAL/NoteDAL.dart';
import 'package:notemobileapp/DAL/TagDAL.dart';
import 'package:notemobileapp/home/home.dart';
import 'package:notemobileapp/model/SqliteModel/NoteContentModel.dart';
import 'package:notemobileapp/model/SqliteModel/initializeDB.dart';
import 'package:notemobileapp/test/component/toast.dart';
import 'package:notemobileapp/test/model/note_content.dart';

import '../../model/SqliteModel/NoteModel.dart';
import '../../router.dart';
import '../model/tag.dart';
import '../services/firebase_firestore_service.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool _isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  get canResend => null;

  NoteDAL noteDAL = NoteDAL();
  NoteContentDAL ncontentDAL = NoteContentDAL();
  TagDAL tagDAL = TagDAL();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!_isEmailVerified) {
      sendVerificationEmail();
      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify email"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Email xác minh đã được gửi !'),
            SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
                onPressed: () {
                  if (canResendEmail) {
                    sendVerificationEmail();
                  }
                },
                icon: const Icon(Icons.email),
                label: const Text('Gửi lại email xác thực')),
            TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed(RoutePaths.login);
              },
              child: Text('Huỷ'),
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(20)),
            )
          ],
        ),
      ),
    );
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
      setState(() => canResendEmail = false);
      await Future.delayed(Duration(seconds: 5));
      setState(() => canResendEmail = true);
    } catch (e) {
      print(e);
    }
  }

  checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();
    setState(() {
      _isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (_isEmailVerified) {
      uploadNoteToCloud();

      ToastComponent().showToast("Email của bạn đã được xác thực thành công !");
      Navigator.of(context).pushNamedAndRemoveUntil(RoutePaths.start, (Route<dynamic> route) => false);
      timer?.cancel();
    }
  }

  uploadNoteToCloud() async {
    ///UPLOAD DANH SACH TAG
      ///UPLOAD DANH SACH TAG
      ///UPLOAD DANH SACH TAG
      List<String> listtag = await tagDAL.getAllTagsByUserID(-1, InitDataBase.db);

      if(listtag.isNotEmpty){
        Tag tag = Tag();
        for(int i = 0; i < listtag.length; i++){
          tag.tagname = listtag[i];

          await FireStorageService().saveTags(tag);
        }
      }
      
      ///UPLOAD DANH SACH TAG
      ///UPLOAD DANH SACH TAG
      ///UPLOAD DANH SACH TAG

      ///UPLOAD DANH SACH NOTE VA NOTE CONTENTS
      ///UPLOAD DANH SACH NOTE VA NOTE CONTENTS
      ///UPLOAD DANH SACH NOTE VA NOTE CONTENTS
      List<NoteModel> NotesAtLocal = await noteDAL.getAllNotesByUserID(-1, InitDataBase.db);
      List<Map<String, dynamic>> contents = [];
      NoteContent note = NoteContent();

      if(NotesAtLocal.isNotEmpty){
        for(int i = 0 ; i < NotesAtLocal.length; i++){
          contents = await ncontentDAL.getAllNoteContentsById_Cloud(InitDataBase.db, NotesAtLocal[i].note_id?.toInt() ?? 0);
          note.content = contents;
          note.title = NotesAtLocal[i].title;
          note.timeStamp = NotesAtLocal[i].date_created;
          
          note.tagname = await tagDAL.getTagNameByID(NotesAtLocal[i].tag_id?.toInt() ?? 0, InitDataBase.db);
          
          await FireStorageService().saveContentNotes(note);
        }
      }

      ///UPLOAD DANH SACH NOTE VA NOTE CONTENTS
      ///UPLOAD DANH SACH NOTE VA NOTE CONTENTS
      ///UPLOAD DANH SACH NOTE VA NOTE CONTENTS
  }
}
