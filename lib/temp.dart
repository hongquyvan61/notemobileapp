import 'package:flutter/material.dart';

class TempScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
              backgroundColor: const Color.fromARGB(131, 0, 0, 0),
              elevation: 0.0,
              title: const Text('Sửa ghi chú'),
              centerTitle: true,
            ),
        body: Container()
      )
    );
  }
  
}