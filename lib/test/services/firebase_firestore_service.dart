import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:notemobileapp/test/model/note_content.dart';
import 'package:notemobileapp/test/model/note_receive.dart';

class FireStorageService {
  final CollectionReference notesCollection =
      FirebaseFirestore.instance.collection('notes');
  final FirebaseStorage storage = FirebaseStorage.instance;

  String? currentUser = FirebaseAuth.instance.currentUser?.email;

  Future<void> saveContentNotes(NoteContent noteContent) async {
    final idNote = notesCollection.doc(currentUser).collection("note").doc();

    // Tạo reference trong Firebase Storage

    // await idNote.set({
    //   'content': '',
    //   'note_id': idNote.id,
    //   'title': "abc",
    //   'timestamp': time,
    // });
    await idNote.set(noteContent.toMap());
    // await idNote.set({'content': notes}, SetOptions(merge: true));
  }

  Future<List<NoteReceive>> getAllNote() async {
    List<NoteReceive> notes = [];
    final noteCollection = notesCollection.doc(currentUser).collection("note");
    NoteReceive note = NoteReceive();

    await noteCollection.get().then((value) {
      for (var docSnapshot in value.docs) {
        notes.add(NoteReceive.withValue(
            docSnapshot.get('content'),
            docSnapshot.id,
            docSnapshot.get('timestamp'),
            docSnapshot.get('title')));
      }
    });

    return notes;
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

  void deleteNoteById(String id) async {

    final noteDocument = notesCollection.doc(currentUser).collection("note").doc(id);

    noteDocument.delete();
  }

  void updateNoteById(String id, NoteContent noteContent) async {

    final noteDocument = notesCollection.doc(currentUser).collection("note").doc(id);
    noteDocument.update(noteContent.toMap());

  }

}


