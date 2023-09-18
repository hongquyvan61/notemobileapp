class ToDo {
  final int id;
  final String title;
  final String text;
  final String? imageUrl;

  ToDo(
      {required this.id, required this.text, required this.title, this.imageUrl});

  factory ToDo.fromSqfliteDatabase(Map<String, dynamic> map) =>
      ToDo(
        id: map['id']?.toInt() ?? 0, title: map['title'] ?? '', text: map['text'] ?? '');
}