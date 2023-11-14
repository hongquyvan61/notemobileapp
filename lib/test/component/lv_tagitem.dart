class TagItem {
  late int? note_id;
  late String title;
  late String date_created;
  late int user_id;
  late int? tag_id;
  late String? tag_name;

  TagItem({
    this.note_id,
    required this.title,
    required this.date_created,
    required this.user_id,
    this.tag_id,
    this.tag_name,
  });
}