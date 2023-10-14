import 'package:flutter/material.dart';

Widget textFieldWidget(TextEditingController controller){
  return TextField(
    keyboardType: TextInputType.multiline,

    controller: controller,

    maxLines: null,
    style: const TextStyle(fontSize: 14),
    decoration: const InputDecoration(border: InputBorder.none),
  );
}