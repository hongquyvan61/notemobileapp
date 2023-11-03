// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:notemobileapp/test/model/invite.dart';
import 'package:notemobileapp/test/model/invite_receive.dart';
import 'package:notemobileapp/test/model/receive.dart';
import 'package:notemobileapp/test/services/firebase_firestore_service.dart';

class ShareNoteUser extends StatefulWidget {
  final String noteId;

  const ShareNoteUser({super.key, required this.noteId});

  @override
  State<ShareNoteUser> createState() => _ShareNoteUserState();
}

class _ShareNoteUserState extends State<ShareNoteUser> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  List<String> emails = [];
  Map<String, dynamic> emailsMap = {};
  bool updated = false;
  List<String> dropDownValue = [];
  TextEditingController _textEditingController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  List<Invite> invites = [];
  int indexOfOld = 0;
  List<int> indexOfLog = [];
  List<String> users = [];
  final List<String> items = [
    'Chỉ xem',
    'Chỉnh sửa',
  ];

  @override
  void initState() {
    if (emails.isEmpty || users.isEmpty) {
      getAllEmailInvite();
      getAllUser();
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Hỏi người dùng có chắc chắn muốn quay lại không
        if (updated) {
          bool confirm = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Xác nhận'),
                content: Text(
                    'Các thay đổi chưa được lưu, bạn chắc chắn muốn thoát ?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true); // Người dùng chấp nhận
                    },
                    child: Text('Có'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false); // Người dùng từ chối
                    },
                    child: Text('Không'),
                  ),
                ],
              );
            },
          );
          return confirm;
        } else {
          return true;
        }
      },
      child: GestureDetector(
        onTap: () {
          if (_focusNode.hasFocus) {
            _focusNode.unfocus(); // Ẩn bàn phím
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text('Chia sẻ'),
            actions: [
              IconButton(
                  onPressed: () {
                    if (updated) {
                      updateInviteToCloud();
                      updateInviteToUser();
                    }
                    setState(() {
                      updated = false;
                    });
                  },
                  icon: !updated ? Icon(Icons.check) : Icon(Icons.save))
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      getAllEmailInvite();
                      getAllUser();
                    },
                    child: ListView.separated(
                        itemCount: emails.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              emails[index],
                            ),
                            subtitle: Text(
                              'Subtitle goes here...',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                DropdownButton2<String>(
                                  hint: Text('Chọn quyền'),
                                  items: items
                                      .map((String item) =>
                                          DropdownMenuItem<String>(
                                            value: item,
                                            child: Text(
                                              item,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      dropDownValue[index] = value!;
                                      updated = true;
                                    });
                                    debugPrint(
                                        "$index  ${dropDownValue[index]}");
                                  },
                                  value: dropDownValue[index],
                                  dropdownStyleData: DropdownStyleData(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: Colors.red,
                                    ),
                                    offset: const Offset(-20, 0),
                                    scrollbarTheme: ScrollbarThemeData(
                                      radius: const Radius.circular(40),
                                      thickness:
                                          MaterialStateProperty.all<double>(6),
                                      thumbVisibility:
                                          MaterialStateProperty.all<bool>(true),
                                    ),
                                  ),
                                ),
                                IconButton(
                                    onPressed: () async {
                                      if (await confirmDelete()) {
                                        setState(() {
                                          emails.removeAt(index);
                                          dropDownValue.removeAt(index);
                                          updated = true;
                                        });
                                      }
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ))
                              ],
                            ),
                            dense: false,
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return Divider(
                            thickness: 1,
                            height: 40,
                          );
                        }),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textEditingController,
                        focusNode: _focusNode,
                        decoration:
                            InputDecoration(labelText: 'Enter your text'),
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          String textController = _textEditingController.text;
                          if (textController.isNotEmpty && await checkSelfEmail(textController) &&
                              isValidEmail(textController) &&
                              await checkDuplicate(
                                  textController) &&
                              await checkExistEmail(textController)) {
                            emailsMap.addAll({textController : ''});
                            addInviteTemp();
                            _textEditingController.clear();
                            setState(() {
                              updated = true;
                            });
                          }
                        },
                        child: Text(
                          'Mời',
                          style: TextStyle(fontSize: 20),
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> getAllEmailInvite() async {
    emails.clear();
    dropDownValue.clear();
    InviteReceive inviteReceive = InviteReceive();
    inviteReceive = await FireStorageService().getInviteById(widget.noteId);
    emailsMap = inviteReceive.rules;
    inviteReceive.rules.forEach((key, value) {
      emails.add(key);
      dropDownValue.add(value);
    });
    setState(() {
      indexOfOld = emails.length;
    });
  }

  Future<void> addInviteTemp() async {
    String key = _textEditingController.text;
    String rule = 'Chỉ xem';
    setState(() {
      emails.add(key);
      dropDownValue.add(rule);
    });
  }

  Future<void> updateInviteToCloud() async {
    Invite invite = Invite();
    for (int i = 0; i < emails.length; i++) {
      invite.rules.addAll({emails[i]: dropDownValue[i]});
    }
    invite.noteId = widget.noteId;
    await FireStorageService().updateInvite(invite);
  }

  Future<void> updateInviteToUser() async {
    Receive receive = Receive();
    for (int i = 0; i < emails.length; i++) {
      receive.rule = dropDownValue[i];
      receive.email = emails[i];
      receive.noteId = widget.noteId;
      await FireStorageService().addInviteToUser(receive);
    }
  }

  Future<bool> checkDuplicate(String key) async {
    bool check = true;
    if (emailsMap.containsKey(key)) {
      check = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Địa chỉ email này đã được mời !"),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text('OK'))
              ],
            );
          });
    }
    return check;
  }

  Future<bool> confirmDelete() async {
    bool check = true;

    check = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Bạn chắc chắn muốn xoá ?'),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text('Có')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text('Không')),
            ],
          );
        });

    return check;
  }

  Future<void> getAllUser() async {
    users = await FireStorageService().getAllEmailUser();
  }

  Future<bool> checkExistEmail(String email) async {
    for (int i = 0; i < users.length; i++) {
      if (email == users[i]) {
        return true;
      }
    }
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Người dùng Email này không có trong hệ thống'),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text("Ok"))
            ],
          );
        });
  }

  Future<bool> checkSelfEmail(String email) async {
    bool check = true;
    if(userEmail == email){
      check = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Bạn không thể tự mời chính mình, thử lại email khác'),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text("Ok"))
              ],
            );
          });
    }
    return check;
  }

  bool isValidEmail(String email) {
    RegExp regExp = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    if (!regExp.hasMatch(email)) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Email không đúng dịnh dạng, thử lại'),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Ok'))
              ],
            );
          });
    }
    return regExp.hasMatch(email);
  }
}
