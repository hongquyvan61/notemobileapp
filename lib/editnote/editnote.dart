import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';

class EditNoteScreen extends StatefulWidget{
  const EditNoteScreen({super.key});
  
  @override
  State<StatefulWidget> createState() {
    return EditNoteScreenState();
  }
  
}

class EditNoteScreenState extends State<EditNoteScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        
        floatingActionButton: AvatarGlow(
          duration: const Duration(milliseconds: 2000),
          glowColor: Colors.purple,
          animate: true, 
          repeat: true,
          child: CircleAvatar(
            backgroundColor: Colors.purple[300],
            radius: 35,
            child: const Icon(Icons.mic, color: Colors.white),
          ),
        ),
        
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(131, 0, 0, 0),
          elevation: 0.0,
          title: const Text('Sửa ghi chú'),
          centerTitle: true,
        ),

        body: Container(
          alignment: Alignment.center,
          child: const Text(
            'Nhan giu de viet ghi chu bang giong noi!',
            style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),) ,
        )

      ),
    );
  }

}