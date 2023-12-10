import 'dart:io';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:notemobileapp/router.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_database/firebase_database.dart';

import 'package:notemobileapp/test/component/toast.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:notemobileapp/DAL/UserDAL.dart';
import 'package:path_provider/path_provider.dart';

import '../../DAL/NoteContentDAL.dart';
import '../../DAL/NoteDAL.dart';
import '../../DAL/TagDAL.dart';
import '../../model/SqliteModel/NoteModel.dart';
import '../../model/SqliteModel/TagModel.dart';
import '../../model/SqliteModel/initializeDB.dart';
import '../model/note_content.dart';
import '../model/tag.dart';
import 'firebase_firestore_service.dart';

class Auth {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
  final UserDAL uDAL = UserDAL();

  NoteDAL noteDAL = NoteDAL();
  NoteContentDAL ncontentDAL = NoteContentDAL();
  TagDAL tagDAL = TagDAL();

  late bool isAnonymuos;

  DatabaseReference? userstable;

  Future<String> registerWithEmailPassword(
      context, String email, String password) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ToastComponent().showToast('Mật khẩu không an toàn. Thử lại');
        return e.code;

      } else if (e.code == 'email-already-in-use') {
        ToastComponent().showToast('Tài khoản này đã được đăng ký trước đó.');
        return e.code;
      }
    } catch (e) {
      ToastComponent().showToast(e.toString());
    }

    return "success";
  }

  Future signInWithEmailPassword(context, String email, String password) async {
    try {
      final _user = await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) async {
        if (FirebaseAuth.instance.currentUser!.emailVerified) {
          await uploadDataToCloudWithAccount(context);

          Navigator.of(context).pushNamedAndRemoveUntil(
              RoutePaths.start, (Route<dynamic> route) => false);
          ToastComponent().showToast('Đăng nhập thành công');
        } else {
          Navigator.of(context).pushReplacementNamed(RoutePaths.verifyEmail);
        }
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
        ToastComponent().showToast('Thông tin đăng nhập không hợp lệ');
      } else if (e.code == 'invalid-email') {
        ToastComponent().showToast('Email không đúng định dạng');
      }
    } catch (e) {
      print(e);
    }
  }

  signInWithGoogle(context) async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication aAuth = await gUser!.authentication;

    final credential = GoogleAuthProvider.credential(
        accessToken: aAuth.accessToken, idToken: aAuth.idToken);
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
  }

  changePassword() async {
    String? email = _auth.currentUser?.email;
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email!);

      ToastComponent().showToast("Email đã được gửi !");
    } on FirebaseAuthException catch (e) {
      ToastComponent().showToast("Có lỗi xảy ra, vui lòng thử lại");
    }

  }

  Future<bool> showAlertDialog(BuildContext context, String message, String alerttitle) async {
    // set up the buttons
    Widget cancelButton = OutlinedButton(
      child: Text('Không'),
      onPressed: () {
        // returnValue = false;
        Navigator.of(context).pop(false);
      },
    );
    Widget continueButton = OutlinedButton(
      child: Text("Có"),
      onPressed: () {
        // returnValue = true;
        Navigator.of(context).pop(true);
      },
    ); // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(alerttitle),
      content: Text(message),
      actions: [
        cancelButton,
        continueButton,
      ],
    ); // show the dialog
    final result = await showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
    return result ?? false;
  }

  Future<void> uploadNoteToCloud() async {
    ///UPLOAD DANH SACH TAG
      ///UPLOAD DANH SACH TAG
      ///UPLOAD DANH SACH TAG
      List<TagModel> listtag = await tagDAL.getAllTagsByUserID(-1, InitDataBase.db);

      if(listtag.isNotEmpty){
        Tag tag = Tag();
        for(int i = 0; i < listtag.length; i++){
          tag.tagname = listtag[i].tag_name;

          await FireStorageService().saveTags(tag);
        }
      }
      
      ///UPLOAD DANH SACH TAG
      ///UPLOAD DANH SACH TAG
      ///UPLOAD DANH SACH TAG

      ///UPLOAD DANH SACH NOTE VA NOTE CONTENTS
      ///UPLOAD DANH SACH NOTE VA NOTE CONTENTS
      ///UPLOAD DANH SACH NOTE VA NOTE CONTENTS
      List<NoteModel> NotesAtLocal = await noteDAL.getAllNotes(InitDataBase.db);
      List<Map<String, dynamic>> contents = [];
      NoteContent note = NoteContent();

      if(NotesAtLocal.isNotEmpty){
        for(int i = 0 ; i < NotesAtLocal.length; i++){
          contents = await ncontentDAL.getAllNoteContentsById_Cloud(InitDataBase.db, NotesAtLocal[i].note_id?.toInt() ?? 0);
          note.content = contents;
          note.title = NotesAtLocal[i].title;
          note.timeStamp = NotesAtLocal[i].convertDateCreate();
          
          note.tagname = await tagDAL.getTagNameByID(NotesAtLocal[i].tag_id?.toInt() ?? 0, InitDataBase.db);
          
          await FireStorageService().saveContentNotes(note).whenComplete((){

          });
        }
      }

      ///UPLOAD DANH SACH NOTE VA NOTE CONTENTS
      ///UPLOAD DANH SACH NOTE VA NOTE CONTENTS
      ///UPLOAD DANH SACH NOTE VA NOTE CONTENTS
  }

  Future<void> uploadDataToCloudWithAccount(context) async{
    List<NoteModel> lstnote = await noteDAL.getAllNotes(InitDataBase.db);
    if(lstnote.isNotEmpty){
      isAnonymuos = true;
    }
    else{
      isAnonymuos = false;
    }
    
    if(isAnonymuos){
      bool isSynchronize = await showAlertDialog(context, "Bạn có muốn đồng bộ dữ liệu của những ghi chú đã tạo trước đây vào tài khoản này không?", "Xác nhận đồng bộ");
      
      await EasyLoading.show(status: "Đang tải danh sách nhãn của bạn...",
                            maskType:EasyLoadingMaskType.black,
                            );

      if(isSynchronize){
        await uploadNoteToCloud().whenComplete(() {

        });
      }
      // else{
      //   Directory cachedr = await getTemporaryDirectory();
      //   cachedr.delete();
      // }

      await tagDAL.deleteAllTags(InitDataBase.db).whenComplete(() async {
        await ncontentDAL.deleteAllNoteContents(InitDataBase.db).whenComplete(() async {
            await noteDAL.deleteAllNote(InitDataBase.db).whenComplete(() async {
                
            });
        });
      });

      await EasyLoading.dismiss();

    }

    await tagDAL.deleteAllTags(InitDataBase.db);
  }
}
