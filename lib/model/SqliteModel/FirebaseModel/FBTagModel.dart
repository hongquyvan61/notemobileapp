class FBTagModel {
  late int? tag_id;
  late String? tag_name;
  late int? user_id;

  FBTagModel({
    this.tag_id,
    required this.tag_name,
    required this.user_id,
  });

  // Convert a NoteModel into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'tag_id': tag_id,
      'tag_name': tag_name,
      'user_id': user_id
    };
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'FBTagModel{tag_id: $tag_id, tag_name: $tag_name, user_id: $user_id}';
  }
}