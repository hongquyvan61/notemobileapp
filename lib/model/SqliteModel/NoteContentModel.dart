class NoteContentModel {
  late int? notecontent_id;
  late String? textcontent;
  late String? imagecontent;
  late int? note_id;

  NoteContentModel({
    required this.notecontent_id,
    required this.textcontent,
    required this.imagecontent,
    required this.note_id,
  });

  // Convert a NoteModel into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'notecontent_id': notecontent_id,
      'textcontent': textcontent,
      'imagecontent': imagecontent,
      'note_id': note_id,
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'NoteContentModel{notecontent_id: $notecontent_id, textcontent: $textcontent, imagecontent: $imagecontent, note_id: $note_id}';
  }
}