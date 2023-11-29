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


Widget textFieldWidgetForEdit(TextEditingController controller, FocusNode fcnode, bool isEditCompleted, bool isEdit){
  return TextField(
    keyboardType: TextInputType.multiline,
    controller: controller,
    focusNode: fcnode,
    enabled: isEditCompleted == false  || isEdit == false ? true : false,
    maxLines: null,
    style: const TextStyle(fontSize: 14),
    decoration: const InputDecoration(border: InputBorder.none),
  );
}

Widget textFieldWidgetViewOnly(TextEditingController controller, FocusNode fcnode){
  return TextField(
    keyboardType: TextInputType.multiline,
    controller: controller,
    focusNode: fcnode,
    readOnly: true,
    maxLines: null,
    style: const TextStyle(fontSize: 14),
    decoration: const InputDecoration(border: InputBorder.none),
  );
}