import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../../DAL/TagDAL.dart';
import '../../model/SqliteModel/TagModel.dart';
import '../../model/SqliteModel/initializeDB.dart';
import '../model/tag.dart';
import '../model/tag_receive.dart';
import '../services/firebase_firestore_service.dart';

class TagScreen extends StatefulWidget {
  const TagScreen({Key? key,
    required this.email
  }) : super(key: key);

  final String? email;
  @override
  State<StatefulWidget> createState() {
    return TagScreenState();
  }
}

class TagScreenState extends State<TagScreen>{
  List<TagReceive> lsttags = [];
  List<TagModel> lsttagslocal = [];

  TagDAL tagDAL = TagDAL();

  TextEditingController _tagnamecontroller = TextEditingController();


  bool loginState = false;
  bool isCreatedNewTag = false;

  String? newTagName = "";

  
  @override
  void initState() {
    super.initState();
    
    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.chasingDots
      ..loadingStyle = EasyLoadingStyle.dark;

    checkLogin();
    
    if (widget.email != "") {
      getTagsByID();
    } else {
      getTagsAtLocal();
    }
  }
  
  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
              backgroundColor: const Color.fromARGB(131, 0, 0, 0),
              elevation: 0.0,
              title: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Nhãn của bạn',
                        )
                      ],
                    ),
              centerTitle: true,
              
            ),
        body: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                flex: 0,
                child: TextField(
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                                decoration: const InputDecoration(
                                    hintText: "Tìm kiếm nhãn...",
                                    prefixIcon: Icon(Icons.search),
                                    filled: true,
                                    fillColor:
                                        Color.fromARGB(255, 239, 241, 243),
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                      width: 0.5,
                                    ))),
                                onChanged: (value) async {
                                  if (value == "") {
                                    await EasyLoading.show(
                                            status:"Đang tải danh sách nhãn của bạn...",
                                            maskType: EasyLoadingMaskType.none,
                                          );
                                    lsttags = await FireStorageService().getAllTags();

                                    await EasyLoading.dismiss();
                                  } else {
                                    await EasyLoading.show(
                                            status: "Đang tìm kiếm...",
                                            maskType: EasyLoadingMaskType.none,
                                          );
                                    lsttags = lsttags.where((element) => element.tagname.toLowerCase().contains(value)).toList();
                                    
                                    await EasyLoading.dismiss();
                                  }

                                  setState(() {});
                                }
                        )
              ),

              Expanded(
                flex: 5,
                child: ListView.builder(
                  itemCount: loginState == true ? lsttags.length : lsttagslocal.length,
                  itemBuilder: (context, index) {
                    TextEditingController updatenamecontroller = TextEditingController();
                    updatenamecontroller.text = lsttags[index].tagname;
                    return Container(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: ListTile(
                                    leading: const Icon(Icons.turned_in_outlined,
                                                    color: Color.fromARGB(255, 251, 178, 37),
                                                    size: 22,
                                            ),
                                    trailing: Container(
                                                width: 100,
                                                // decoration: BoxDecoration(
                                                //   border: Border.all(
                                                //     color: Colors.red,
                                                //     width: 1.0
                                                //   )
                                                // ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  children: [
                                                     IconButton(
                                                       onPressed: () async {
                                                          newTagName = await showDialog<String>(
                                                            context: context, 
                                                            barrierDismissible: false,
                                                            builder: (BuildContext context) {
                                                              return Dialog(
                                                                child: Container(
                                                                  margin: const EdgeInsets.all(8),
                                                                  child: Column(
                                                                    mainAxisSize: MainAxisSize.min,
                                                                    children: [
                                                                      const Center(
                                                                        child: Text(
                                                                          "Sửa thông tin nhãn",
                                                                          style: TextStyle(fontSize: 18),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height: 15,
                                                                      ),

                                                                      Expanded(
                                                                        flex: 0,
                                                                        child: TextField(
                                                                          controller: updatenamecontroller,
                                                                          style: const TextStyle(
                                                                            fontSize: 15
                                                                          ),
                                                                          decoration: InputDecoration(
                                                                            border: OutlineInputBorder(
                                                                              borderSide: BorderSide(
                                                                                width: 1.0
                                                                              )
                                                                            )
                                                                          ),
                                                                        )
                                                                      ),

                                                                      Expanded(
                                                                        flex: 0,
                                                                        child: Row(
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 1,
                                                                              child: Container(
                                                                                child: ElevatedButton(
                                                                                  onPressed: (){
                                                                                    Navigator.of(context).pop("");
                                                                                    updatenamecontroller.text = lsttags[index].tagname;
                                                                                  },
                                                                                  style: ElevatedButton.styleFrom(
                                                                                      shape:
                                                                                          const StadiumBorder(),
                                                                                      backgroundColor:
                                                                                          Color.fromARGB(
                                                                                              255, 97, 115, 239),
                                                                                      side: const BorderSide(
                                                                                        width: 1.0,
                                                                                        color: Colors.grey,
                                                                                      ),
                                                                                    ),
                                                                                    child: Text("HUỶ")
                                                                                )
                                                                              ),
                                                                            ),

                                                                            Expanded(
                                                                              flex: 1,
                                                                              child: Container(
                                                                                child: ElevatedButton(
                                                                                  onPressed: (){
                                                                                    Navigator.of(context).pop(updatenamecontroller.text);
                                                                                  },
                                                                                  style: ElevatedButton.styleFrom(
                                                                                      shape:
                                                                                          const StadiumBorder(),
                                                                                      backgroundColor:
                                                                                          Color.fromARGB(
                                                                                              255, 97, 115, 239),
                                                                                      side: const BorderSide(
                                                                                        width: 1.0,
                                                                                        color: Colors.grey,
                                                                                      ),
                                                                                    ),
                                                                                    child: Text("CẬP NHẬT")
                                                                                )
                                                                              ),
                                                                            )
                                                                          ],
                                                                        )
                                                                      )
                                                                    ],
                                                                  )
                                                                ),
                                                              );
                                                            },
                                                          );

                                                          if(newTagName != lsttags[index].tagname && newTagName != "" && newTagName != null){
                                                            updateTag(lsttags[index].tagid, newTagName?.toString() ?? "");

                                                            
                                                          }  
                                                       },
                                                       icon: const Icon(Icons.edit,
                                                        color: Colors.grey,
                                                        size: 22, 
                                                       ),
                                                     ),
                                                  
                                                     IconButton(
                                                       onPressed: () async {
                                                          bool deleteornot = await showAlertDialog(
                                                                  context,
                                                                  "Bạn có muốn xoá nhãn này không? Tất cả ghi chú được gán nhãn này sẽ được gỡ nhãn!",
                                                                  "Xoá ghi chú");
                                                          if(deleteornot){
                                                            deleteTag(lsttags[index].tagid);
                                                          }
                                                          
                                                       },
                                                       icon: const Icon(Icons.delete,
                                                        color: Colors.red,
                                                        size: 22,
                                                       ),
                                                     ),
                                                  ]
                                                ),
                                    ),
                                            
                                    title: Container(
                                      width: 200,
                                      // decoration: BoxDecoration(
                                      //             border: Border.all(
                                      //               color: Colors.red,
                                      //               width: 1.0
                                      //             )
                                      // ),
                                      child: Text( loginState == true ?
                                                lsttags[index].tagname
                                                :
                                                lsttagslocal[index].tag_name
                                                ,
                                                style: TextStyle(fontSize: 18),
                                                overflow: TextOverflow.ellipsis,
                                             ),
                                    ),
                                  ),
                    );
                  },
                ),
              )
              ,
              Expanded(
                flex: 0,
                child: isCreatedNewTag ? 
                Container(
                  width: 400,
                  child: ListTile(
                    leading: IconButton(
                              icon: Icon(
                                Icons.close,
                                size: 20,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                isCreatedNewTag = false;
                                setState(() {});
                              },
                    ),
                    trailing: IconButton(
                                onPressed: () async {
                                 createTag();
                                 
                                },
                                icon: const Icon(Icons.check,
                                            size: 20,
                                            color:Colors.green)
                    ),
                    title: Container(
                            width: 200,
                            child: TextField(
                                    controller: _tagnamecontroller,
                                    style: const TextStyle(
                                                  fontSize: 18,
                                                 )
                                   ),
                    ),
                  ),
                )
                
                :

                Container(
                  width: 400,
                  child: ElevatedButton.icon(
                    onPressed: (){
                      isCreatedNewTag = true;
                      setState(() {});
                    }, 
                    icon: const Icon(Icons.add,
                           size: 20,
                           color: Color.fromARGB(255,97,115,239)
                          ), 
                    label: Text('Tạo nhãn mới', style: TextStyle(color: Color.fromARGB(255, 97, 115, 239)),),

                    style: ElevatedButton
                                                            .styleFrom(
                                                          shape:
                                                              const StadiumBorder(),
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          shadowColor: Colors
                                                              .transparent
                                                              .withOpacity(0.1),
                                                          elevation: 0,
                                                          side:
                                                              const BorderSide(
                                                            width: 1.0,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    97,
                                                                    115,
                                                                    239),
                                                          ),
                                                        ),
                  ),
                ),
              )
            ],
          ),
        )
      ),
    );
  }

  Future<void> getTagsByID() async {
    lsttags = await FireStorageService().getAllTags();
    setState(() {
      
    });
  }

  Future<void> getTagsAtLocal() async {
    lsttagslocal = await tagDAL.getAllTagsByUserID(-1, InitDataBase.db);
    setState(() {
      
    });
  }

  Future<void> createTag() async {
    if (_tagnamecontroller.text.isNotEmpty) {
      await EasyLoading.show(
        status: "Đang tạo nhãn mới...",
        maskType: EasyLoadingMaskType.none,
      );

      Tag t = Tag();
      t.tagname = _tagnamecontroller.text;
      FireStorageService().saveTags(t);

      lsttags = await FireStorageService().getAllTags();

      await EasyLoading.dismiss();

      isCreatedNewTag = false;

      _tagnamecontroller.text = "";

      setState(() {});
    }
  }

  Future<void> updateTag(String tagid, String newname) async{
     await EasyLoading.show(
      status: "Đang cập nhật thông tin...",
      maskType: EasyLoadingMaskType.none,
     );

    Tag t = Tag();
    t.tagname = newname;

    await FireStorageService().updateTagById(tagid, t);

    lsttags = await FireStorageService().getAllTags();

    await EasyLoading.dismiss();

    setState(() {
      
    });
  }

  Future<void> deleteTag(String tagid) async {
    await EasyLoading.show(
      status: "Đang cập nhật thông tin...",
      maskType: EasyLoadingMaskType.none,
     );

    await FireStorageService().deleteTagById(tagid);

    lsttags = await FireStorageService().getAllTags();

    await EasyLoading.dismiss();

    setState(() {
      
    });
  }

  checkLogin() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        loginState = true;
      } else {
        loginState = false;
      }
    });
  }

  Future<bool> showAlertDialog(
      BuildContext context, String message, String alerttitle) async {
    // set up the buttons
    Widget cancelButton = OutlinedButton(
      child: Text('Không'),
      onPressed: () {
        // returnValue = false;
        Navigator.of(context).pop(false);
      },
    );
    Widget continueButton = OutlinedButton(
      child: Text("Có"),
      onPressed: () {
        // returnValue = true;
        Navigator.of(context).pop(true);
      },
    ); // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(alerttitle),
      content: Text(message),
      actions: [
        cancelButton,
        continueButton,
      ],
    ); // show the dialog
    final result = await showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
    return result ?? false;
  }
}