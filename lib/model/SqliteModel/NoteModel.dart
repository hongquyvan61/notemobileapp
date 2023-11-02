class NoteModel {
  late int? note_id;
  late String title;
  late String date_created;
  late int user_id;
  late int? tag_id;
  late String? tag_name;

  NoteModel({
    this.note_id,
    required this.title,
    required this.date_created,
    required this.user_id,
    this.tag_id,
    this.tag_name,
  });

  // Convert a NoteModel into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'note_id': note_id,
      'title': title,
      'date_created': date_created,
      'user_id': user_id,
      'tag_id': tag_id,
      'tag_name': tag_name
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'NoteModel{note_id: $note_id, title: $title, date_created: $date_created, user_id: $user_id, tag_name: $tag_name}';
  }
}