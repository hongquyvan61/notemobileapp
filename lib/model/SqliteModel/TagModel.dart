class TagModel {
  late int? tag_id;
  late String tag_name;

  TagModel({
    this.tag_id,
    required this.tag_name,
  });

  // Convert a NoteModel into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'tag_id': tag_id,
      'tag_name': tag_name,
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'TagModel{tag_id: $tag_id, tag_name: $tag_name}';
  }
}