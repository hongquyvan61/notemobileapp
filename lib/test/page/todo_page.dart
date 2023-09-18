import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notemobileapp/test/database/todo_db.dart';
import 'package:notemobileapp/test/model/todo.dart';

class ToDoPage extends StatefulWidget {
  const ToDoPage({super.key});

  @override
  State<ToDoPage> createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  Future<List<ToDo>>? futureTodos;
  final todoDB = TodoDB();

  @override
  void initState() {
    super.initState();
    fetchTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo list view'),
      ),
      body: FutureBuilder<List<ToDo>>(
        future: futureTodos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            final todos = snapshot.data;
            return ListView.separated(
              itemBuilder: (context, index) {
                final todo = todos[index];
                return ListTile(
                  title: Text(todo.title),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(
                height: 12,
              ),
              itemCount: todos!.length,
            );
          }
        },
      ),
    );
  }

  void fetchTodos() {
    setState(() {
      futureTodos = todoDB.fetchAll();
    });
  }
}
