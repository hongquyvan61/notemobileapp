// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:notemobileapp/test/notifi_service.dart';
// import 'package:notemobileapp/test/services/firebase_firestore_service.dart';
//
// import 'date_time_picker.dart';
//
// class TestPage extends StatefulWidget {
//   const TestPage({super.key});
//
//   @override
//   State<TestPage> createState() => _TestPageState();
// }
//
// class _TestPageState extends State<TestPage> {
//   TextEditingController textEditingController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Test Page"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // const DatePickerTxt(),
//             // const ScheduleBtn(),
//             Padding(
//               padding: const EdgeInsets.only(top: 50),
//               child: ElevatedButton(
//                 child: const Text("Show Notification"),
//                 onPressed: () {
//                   NotificationService().showNotification(
//                       title: "Sample title", body: "it's work");
//                 },
//               ),
//             ),
//             ElevatedButton(
//                 onPressed: () {
//                   openDialog();
//                 },
//                 child: Text("Add Note")),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void openDialog() {
//     showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//               title: Text('New Note'),
//               content: TextField(
//                 decoration: InputDecoration(hintText: 'note'),
//                 controller: textEditingController,
//               ),
//               actions: [TextButton(onPressed: () {
//                 if(FirebaseAuth.instance.currentUser?.email != null) {
//                   // FireStoreService().addNote(textEditingController.text);
//                 }
//                 textEditingController.clear();
//                 Navigator.pop(context);
//               }, child: Text('Save'))],
//             ));
//   }
// }
