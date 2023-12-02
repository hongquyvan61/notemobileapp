//import 'dart:js_interop';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:notemobileapp/test/model/note_content.dart';
import 'package:notemobileapp/test/model/note_receive.dart';
import 'package:notemobileapp/test/model/receive.dart';
import 'package:notemobileapp/test/services/firebase_message_service.dart';

import '../model/invite.dart';
import '../model/invite_receive.dart';
import '../model/tag.dart';
import '../model/tag_receive.dart';

class FireStorageService {
  final CollectionReference notesCollection =
      FirebaseFirestore.instance.collection('notes');

  final FirebaseStorage storage = FirebaseStorage.instance;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String? currentUser = FirebaseAuth.instance.currentUser?.email;

  Future<String> saveContentNotes(NoteContent noteContent) async {
    final idNote = notesCollection.doc(currentUser).collection("note").doc();
    await idNote.set(noteContent.toMap());
    debugPrint('Insert count');
    return idNote.id;
  }

  Future<String> saveContentNotesForShare(
      NoteContent noteContent, String owner) async {
    final idNote = notesCollection.doc(owner).collection("note").doc();
    await idNote.set(noteContent.toMap());
    debugPrint('Insert count');
    return idNote.id;
  }

  Future<List<NoteReceive>> getAllNote() async {
    List<NoteReceive> notes = [];
    final noteCollection = await notesCollection
        .doc(currentUser)
        .collection("note")
        .orderBy('timestamp', descending: true)
        .get()
        .then((value) {
      for (var docSnapshot in value.docs) {
        notes.add(NoteReceive.withValue(
            docSnapshot.get('content'),
            docSnapshot.id,
            docSnapshot.get('timestamp'),
            docSnapshot.get('title'),
            docSnapshot.get('tagname')));
      }
    });

    return notes;
  }

  Future<List<TagReceive>> getAllTags() async {
    List<TagReceive> tags = [];
    final tagCollection = notesCollection.doc(currentUser).collection("tag");

    await tagCollection.get().then((value) {
      for (var docSnapshot in value.docs) {
        tags.add(
            TagReceive.withValue(docSnapshot.get("tag_name"), docSnapshot.id));
      }
    });

    return tags;
  }

  Future<List<TagReceive>> getAllTagsForShare(String owner) async {
    List<TagReceive> tags = [];
    final tagCollection = notesCollection.doc(owner).collection("tag");

    await tagCollection.get().then((value) {
      for (var docSnapshot in value.docs) {
        tags.add(
            TagReceive.withValue(docSnapshot.get("tag_name"), docSnapshot.id));
      }
    });

    return tags;
  }

  Future<List<TagReceive>> getTagsForFilter() async {
    List<TagReceive> tags = [];
    final tagCollection =
        notesCollection.doc(currentUser).collection("tag").limit(7);

    await tagCollection.get().then((value) {
      for (var docSnapshot in value.docs) {
        tags.add(
            TagReceive.withValue(docSnapshot.get("tag_name"), docSnapshot.id));
      }
    });

    return tags;
  }

  Future<List<TagReceive>> getAllTagsForDialog() async {
    List<TagReceive> tags = [];
    final tagCollection = notesCollection.doc(currentUser).collection("tag");

    await tagCollection.get().then((value) {
      for (var docSnapshot in value.docs) {
        tags.add(
            TagReceive.withValue(docSnapshot.get("tag_name"), docSnapshot.id));
      }
    });

    // TagReceive emptytag = TagReceive();
    // emptytag.tagname = "";
    // tags.add(emptytag);

    return tags;
  }

  Future<List<TagReceive>> searchTags(String tag_name) async {
    List<TagReceive> tags = [];
    final tagCollection = notesCollection.doc(currentUser).collection("tag");

    await tagCollection.get().then((value) {
      for (var docSnapshot in value.docs) {
        if (docSnapshot.get("tag_name") == tag_name) {
          tags.add(TagReceive.withValue(
              docSnapshot.get("tag_name"), docSnapshot.id));
        }
      }
    });

    return tags;
  }

  Future<void> updateTagById(String id, Tag t) async {
    final tagDocument =
        notesCollection.doc(currentUser).collection("tag").doc(id);

    DocumentSnapshot doc = await tagDocument.get();
    String oldname = doc.get('tag_name');

    await tagDocument.update(t.toMap());

    List<NoteReceive> notes = await getAllNote();
    for (int i = 0; i < notes.length; i++) {
      if (notes[i].tagname == oldname) {
        notesCollection
            .doc(currentUser)
            .collection('note')
            .doc(notes[i].noteId)
            .update({'tagname': t.tagname});
      }
    }
  }

  Future<void> saveTags(Tag tag) async {
    final idtag = notesCollection.doc(currentUser).collection("tag").doc();

    await idtag.set(tag.toMap());
  }

  Future<void> deleteTagById(String id) async {
    final tagDocument =
        notesCollection.doc(currentUser).collection("tag").doc(id);

    DocumentSnapshot doc = await tagDocument.get();
    String name = doc.get('tag_name');

    await tagDocument.delete();

    List<NoteReceive> notes = await getAllNote();
    for (int i = 0; i < notes.length; i++) {
      if (notes[i].tagname == name) {
        notesCollection
            .doc(currentUser)
            .collection('note')
            .doc(notes[i].noteId)
            .update({'tagname': ""});
      }
    }
  }

  Future<void> saveTagsForShare(Tag tag, String owner) async {
    final idtag = notesCollection.doc(owner).collection("tag").doc();

    await idtag.set(tag.toMap());
  }

  Future<NoteReceive> getNoteById(String id) async {
    final noteDocument =
        notesCollection.doc(currentUser).collection("note").doc(id);
    DocumentSnapshot doc = await noteDocument.get();
    NoteReceive note = NoteReceive();
    note.noteId = doc.id;
    note.title = doc.get('title');
    note.timeStamp = doc.get('timestamp');
    note.content = doc.get('content');
    note.tagname = doc.get('tagname');
    return note;
  }

  Future<NoteReceive> getNoteShareByIdForShare(String id, String owner) async {
    NoteReceive noteReceive = NoteReceive();
    DocumentSnapshot noteDocument =
        await notesCollection.doc(owner).collection("note").doc(id).get();

    noteReceive = NoteReceive.withValue(
        noteDocument.get('content'),
        noteDocument.id,
        noteDocument.get('timestamp'),
        noteDocument.get('title'),
        noteDocument.get('tagname'));
    return noteReceive;
  }

  Future<List<NoteReceive>> getListNoteByOwner(
      List<Receive> listReceive) async {
    List<NoteReceive> listNote = [];
    NoteReceive noteReceive = NoteReceive();
    for (var element in listReceive) {
      final noteDocument = notesCollection
          .doc(element.owner)
          .collection("note")
          .doc(element.noteId);
      DocumentSnapshot doc = await noteDocument.get();
      noteReceive = NoteReceive.withValue2(
          doc.get('content'),
          doc.id,
          doc.get('timestamp'),
          doc.get('title'),
          doc.get('tagname'),
          element.owner,
          element.rule);
      listNote.add(noteReceive);
    }

    return listNote;
  }

  Future<NoteReceive> getNoteByOwner(Receive receive) async {
    NoteReceive noteReceive = NoteReceive();

    final noteDocument = notesCollection
        .doc(receive.owner)
        .collection("note")
        .doc(receive.noteId);
    DocumentSnapshot doc = await noteDocument.get();
    noteReceive = NoteReceive.withValue2(
        doc.get('content'),
        doc.id,
        doc.get('timestamp'),
        doc.get('title'),
        doc.get('tagname'),
        receive.owner,
        receive.rule);

    return noteReceive;
  }

  Future<void> deleteNoteById(String id) async {
    String emailInvited = '';
    Receive receives = Receive();
    final noteDocument =
        notesCollection.doc(currentUser).collection("note").doc(id);

    //delete Receive ở từng user
    final inviteDocument =
        notesCollection.doc(currentUser).collection("invite");
    QuerySnapshot collectionSnapshot = await inviteDocument.get();

    //Kiểm tra xem invite có trống hay không (người dùng chưa bấm vào share)
    if (collectionSnapshot.docs.isNotEmpty) {
      DocumentSnapshot doc = await inviteDocument.doc(id).get();
      if (doc.exists) {
        Map<String, dynamic>? docData = doc.data() as Map<String, dynamic>?;
        Map<String, dynamic>? rulesData = {};
        if (docData!.isNotEmpty) {
          if (docData.containsKey('rules')) {
            rulesData = docData['rules'];
            rulesData?.forEach((key, value) async {
              if (key != 'timestamp') {
                receives.email = key;
                receives.noteId = id;
                await deleteReceive(receives);
              }
            });
          }
        }
      }
    }

    ///----------------------------

    await deleteInviteById(id);
    await noteDocument.delete();
  }

  Future<void> updateNoteById(String id, NoteContent noteContent) async {
    final noteDocument =
        notesCollection.doc(currentUser).collection("note").doc(id);
    await noteDocument.update(noteContent.toMap());
  }

  Future<void> updateNoteByIdForShare(
      String id, NoteContent noteContent, String owner) async {
    final noteDocument = notesCollection.doc(owner).collection("note").doc(id);
    await noteDocument.update(noteContent.toMap());
  }

  Future<void> updateCloudImageURL(String id, List<dynamic> contents) async {
    final noteDocument =
        notesCollection.doc(currentUser).collection("note").doc(id);
    Map<Object, Object?> map = {"content": contents};
    noteDocument.update(map);
  }

  Future<void> updateCloudImageURLForShare(
      String id, List<dynamic> contents, String owner) async {
    final noteDocument = notesCollection.doc(owner).collection("note").doc(id);
    Map<Object, Object?> map = {"content": contents};
    noteDocument.update(map);
  }

  // Future<List<InviteReceive>> getAllInvite() async {
  //   List<InviteReceive> inviteReceive = [];
  //   final inviteCollection = notesCollection.doc(currentUser).collection('invite');
  //   await inviteCollection.get().then((value) {
  //     for(var snapshot in value.docs){
  //       inviteReceive.add(InviteReceive.withValue(snapshot.get('id_note'), snapshot.get('rules'), snapshot.id));
  //     }
  //   });
  //   return inviteReceive;
  // }

  Future<InviteReceive> getInviteById(String id) async {
    InviteReceive inviteReceive = InviteReceive();
    final inviteDocument =
        notesCollection.doc(currentUser).collection('invite').doc(id);
    DocumentSnapshot doc = await inviteDocument.get();
    Map<String, dynamic>? docData = doc.data() as Map<String, dynamic>?;

    if (doc.exists && docData!.containsKey('rules')) {
      inviteReceive.rules = doc.get('rules');
    } else {
      saveInvite(id);
      // final inviteDocument =
      //     notesCollection.doc(currentUser).collection('invite').doc(id);
      // DocumentSnapshot doc = await inviteDocument.get();
      // if(doc.data() != null){
      //   inviteReceive.rules = doc.get('rules');
      // }
    }
    return inviteReceive;
  }

  Future<void> saveInvite(String noteId) async {
    final idInvite =
        notesCollection.doc(currentUser).collection("invite").doc(noteId);
    idInvite.set({});
    debugPrint('Insert successful');
  }

  Future<void> updateInvite(Invite invite) async {
    final idInvite = notesCollection
        .doc(currentUser)
        .collection("invite")
        .doc(invite.noteId);
    await idInvite.update(invite.toMap());
    debugPrint('Insert successful');
  }

  Future<void> deleteInviteById(String id) async {
    await notesCollection
        .doc(currentUser)
        .collection("invite")
        .doc(id)
        .delete();
  }

  Future<List<NoteReceive>> getNoteShare() async {
    List<NoteReceive> note = [];
    NoteReceive temp = NoteReceive();
    Map<String, dynamic> rules = {};
    Map<String, dynamic>? checkNull = {};
    QuerySnapshot inviteColection =
        await notesCollection.doc(currentUser).collection('invite').get();
    for (QueryDocumentSnapshot document in inviteColection.docs) {
      checkNull = document.data() as Map<String, dynamic>?;
      temp = await getNoteById(document.id);
      if (checkNull!.containsKey('rules')) {
        // check nếu như người dùng xoá hết email share và values chỉ còn timestamp
        rules = document.get('rules');
        temp.rules = rules;
      }
      note.add(temp);
    }
    return note;
  }

  Future<void> deleteReceive(Receive receives) async {
    final receive = notesCollection
        .doc(receives.email)
        .collection('receive')
        .doc(receives.noteId)
        .delete();
  }

  Future<void> addInviteToUser(Receive receive) async {
    String token = '';
    receive.owner = currentUser!;
    final idReceive = notesCollection
        .doc(receive.email)
        .collection("receive")
        .doc(receive.noteId);
    await idReceive.set(receive.toMap(), SetOptions(merge: true));

    token = await getToken(receive.email);
    await FireBaseMessageService()
        .messageFromServer(token, receive.noteId, receive.owner, receive.rule);
    debugPrint('Insert successful');
  }

  Future<void> setIsNewFalse(String idInvite) async {
    // final idReceive =
    //     notesCollection.doc(currentUser).collection("receive").doc(idInvite);
    // await idReceive.update({'isNew': false});
  }

  Future<List<String>> getAllEmailUser() async {
    List<String> users = [];
    final note = await notesCollection.get();
    note.docs.forEach((element) {
      users.add(element.id);
    });
    return users;
  }

  Future<List<Receive>> getAllReceive() async {
    List<Receive> listReceive = [];
    final idReceive = notesCollection
        .doc(currentUser)
        .collection("receive")
        .orderBy('hadseen', descending: false)
        .orderBy('timestamp', descending: true);

    await idReceive.get().then((value) {
      for (var element in value.docs) {
        listReceive.add(Receive.withValue1(
            element.get('owner'),
            element.get('rule'),
            element.id,
            element.get('timestamp'),
            element.get('hadseen')));
      }
    });

    return listReceive;
  }

  Future<void> setTrueHasSeen(Receive receives) async {
    final idReceive = await notesCollection
        .doc(currentUser)
        .collection("receive")
        .doc(receives.noteId)
        .update({'hadseen': true});
  }

  Future<void> insertCollection() async {
    Map<String, dynamic> temp = {};
    await notesCollection.doc(currentUser).set(temp);
  }

  Future<void> addToken(dynamic token) async {
    await notesCollection.doc(currentUser).set({'token': token});
  }

  Future<String> getToken(String user) async {
    String result = '';
    DocumentSnapshot documentSnapshot = await notesCollection.doc(user).get();
    if (documentSnapshot.exists) {
      // Dữ liệu tồn tại
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;
      result = data['token'];
    } else {
      // Dữ liệu không tồn tại
      print('Không tìm thấy dữ liệu');
    }

    return result;
  }

  Future<int> getNumberOfNotiHadNotSeen() async {
    int num = await notesCollection.doc(currentUser).collection('receive')
                                .where('hadseen',isEqualTo: false).count().get().then((res) => res.count);
    return num;
  }
}
