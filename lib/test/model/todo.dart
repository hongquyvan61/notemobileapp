

class ToDoModel {
  final String? id;
  final String title;
  final String text;

  const ToDoModel({this.id, required this.title, required this.text});

  toJson(){
    return {
      "Title": title,
      "Text": text,
    };
  }
}
