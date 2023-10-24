import 'package:flutter/material.dart';

Widget textFieldWidget(TextEditingController controller, FocusNode fcnode){
  return TextField(
    keyboardType: TextInputType.multiline,

    controller: controller,
    focusNode: fcnode,

    maxLines: null,
    style: const TextStyle(fontSize: 14),
    decoration: const InputDecoration(border: InputBorder.none),
  );
}