import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:notemobileapp/test/model/note_content.dart';
import 'package:notemobileapp/test/model/note_receive.dart';
import 'package:notemobileapp/test/model/receive.dart';

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

  Future<void> saveTags(Tag tag) async {
    final idtag = notesCollection.doc(currentUser).collection("tag").doc();

    await idtag.set(tag.toMap());
  }

  Future<List<NoteReceive>> getAllNote() async {
    List<NoteReceive> notes = [];
    final noteCollection = notesCollection
        .doc(currentUser)
        .collection("note")
        .orderBy('timestamp', descending: true);
    await noteCollection.get().then((value) {
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

  Future<List<TagReceive>> getTagsForFilter() async {

    List<TagReceive> tags = [];
    final tagCollection = notesCollection.doc(currentUser).collection("tag").limit(7);

    await tagCollection.get().then((value) {
      for (var docSnapshot in value.docs) {
        tags.add(TagReceive.withValue(
            docSnapshot.get("tag_name"),
            docSnapshot.id
        ));
      }
    });

    return tags;
  }

  Future<List<TagReceive>> getAllTagsForDialog() async {

    List<TagReceive> tags = [];
    final tagCollection = notesCollection.doc(currentUser).collection("tag");

    await tagCollection.get().then((value) {
      for (var docSnapshot in value.docs) {
        tags.add(TagReceive.withValue(
            docSnapshot.get("tag_name"),
            docSnapshot.id
        ));
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
        if(docSnapshot.get("tag_name") == tag_name){
          tags.add(TagReceive.withValue(
            docSnapshot.get("tag_name"),
            docSnapshot.id
          ));
        }
      }
    });

    return tags;
  }

  Future<NoteReceive> getNoteById(String id) async {
    final noteDocument =
        notesCollection.doc(currentUser).collection("note").doc(id);
    DocumentSnapshot doc = await noteDocument.get();
    NoteReceive note = NoteReceive();
    note.title = doc.get('title');
    note.timeStamp = doc.get('timestamp');
    note.content = doc.get('content');
    note.tagname = doc.get('tagname');
    return note;
  }

  Future<void> deleteNoteById(String id) async {
    final noteDocument =
        notesCollection.doc(currentUser).collection("note").doc(id);
    await noteDocument.delete();
  }

  Future<void> updateNoteById(String id, NoteContent noteContent) async {
    final noteDocument =
        notesCollection.doc(currentUser).collection("note").doc(id);
    await noteDocument.update(noteContent.toMap());
  }

  Future<void> updateCloudImageURL(String id, List<dynamic> contents) async {
    final noteDocument =
        notesCollection.doc(currentUser).collection("note").doc(id);
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

    if (doc.exists) {
      inviteReceive.rules = doc.get('rules');
    } else {
      saveInvite(id);
      final inviteDocument =
          notesCollection.doc(currentUser).collection('invite').doc(id);
      DocumentSnapshot doc = await inviteDocument.get();
      if(doc.data() != null){
        inviteReceive.rules = doc.get('rules');
      }
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

  Future<void> addInviteToUser(Receive receive) async {
    receive.owner = currentUser!;
    final idReceive = notesCollection
        .doc(receive.email)
        .collection("receive")
        .doc(receive.noteId);
    await idReceive.set(receive.toMap());
    debugPrint('Insert successful');
  }

  Future<List<String>> getAllEmailUser() async {
    List<String> users = [];
    final note = await notesCollection.get();
    note.docs.forEach((element) {
      users.add(element.id);
    });
    return users;
  }

  Future<void> insertCollection(User user) async {
    Map<String, dynamic> temp = {};
    await notesCollection.doc(user.email).set(temp);
  }


}
