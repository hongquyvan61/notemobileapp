class NoteModel {
  late int? note_id;
  late String title;
  late String date_created;
  late String email;
  late int? tag_id;

  NoteModel({
    this.note_id,
    required this.title,
    required this.date_created,
    required this.email,
    this.tag_id,
  });

  // Convert a NoteModel into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'note_id': note_id,
      'title': title,
      'date_created': date_created,
      'user_id': email,
      'tag_id': tag_id
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'NoteModel{note_id: $note_id, title: $title, date_created: $date_created, user_id: $email, tag_id: $tag_id}';
  }
}