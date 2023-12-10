// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:intl/intl.dart';
import 'package:notemobileapp/router.dart';

import 'package:notemobileapp/test/model/invite.dart';
import 'package:notemobileapp/test/model/invite_receive.dart';
import 'package:notemobileapp/test/model/receive.dart';
import 'package:notemobileapp/test/services/firebase_dynamic_link.dart';
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
  List<String> emails = []; //Chứa email invite để lấy ra hiển thị
  Map<String, dynamic> emailsMap = {}; //check trùng email đã mời

  List<String> lsttimestamp = []; //CHỨA THỜI GIAN CẬP NHẬT CÁC QUYỀN
  
  bool updated = false;
  List<String> dropDownValue = [];
  List<String> dropDownValueCheckUpdate = [];
  TextEditingController _textEditingController = TextEditingController();

  TextEditingController sharewithMailController = TextEditingController();

  TextEditingController ErrorTextController = TextEditingController();

  TextEditingController mailBodyController = TextEditingController();

  FocusNode _focusNode = FocusNode();
  List<Invite> invites = [];

  List<String> users = [];
  List<String> deleteListTemp = [];
  List<Map<String, dynamic>> addList = [];
  final List<String> items = [
    'Chỉ xem',
    'Chỉnh sửa',
  ];
  bool isDelete = false;
  bool isInvalidMail = false;
  

  @override
  void initState() {
    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.chasingDots
      ..loadingStyle = EasyLoadingStyle.dark;

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

  Widget buildListView() {
    if (emails.isNotEmpty) {
      return ListView.separated(
          itemCount: emails.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                emails[index],
              ),
              subtitle: Text(
                lsttimestamp[index],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DropdownButton2<String>(
                    hint: Text('Chọn quyền'),
                    items: items
                        .map((String item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontFamily: 'Roboto',
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
                        setAddList(index, value);
                        if (!checkUpdate()) {
                          updated = true;
                        } else {
                          updated = false;
                        }
                      });
                      debugPrint("$index  ${dropDownValue[index]}");
                    },
                    value: dropDownValue[index],
                    // dropdownStyleData: DropdownStyleData(
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.circular(14),
                    //     color: Colors.red,
                    //   ),
                    //   offset: const Offset(-20, 0),
                    //   scrollbarTheme: ScrollbarThemeData(
                    //     radius: const Radius.circular(40),
                    //     thickness: MaterialStateProperty.all<double>(6),
                    //     thumbVisibility: MaterialStateProperty.all<bool>(true),
                    //   ),
                    // ),
                  ),
                  IconButton(
                      onPressed: () async {
                        if (await confirmDelete()) {
                          setState(() {
                            emailsMap.remove(emails[index]);
                            deleteListTemp.add(emails[index]);

                            dropDownValue.removeAt(index);
                            lsttimestamp.removeAt(index);
                            dropDownValueCheckUpdate.removeAt(index);
                            for (int i = 0; i < addList.length; i++) {
                              if (addList[i].containsKey(emails[index])) {
                                addList.removeAt(i);
                              }
                            }
                            emails.removeAt(index);
                            isDelete = true;
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
          });
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Image(
            image: AssetImage('images/facts.png'),
            width: 140,
            height: 140,
            fit: BoxFit.cover,
            
          ),
          const SizedBox(height: 20,),
          Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: const Text("Danh sách lời mời trống hoặc do chưa kịp hiển thị danh sách, xin đợi chút hoặc kéo thả để tải lại danh sách!")
          ),
        ],
      );
    }
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
            backgroundColor: const Color.fromARGB(131, 0, 0, 0),
            title: Center(child: Text('Chia sẻ')),
            actions: [
              IconButton(
                  onPressed: () {
                    if (updated) {
                      updateInviteToCloud();
                      updateInviteToUserFilter();
                      if (isDelete) {
                        deleteReceive();
                      }
                    }
                    if(updated == false){
                      Navigator.of(context).pop();
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
            child: Stack(children: [
              Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                        onRefresh: () async {
                          addList = [];
                          lsttimestamp = [];
                          getAllEmailInvite();
                          getAllUser();
                        },
                        child: buildListView()),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textEditingController,
                          focusNode: _focusNode,
                          decoration: InputDecoration(
                              labelText: 'Nhập email người muốn mời'),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          String textController = _textEditingController.text;
                          if (textController.isNotEmpty &&
                              await checkSelfEmail(textController) &&
                              isValidEmail(textController) &&
                              await checkDuplicate(textController) &&
                              await checkExistEmail(textController)) {
                            emailsMap.addAll({textController: ''});
                            addInviteTemp();
                            _textEditingController.clear();
                            setState(() {
                              updated = true;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            shape: const StadiumBorder(),
                            backgroundColor:
                                const Color.fromARGB(255, 97, 115, 239)),
                        child: Text(
                          'Chia sẻ',
                          style: TextStyle(fontFamily: 'Roboto',fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              )
               ,
               Container(
                 margin: const EdgeInsets.only(bottom: 50.0),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: ElevatedButton.icon(
                          icon: const Icon(
                            Icons.mail,
                            size: 16.0,
                          ),
                          onPressed: (){
                            showDialog(
                              barrierDismissible: false,
                              context: context, 
                              builder: (context) {
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return Dialog(
                                      child: Container(
                                        margin: EdgeInsets.all(10),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Center(
                                                  child: Text("Chia sẻ qua mail", style: TextStyle(fontFamily: 'Roboto', fontSize: 18),),
                                            ),

                                            const SizedBox(height: 15,),

                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Expanded(
                                                  child: ListTile(
                                                    title: Container(
                                                      child: TextField(
                                                        controller: sharewithMailController,
                                                        style: const TextStyle(
                                                          fontFamily: 'Roboto',
                                                          fontSize: 13,
                                                        ),
                                                        decoration: const InputDecoration(
                                                            hintText: "Nhập email của người muốn chia sẻ...",
                                                        ),
                                                        onTap: () {
                                                          isInvalidMail = false;
                                                          ErrorTextController.text = "";
                                                          setState(() {
                                                              
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                
                                                    trailing: ElevatedButton(
                                                        onPressed: () async {
                                                          RegExp regExp = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
                                                          if (!regExp.hasMatch(sharewithMailController.text)) {
                                                            isInvalidMail = true;
                                                            ErrorTextController.text = "Email không đúng dịnh dạng, thử lại";
                                                          }
                                                          if(mailBodyController.text.isEmpty){
                                                            isInvalidMail = true;
                                                            String emptymailerror = "";
                                                            if(ErrorTextController.text.isNotEmpty){
                                                               emptymailerror = "\n" + "Nội dung mail đang bị bỏ trống!";
                                                            }
                                                            else{
                                                              emptymailerror = "Nội dung mail đang bị bỏ trống!";
                                                            }
                                                            
                                                            ErrorTextController.text += emptymailerror;
                                                          }
                                                          if(isInvalidMail){
                                                            setState(() {
                                                              
                                                            });
                                                          }

                                                          if(isInvalidMail == false){
                                                            String dynamiclink = await FirebaseDynamicLinkService().createDynamicLink(true, RoutePaths.newnote, widget.noteId);

                                                            sendEmail(dynamiclink);

                                                            Navigator.of(context).pop();
                                                          }
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                            shape: const StadiumBorder(),
                                                            backgroundColor:
                                                                const Color.fromARGB(255, 97, 115, 239)
                                                        ),
                                                        child: Text(
                                                          'Chia sẻ',
                                                          style: TextStyle(fontFamily: 'Roboto', fontSize: 15),
                                                        ),
                                                      
                                                    ),
                                                  ),
                                                )
                                                
                                              ]
                                            ),

                                            const SizedBox(height: 10,),

                                            isInvalidMail ? 
                                            TextField(
                                              enabled: false,
                                              controller: ErrorTextController,
                                              style: const TextStyle(
                                                fontFamily: 'Roboto',
                                                fontSize: 13,
                                                color: Colors.red
                                              ),
                                              decoration: const InputDecoration(
                                                border: InputBorder.none
                                              )
                                            )
                                            :
                                            const Text(""),

                                            TextField(
                                              controller: mailBodyController,
                                              keyboardType: TextInputType.multiline,
                                              maxLines: null,
                                              showCursor: true,
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                              decoration: const InputDecoration(
                                                hintText: "Nhập nội dung mail ở đây...",
                                                hintStyle: TextStyle(
                                                  fontStyle: FontStyle.italic
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(
                                                      width: 0.5,
                                                ))
                                              ),
                                              onTap: () {
                                                isInvalidMail = false;
                                                ErrorTextController.text = "";
                                                setState(() {
                                                              
                                                });
                                              },
                                            ),

                                            const SizedBox(height: 10,),

                                            Expanded(
                                                  flex: 0,
                                                  child: Container(
                                                    width: 300,
                                                    child: ElevatedButton(
                                                      onPressed: (){
                                                        isInvalidMail = false;
                                                        ErrorTextController.text = "";
                                                        sharewithMailController.text = "";
                                                        Navigator.of(context).pop();
                                                      }, 
                                                      style: ElevatedButton.styleFrom(
                                                        shape: const StadiumBorder(),
                                                        backgroundColor: Color.fromARGB(255, 97, 115, 239),
                                                        side: const BorderSide(
                                                          width: 1.0,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                      child: Text("THOÁT", style: TextStyle(
                                                        fontFamily: 'Roboto',
                                                      ))
                                                    ),
                                                  ),
                                            )
                                          ],
                                        ),
                                      ),
                                      
                                  );
                                }
                              );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder(),
                              backgroundColor:
                                  const Color.fromARGB(255, 97, 115, 239)),
                          label: const Text(
                            'Chia sẻ qua mail',
                            style: TextStyle(fontFamily: 'Roboto',fontSize: 16),
                          ),
                        )
                      )
                    
               ),
              
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> getAllEmailInvite() async {
    emails.clear();
    dropDownValue.clear();
    dropDownValueCheckUpdate = [];
    InviteReceive inviteReceive = InviteReceive();
    inviteReceive = await FireStorageService().getInviteById(widget.noteId);
    emailsMap = inviteReceive.rules;
    inviteReceive.rules.forEach((key, value) {
      if (!key.contains('timestamp')) {
        emails.add(key);
        lsttimestamp.add(value['timestamp']);
        dropDownValue.add(value['permission']);
        dropDownValueCheckUpdate.add(value['permission']);
      }
    });
    setState(() {});
  }

  Future<void> addInviteTemp() async {
    String key = _textEditingController.text;
    String rule = 'Chỉ xem';
    DateTime now = DateTime.now();
    String currentDateTime = DateFormat.yMd('vi_VN').add_jm().format(now);
    setState(() {
      emails.add(key);
      lsttimestamp.add(currentDateTime);
      dropDownValue.add(rule);
      dropDownValueCheckUpdate.add(rule);
      addList.add({key: rule});
    });
  }

  Future<void> updateInviteToCloud() async {
    DateTime now = DateTime.now();
    String currentDateTime = DateFormat.yMd('vi_VN').add_jm().format(now);
    Invite invite = Invite();
    Map<String, String> permissionmap;
    for (int i = 0; i < emails.length; i++) {
      permissionmap = {"permission" : dropDownValue[i]};
      permissionmap.addAll({'timestamp': currentDateTime});

      invite.rules.addAll({emails[i]: permissionmap});

      //invite.rules.addAll({emails[i]: dropDownValue[i]});
    }
    //invite.rules.addAll({'timestamp' : currentDateTime});
    invite.noteId = widget.noteId;
    await FireStorageService().updateInvite(invite);
  }

  // Future<void> updateInviteToUser() async {
  //   DateTime dateTime = DateTime.now();
  //   Timestamp currentDateTime = Timestamp.fromDate(dateTime);
  //   Receive receive = Receive();
  //   for (int i = 0; i < emails.length; i++) {
  //     receive.rule = dropDownValue[i];
  //     receive.email = emails[i];
  //     receive.noteId = widget.noteId;
  //     receive.timeStamp = currentDateTime;
  //     await FireStorageService().addInviteToUser(receive);
  //   }
  // }

  Future<void> updateInviteToUserFilter() async {
    DateTime dateTime = DateTime.now();
    Timestamp currentDateTime = Timestamp.fromDate(dateTime);
    Receive receive = Receive();
    for (int i = 0; i < emails.length; i++) {
      if (dropDownValueCheckUpdate[i] != dropDownValue[i]) {
        receive.rule = dropDownValue[i];
        receive.email = emails[i];
        receive.noteId = widget.noteId;
        receive.timeStamp = currentDateTime;
        await FireStorageService().addInviteToUser(receive);
      }
    }

    if(mounted){
      setState(() {

      });
    }



    if(addList.isNotEmpty){
      for (var element in addList) {
        element.forEach((key, value) {
          receive.rule = value;
          receive.email = key;
        });
        receive.noteId = widget.noteId;
        receive.timeStamp = currentDateTime;
        await FireStorageService().addInviteToUser(receive);
      }
      addList.clear();
    }
  }

  Future<void> deleteReceive() async {
    Receive receive = Receive();
    for (int i = 0; i < deleteListTemp.length; i++) {
      receive.email = deleteListTemp[i];
      receive.noteId = widget.noteId;
      await FireStorageService().deleteReceive(receive);
    }
    deleteListTemp.clear();
    setState(() {
      isDelete = false;
    });
  }

  Future<bool> checkDuplicate(String key) async {
    bool check = true;
    if (emailsMap.containsKey(key)) {
      check = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                  "Địa chỉ email này đã được mời hoặc chưa lưu thay đổi !"),
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
    if (userEmail == email) {
      check = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title:
                  Text('Bạn không thể tự mời chính mình, thử lại email khác'),
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
              title: Text('Email không đúng định dạng, thử lại'),
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

   bool checkUpdate() {
    if (listEquals(dropDownValue, dropDownValueCheckUpdate)) {
      return true;
    }
    return false;
  }

  Future<void> sendEmail(String dynamiclink) async {
    String mailBody = mailBodyController.text + "\n\n" + "Đường dẫn để xem ghi chú online:" + "\n\n" + dynamiclink;
    String mailSubject = FirebaseAuth.instance.currentUser?.email?.toString() ?? "";
  
    final Email email = Email(
      body: mailBody,
      subject: mailSubject + " chia sẻ ghi chú",
      recipients: [sharewithMailController.text],
      attachmentPaths: [],
      isHTML: false,
    );

    String platformResponse;

    try {
      await EasyLoading.show(
        status: "Đang gửi mail...",
        maskType: EasyLoadingMaskType.none,
      );

      await FlutterEmailSender.send(email);

      await EasyLoading.dismiss();
      
      platformResponse = 'success';
    } catch (error) {
      debugPrint(error.toString());
      platformResponse = error.toString();
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: platformResponse == 'success' ? 
        Text("Mail đã được gửi thành công!") 
        : 
        Text("Quá trình gửi mail xảy ra lỗi, hãy chia sẻ lại!"),
      ),
    );
  }

  void setAddList(int index, String rule) {

    for(int i = 0; i < addList.length; i++){
      addList[i].forEach((key, value) {
        if(key == emails[index]){
          addList[i].update(key, (value) => rule);
        }
      });
    }


  }

}
