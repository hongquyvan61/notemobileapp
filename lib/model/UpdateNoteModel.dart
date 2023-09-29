class UpdateNoteModel {
  late int? notecontent_id;
  late String type;

  UpdateNoteModel({
    required this.notecontent_id,
    required this.type,
  });

  // Convert a NoteModel into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'notecontent_id': notecontent_id,
      'type': type,
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'UpdateNoteModel{notecontent_id: $notecontent_id, textcontent: $type}';
  }
}