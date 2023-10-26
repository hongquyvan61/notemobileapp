import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:notemobileapp/test/model/note_content.dart';
import 'package:notemobileapp/test/model/note_receive.dart';

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

  Future<void> saveTags(Tag tag) async{
    final idtag = notesCollection.doc(currentUser).collection("tag").doc();

    await idtag.set(tag.toMap());
  }
  

  Future<List<NoteReceive>> getAllNote() async {

    List<NoteReceive> notes = [];
    final noteCollection = notesCollection.doc(currentUser).collection("note").orderBy('timestamp', descending: true);
    await noteCollection.get().then((value) {
      for (var docSnapshot in value.docs) {
        notes.add(NoteReceive.withValue(
            docSnapshot.get('content'),
            docSnapshot.id,
            docSnapshot.get('timestamp'),
            docSnapshot.get('title'),
            docSnapshot.get('tagname')
        ));
      }
    });

    return notes;
  }

  Future<List<TagReceive>> getAllTags() async {

    List<TagReceive> tags = [];
    final tagCollection = notesCollection.doc(currentUser).collection("tag");
    TagReceive tagReceive = TagReceive();

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

  Future<NoteReceive> getNoteById(String id) async {

    final noteDocument = notesCollection.doc(currentUser).collection("note").doc(id);
    DocumentSnapshot doc = await noteDocument.get();
    NoteReceive note = NoteReceive();
    note.title = doc.get('title');
    note.timeStamp = doc.get('timestamp');
    note.content = doc.get('content');
    return note;

  }

  Future<void> deleteNoteById(String id) async {

    final noteDocument = notesCollection.doc(currentUser).collection("note").doc(id);
    await noteDocument.delete();

  }

  Future<void> updateNoteById(String id, NoteContent noteContent) async {

    final noteDocument = notesCollection.doc(currentUser).collection("note").doc(id);
    await noteDocument.update(noteContent.toMap());

  }

  Future<void> updateCloudImageURL(String id, List<dynamic> contents) async {
    final noteDocument = notesCollection.doc(currentUser).collection("note").doc(id);
    Map<Object, Object?> map = {"content" : contents};
    noteDocument.update(map);
  }

}


