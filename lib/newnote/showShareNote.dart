// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:io';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

//import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notemobileapp/DAL/FB_DAL.dart/FB_Note.dart';
import 'package:notemobileapp/DAL/FB_DAL.dart/FB_NoteContent.dart';

import 'package:notemobileapp/model/SqliteModel/UpdateNoteModel.dart';
import 'package:notemobileapp/test/component/text_edit.dart';
import 'package:notemobileapp/test/model/note_content.dart';
import 'package:notemobileapp/test/model/note_receive.dart';
import 'package:notemobileapp/test/model/tag_receive.dart';
import 'package:notemobileapp/test/page/email_rules_page.dart';
import 'package:notemobileapp/test/services/firebase_firestore_service.dart';
import 'package:notemobileapp/test/services/firebase_store_service.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:select_dialog/select_dialog.dart';

import 'package:speech_to_text/speech_to_text.dart';
import 'package:notemobileapp/DAL/UserDAL.dart';

import 'package:notemobileapp/DAL/NoteDAL.dart';
import 'package:notemobileapp/DAL/NoteContentDAL.dart';

import '../DAL/TagDAL.dart';
import '../model/SqliteModel/NoteContentModel.dart';
import '../model/SqliteModel/NoteModel.dart';
import '../model/SqliteModel/TagModel.dart';
import '../model/SqliteModel/initializeDB.dart';
import '../router.dart';
import '../test/model/tag.dart';
import '../test/services/internet_connection.dart';

class ShowShareNote extends StatefulWidget {
  const ShowShareNote(
      {Key? key,
      required this.noteId,
      required this.isEdit,
      required this.email,
      required this.rule})
      : super(key: key);

  final String noteId;
  final bool isEdit;
  final String rule;
  final String email;

  @override
  State<StatefulWidget> createState() {
    return ShowShareNoteState();
  }
}

class ShowShareNoteState extends State<ShowShareNote> {
  late BuildContext appcontext;
  List<String> rules = ['Chỉ xem', 'Chỉnh sửa'];
  File? _image;

  SpeechToText speechToText = SpeechToText();

  static FocusNode fcnFirstTxtField = FocusNode();
  static TextEditingController firstTxtFieldController =
      TextEditingController();

  List<dynamic> noteContentList = <dynamic>[
    TextField(
      keyboardType: TextInputType.multiline,
      focusNode: fcnFirstTxtField,
      controller: firstTxtFieldController,
      showCursor: true,
      autofocus: true,
      maxLines: null,
      style: const TextStyle(fontSize: 14),
      decoration: const InputDecoration(border: InputBorder.none),
    )
  ];

  List<FocusNode> lstFocusNode = <FocusNode>[fcnFirstTxtField];
  List<TextEditingController> lstTxtController = <TextEditingController>[
    firstTxtFieldController
  ];

  List<dynamic> SaveNoteContentList = <dynamic>[firstTxtFieldController];
  List<dynamic> UpdateNoteContentList = <dynamic>[firstTxtFieldController];

  List<UpdateNoteModel> lstupdatecontents = <UpdateNoteModel>[];
  List<UpdateNoteModel> lstdeletecontents = <UpdateNoteModel>[];

  late ScrollController _controller;
  late TextEditingController _noteTitleController;
  late TextEditingController _notecontentcontroller;
  late TextEditingController _tagnamecontroller;

  bool _showFab = true;
  bool _isElevated = true;
  bool _isVisible = true;
  bool _isBottomAppBarVisible = false;
  bool MicroIsListening = false;

  bool isEditCompleted = true;
  bool isConnected = false;
  bool isCreatedNewTag = false;

  bool loginState = false;

  int vitrihinh = 0;

  late String NoteTitle = '';
  late String currentDateTime;
  late String firsttxtfieldcont;
  

  FloatingActionButtonLocation get _fabLocation => _isVisible
      ? FloatingActionButtonLocation.centerDocked
      : FloatingActionButtonLocation.centerFloat;

  NoteReceive note = NoteReceive();
  TagReceive? tag;
  TagModel? taglocal;

  List<TagReceive> lsttags = [];
  List<TagModel> lsttagslocal = [];

  late StreamSubscription subscription;

  Map _source = {ConnectivityResult.none: false};
  final NetworkConnectivity _networkConnectivity = NetworkConnectivity.instance;

  void _listen() {
    final ScrollDirection direction = _controller.position.userScrollDirection;
    if (direction == ScrollDirection.forward) {
      _show();
    } else if (direction == ScrollDirection.reverse) {
      _hide();
    }
  }

  void _show() {
    if (!_isVisible) {
      setState(() => _isVisible = true);
    }
  }

  void _hide() {
    if (_isVisible) {
      setState(() => _isVisible = false);
    }
  }

  void _onShowFabChanged(bool value) {
    setState(() {
      _showFab = value;
    });
  }

  void _onElevatedChanged(bool value) {
    setState(() {
      _isElevated = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(_listen);
    _noteTitleController = TextEditingController();
    _notecontentcontroller = TextEditingController();

    _tagnamecontroller = TextEditingController();
    tag = TagReceive();
    tag!.tagid = "";
    tag!.tagname = "";

    taglocal = TagModel(tag_name: "");

    initializeDateFormatting();
    DateTime now = DateTime.now();
    currentDateTime = DateFormat.yMd('vi_VN').add_jm().format(now);

    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.chasingDots
      ..loadingStyle = EasyLoadingStyle.dark;

    checkLogin();
    CheckInternetConnection();


    if (widget.isEdit && widget.email != "") {
      var temp = int.tryParse(widget.noteId);
      if (temp != null) {

      } else {
        getNoteById(widget.noteId);
      }
    }

    if (widget.email != "") {
      getTagsByID();
    }

    //CheckInternetConnection();
  }

  @override
  void dispose() {
    _controller.removeListener(_listen);
    _controller.dispose();
    _noteTitleController.dispose();
    _notecontentcontroller.dispose();
    firstTxtFieldController.text = "";
    super.dispose();
  }

  Future<void> CheckInternetConnection() async {
    _networkConnectivity.initialise();
    _networkConnectivity.myStream.listen((source) {
      _source = source;
      // 1.
      switch (_source.keys.toList()[0]) {
        case ConnectivityResult.mobile:
          isConnected = _source.values.toList()[0] ? true : false;
          break;
        case ConnectivityResult.wifi:
          isConnected = _source.values.toList()[0] ? true : false;
          break;
        case ConnectivityResult.none:
        default:
          isConnected = false;
      }
    });
  }

  Future getImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final imageTemp = File(image.path);

    _image = imageTemp;

    if (widget.isEdit == false) {
      noteContentList.add(_image);
      FocusNode fcnTxtField = FocusNode();
      TextEditingController txtFieldController = TextEditingController();
      Widget nextTextField = textFieldWidget(txtFieldController, fcnTxtField);
      lstFocusNode.add(fcnTxtField);
      lstTxtController.add(txtFieldController);
      noteContentList.add(nextTextField);
      SaveNoteContentList.add(imageTemp);
      SaveNoteContentList.add(txtFieldController);
    } else {
      noteContentList.add(_image);
      FocusNode fcnTxtField = FocusNode();
      TextEditingController txtFieldController = TextEditingController();
      Widget nextTextField = textFieldWidget(txtFieldController, fcnTxtField);
      lstFocusNode.add(fcnTxtField);
      lstTxtController.add(txtFieldController);
      noteContentList.add(nextTextField);
      UpdateNoteContentList.add(imageTemp);

      UpdateNoteModel updtmodel =
          UpdateNoteModel(notecontent_id: null, type: "insert_img");
      UpdateNoteModel updtmodel2 =
          UpdateNoteModel(notecontent_id: null, type: "insert_text");

      lstupdatecontents.add(updtmodel);
      lstupdatecontents.add(updtmodel2);

      UpdateNoteContentList.add(txtFieldController);
    }

    setState(() {});
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


  Future<void> uploadNoteToCloud() async {
    // showDialog(
    //     context: appcontext,
    //     builder: (context) {
    //       return Center(
    //         child: CircularProgressIndicator(),
    //       );
    //     });
    NoteContent noteContent = NoteContent();
    List<dynamic> CloudContents = [];

    firsttxtfieldcont = SaveNoteContentList[0].text;
    File file;
    String urlImageCloud;

    for (int i = 0; i < SaveNoteContentList.length; i++) {
      if (SaveNoteContentList[i] is File) {
        // String imageName = basename(SaveNoteContentList[i].path);
        CloudContents.add({'local_image': SaveNoteContentList[i].path});
      } else {
        String noiDungGhiChu = SaveNoteContentList[i].text;
        CloudContents.add({'text': noiDungGhiChu});
      }
    }
    noteContent.timeStamp = currentDateTime;
    noteContent.title = NoteTitle;
    noteContent.content = CloudContents;
    noteContent.tagname = tag!.tagname == "" || tag == null
        ? ""
        : tag!.tagname; //////SỬA LẠI TAGNAME Ở ĐÂY KHI LÀM PHẦN TAG
    //////SỬA LẠI TAGNAME Ở ĐÂY KHI LÀM PHẦN TAG
    /////////SỬA LẠI TAGNAME Ở ĐÂY KHI LÀM PHẦN TAG

    //Navigator.pop(appcontext);

    String noteid = await FireStorageService().saveContentNotesForShare(noteContent, widget.email);

    if (isConnected) {
      for (int i = 0; i < SaveNoteContentList.length; i++) {
        if (SaveNoteContentList[i] is File) {
          file = File(SaveNoteContentList[i].path);
          urlImageCloud = await StorageService().uploadImage(file);
          CloudContents.insert(i + 1, {'image': urlImageCloud});
        }
      }

      await FireStorageService().updateCloudImageURLForShare(noteid, CloudContents, widget.email);
    }
  }



  Widget buildImageWidget(BuildContext context, int index) {
    Widget imageWidget = Stack(children: [
      noteContentList[index] is String
          ? Transform.scale(
            scale: 1,
            child: Image.network(
                noteContentList[index],
                fit: BoxFit.cover,
              ),
          )
          : Transform.scale(
            scale: 1,
            child: Image.file(
                noteContentList[index]!,

                fit: BoxFit.cover,
              ),
          ),
      widget.rule == rules[1] ? 
      Positioned(
          bottom: 0,
          right: 0,
          child: IconButton(
              icon: Icon(
                Icons.cancel,
                color: Colors.black.withOpacity(0.5),
                size: 30,
              ),
              onPressed: () async {
                bool isDeleted = await showAlertDialog(
                    appcontext, "Bạn có muốn xoá hình này?", "Xoá hình");
                if (isDeleted) {
                  //XOA HINH
                  noteContentList.removeAt(index);

                  if (widget.isEdit == false) {
                    SaveNoteContentList.removeAt(index);
                  } else {
                    if (loginState) {
                    } else {
                      UpdateNoteContentList.removeAt(index);

                      UpdateNoteModel delmodel = UpdateNoteModel(
                          notecontent_id:
                              lstupdatecontents[index].notecontent_id,
                          type: "delete");

                      lstupdatecontents.removeAt(index);
                      lstdeletecontents.add(delmodel);
                    }
                  }
                }

                if (widget.isEdit == false) {
                  if (SaveNoteContentList[index].text == "") {
                    //XOA TEXT FIELD NGAY SAU HINH NEU TEXT FIELD TRONG KHI TAO GHI CHU
                    noteContentList.removeAt(index);
                  }
                } else {
                  if (loginState) {
                    if (noteContentList[index] is TextField) {
                      if (noteContentList[index].controller?.text == "") {
                        //XOA TEXT FIELD NGAY SAU HINH NEU TEXT FIELD TRONG KHI EDIT GHI CHU
                        noteContentList.removeAt(index);
                      }
                    }
                  } else {
                    if (UpdateNoteContentList[index] is TextEditingController) {
                      if (UpdateNoteContentList[index].text == "") {
                        //XOA TEXT FIELD NGAY SAU HINH NEU TEXT FIELD TRONG KHI EDIT GHI CHU

                        noteContentList.removeAt(index);

                        UpdateNoteModel delmodel = UpdateNoteModel(
                            notecontent_id:
                                lstupdatecontents[index].notecontent_id,
                            type: "delete");

                        lstupdatecontents.removeAt(index);
                        lstdeletecontents.add(delmodel);
                      }
                    }
                  }
                }
                setState(() {});
              })) : SizedBox(width: 0, height: 0,)
    ]);
    return imageWidget;
  }

  //final QuillController _quillController = QuillController.basic();

  @override
  Widget build(BuildContext context) {
    appcontext = context;
    return widget.rule == rules[0]
        ? Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(131, 0, 0, 0),
              elevation: 0.0,
              title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Xem ghi chú',
                        )
                      ],
                    ),
              centerTitle: true,
            ),
            body: Container(
              padding: EdgeInsets.all(13),
              child: Column(children: [
                TextField(
                  readOnly: true,
                  autofocus: false,
                  style: const TextStyle(
                      fontSize: 23, fontWeight: FontWeight.bold),
                  controller: _noteTitleController,
                  decoration: const InputDecoration(
                    hintStyle:
                        TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                      ),
                    ),
                  ),
                  onSubmitted: (String value) {
                    NoteTitle = _noteTitleController.text;
                    fcnFirstTxtField.requestFocus();
                  },
                  onTapOutside: (event) {
                    NoteTitle = _noteTitleController.text;
                  },
                ),
                const SizedBox(height: 10),
                Container(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                elevation: 0,
                                padding: EdgeInsets.only(left: 0.0),
                              ),
                              icon: const Icon(Icons.turned_in_outlined,
                                  size: 19.0,
                                  color: Color.fromARGB(255, 97, 115, 239)),
                              label: loginState
                                  ? Text(
                                      tag == null || tag!.tagname == ""
                                          ? "Chưa có nhãn"
                                          : tag!.tagname,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Color.fromARGB(
                                              255, 97, 115, 239)),
                                    )
                                  : Text(
                                      taglocal == null ||
                                              taglocal!.tag_name == ""
                                          ? "Chưa có nhãn"
                                          : taglocal!.tag_name,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Color.fromARGB(
                                              255, 97, 115, 239)),
                                    ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Ngày tạo: ' + currentDateTime,
                              style:
                                  TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    )),
                Expanded(
                    child: ListView.separated(
                        controller: _controller,
                        itemCount: noteContentList.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (noteContentList[index] is String ||
                              noteContentList[index] is File) {
                            return buildImageWidget(context, index);
                          } else {
                            return noteContentList[index];
                          }
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider())),
              ]),
            ),
    )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(131, 0, 0, 0),
              elevation: 0.0,
              title: widget.isEdit
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_note),
                        Text(
                          'Sửa ghi chú',
                        )
                      ],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.create),
                        Text(
                          'Tạo ghi chú',
                        )
                      ],
                    ),
              centerTitle: true,
              actions: [
                if (widget.isEdit && isEditCompleted)
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                    ),
                    onPressed: () {
                      isEditCompleted = false;
                      setState(() {});
                      return;

                      ////UPDATE NOTE TREN CLOUD
                      ////UPDATE NOTE TREN CLOUD
                      ////UPDATE NOTE TREN CLOUD

                      //saveNoteToLocal();

                      //Navigator.pop(context, true);
                    },
                  )
                else if (isEditCompleted == false)
                  IconButton(
                    icon: const Icon(
                      Icons.update,
                    ),
                    onPressed: () async {
                      if (widget.email != "") {
                        updateNote();
                        Navigator.of(context).pop('RELOAD_LIST');
                      }
                      //updateNoteToLocal();

                      //Navigator.push(context, MaterialPageRoute(builder: (context) => const ToDoPage()));
                    },
                  ),
                //Icon(null)

              ],
            ),
            body: Container(
              padding: EdgeInsets.all(13),
              child: Column(children: [
                TextField(
                  autofocus: true,
                  style: const TextStyle(
                      fontSize: 23, fontWeight: FontWeight.bold),
                  controller: _noteTitleController,
                  decoration: const InputDecoration(
                    hintStyle:
                        TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        width: 1,
                      ),
                    ),
                  ),
                  onSubmitted: (String value) {
                    NoteTitle = _noteTitleController.text;
                    fcnFirstTxtField.requestFocus();
                  },
                  onTapOutside: (event) {
                    NoteTitle = _noteTitleController.text;
                  },
                ),
                const SizedBox(height: 10),
                Container(
                    alignment: Alignment.topLeft,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                elevation: 0,
                                padding: EdgeInsets.only(left: 0.0),
                              ),
                              icon: const Icon(Icons.turned_in_outlined,
                                  size: 19.0,
                                  color: Color.fromARGB(255, 97, 115, 239)),
                              label: loginState
                                  ? Text(
                                      tag == null || tag!.tagname == ""
                                          ? "Chưa có nhãn"
                                          : tag!.tagname,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Color.fromARGB(
                                              255, 97, 115, 239)),
                                    )
                                  : Text(
                                      taglocal == null ||
                                              taglocal!.tag_name == ""
                                          ? "Chưa có nhãn"
                                          : taglocal!.tag_name,
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Color.fromARGB(
                                              255, 97, 115, 239)),
                                    ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Ngày tạo: ' + currentDateTime,
                              style:
                                  TextStyle(fontSize: 13, color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    )),
                Expanded(
                    child: ListView.separated(
                        controller: _controller,
                        itemCount: noteContentList.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (noteContentList[index] is String ||
                              noteContentList[index] is File) {
                            return buildImageWidget(context, index);
                          } else {
                            return noteContentList[index];
                          }
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider())),
              ]),


            ),
            floatingActionButton: (isEditCompleted == false) ||
                    widget.isEdit == false
                ? AvatarGlow(
                    animate: MicroIsListening,
                    duration: const Duration(milliseconds: 2000),
                    glowColor: Colors.deepOrange,
                    repeat: true,
                    child: GestureDetector(
                      onTapDown: (details) async {
                        var available = await speechToText.initialize();
                        var vitri;
                        if (available) {
                          setState(() {
                            MicroIsListening = true;
                            speechToText.listen(onResult: (result) {
                              setState(() {
                                for (var i = 0; i < lstFocusNode.length; i++) {
                                  if (lstFocusNode[i].hasFocus) {
                                    vitri = i;
                                    break;
                                  }
                                }
                                if (result.finalResult) {
                                  String doanvannoi = result.recognizedWords;
                                  lstTxtController[vitri].text += doanvannoi;
                                  if (vitri == 0) {
                                    firsttxtfieldcont = doanvannoi;
                                  }
                                  MicroIsListening = false;
                                }
                              });
                            });
                          });
                        }
                      },

                      onTapUp: (details) {
                        setState(() {
                          MicroIsListening = false;
                        });
                        speechToText.stop();
                      },

                      child: const CircleAvatar(
                        backgroundColor: Colors.brown,
                        radius: 30,
                        child: const Icon(Icons.mic, color: Colors.white),
                      ),
                    ),
                  )
                : null,
            floatingActionButtonLocation: _fabLocation,
            bottomNavigationBar: ClipRRect(
              clipBehavior: Clip.hardEdge,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0)),
              child: BottomAppBar(
                height: (isEditCompleted == false) || widget.isEdit == false
                    ? 70.0
                    : 0.0,
                color: Color.fromARGB(255, 108, 127, 244),
                shape: CircularNotchedRectangle(),
                elevation: _isElevated ? null : 0.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    IconButton(
                        tooltip: 'Chèn hình',
                        icon: const Icon(Icons.image_outlined),
                        color: Colors.white,
                        onPressed: () {
                          getImage();
                        }


                        ),
                    IconButton(
                      tooltip: 'Hẹn giờ thông báo',
                      color: Colors.white,
                      icon: const Icon(Icons.notifications_none_outlined),
                      onPressed: () {},
                    ),
                    IconButton(
                      tooltip: 'Định dạng chữ',
                      color: Colors.white,
                      icon: const Icon(Icons.abc),
                      onPressed: () {},
                    ),
                    IconButton(
                      tooltip: 'Gắn thẻ',
                      color: Colors.white,
                      icon: const Icon(
                        Icons.turned_in_not_outlined,
                        size: 22,
                      ),
                      onPressed: () async {
                        if (loginState) {
                          tag = await showDialog<TagReceive>(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return Dialog(
                                        child: Container(
                                      margin: EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          const Center(
                                            child: Text(
                                              "Chọn nhãn",
                                              style: TextStyle(fontSize: 18),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 15,
                                          ),
                                          Expanded(
                                            flex: 0,
                                            child: TextField(
                                              style: const TextStyle(
                                                fontSize: 15,
                                              ),
                                              decoration: const InputDecoration(
                                                hintText: "Tìm kiếm nhãn...",
                                                prefixIcon: Icon(Icons.search),
                                              ),
                                              onChanged: (value) async {
                                                if (value == "") {
                                                  await EasyLoading.show(
                                                    status:
                                                        "Đang tải danh sách nhãn của bạn...",
                                                    maskType:
                                                        EasyLoadingMaskType
                                                            .none,
                                                  );
                                                  lsttags =
                                                      await FireStorageService()
                                                          .getAllTagsForShare(widget.email);

                                                  await EasyLoading.dismiss();
                                                } else {
                                                  await EasyLoading.show(
                                                    status: "Đang tìm kiếm...",
                                                    maskType:
                                                        EasyLoadingMaskType
                                                            .none,
                                                  );
                                                  lsttags = lsttags
                                                      .where((element) =>
                                                          element.tagname
                                                              .toLowerCase()
                                                              .contains(value))
                                                      .toList();
                                                  await EasyLoading.dismiss();
                                                }

                                                setState(() {});
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            flex: 5,
                                            child: ListView.builder(
                                                itemBuilder: (context, index) {
                                                  return Container(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            10, 0, 10, 0),
                                                    child: ListTile(
                                                      leading: Icon(
                                                        Icons
                                                            .turned_in_outlined,
                                                        color: Color.fromARGB(
                                                            255, 251, 178, 37),
                                                        size: 22,
                                                      ),
                                                      trailing: Icon(
                                                        Icons.trip_origin,
                                                        color: Colors.grey,
                                                        size: 22,
                                                      ),
                                                      title: Text(
                                                        lsttags[index].tagname,
                                                        style: TextStyle(
                                                            fontSize: 18),
                                                      ),
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pop(
                                                                lsttags[index]);
                                                      },
                                                    ),
                                                  );
                                                },
                                                itemCount: lsttags.length),
                                          ),
                                          Expanded(
                                            flex: 0,
                                            child: Container(
                                              width: 300,
                                              child: ElevatedButton.icon(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(null);
                                                  },
                                                  icon: Icon(Icons.close,
                                                      size: 20,
                                                      color: Color.fromARGB(
                                                          255, 97, 115, 239)),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    shape:
                                                        const StadiumBorder(),
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    shadowColor: Colors
                                                        .transparent
                                                        .withOpacity(0.1),
                                                    elevation: 0,
                                                    side: const BorderSide(
                                                      width: 1.0,
                                                      color: Color.fromARGB(
                                                          255, 97, 115, 239),
                                                    ),
                                                  ),
                                                  label: Text("Gỡ nhãn",
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255,
                                                              97,
                                                              115,
                                                              239)))),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 0,
                                            child: isCreatedNewTag
                                                ? ListTile(
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

                                                          setState(() {});
                                                        },
                                                        icon: Icon(Icons.check,
                                                            size: 20,
                                                            color:
                                                                Colors.green)),
                                                    title: Container(
                                                      width: 200,
                                                      child: TextField(
                                                          controller:
                                                              _tagnamecontroller,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 18,
                                                          )),
                                                    ),
                                                  )
                                                : Container(
                                                    width: 300,
                                                    child: ElevatedButton.icon(
                                                        onPressed: () {
                                                          isCreatedNewTag =
                                                              true;
                                                          setState(() {});
                                                        },
                                                        icon: Icon(Icons.add,
                                                            size: 20,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    97,
                                                                    115,
                                                                    239)),
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
                                                        label: Text(
                                                            "Tạo nhãn mới",
                                                            style: TextStyle(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        97,
                                                                        115,
                                                                        239)))),
                                                  ),
                                          ),
                                          Expanded(
                                            flex: 0,
                                            child: Container(
                                              width: 300,
                                              child: ElevatedButton(
                                                  onPressed: () {
                                                    isCreatedNewTag = false;
                                                    Navigator.of(context)
                                                        .pop(tag);
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
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
                                                  child: Text("HUỶ")),
                                            ),
                                          )
                                        ],
                                      ),
                                    ));
                                  },
                                );
                              });
                        } else {
                          taglocal = await showDialog<TagModel>(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return Dialog(
                                        child: Container(
                                      margin: EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          const Center(
                                            child: Text(
                                              "Chọn nhãn",
                                              style: TextStyle(fontSize: 18),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 15,
                                          ),
                                          Expanded(
                                            flex: 0,
                                            child: TextField(
                                              style: const TextStyle(
                                                fontSize: 15,
                                              ),
                                              decoration: const InputDecoration(
                                                hintText: "Tìm kiếm nhãn...",
                                                prefixIcon: Icon(Icons.search),
                                              ),
                                              onChanged: (value) async {
                                                if (value == "") {
                                                  await EasyLoading.show(
                                                    status:
                                                        "Đang tải danh sách nhãn của bạn...",
                                                    maskType:
                                                        EasyLoadingMaskType
                                                            .none,
                                                  );


                                                  await EasyLoading.dismiss();
                                                } else {
                                                  await EasyLoading.show(
                                                    status: "Đang tìm kiếm...",
                                                    maskType:
                                                        EasyLoadingMaskType
                                                            .none,
                                                  );

                                                  await EasyLoading.dismiss();
                                                }

                                                setState(() {});
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            flex: 5,
                                            child: ListView.builder(
                                                itemBuilder: (context, index) {
                                                  return Container(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            10, 0, 10, 0),
                                                    child: ListTile(
                                                      leading: Icon(
                                                        Icons
                                                            .turned_in_outlined,
                                                        color: Color.fromARGB(
                                                            255, 251, 178, 37),
                                                        size: 22,
                                                      ),
                                                      trailing: Icon(
                                                        Icons.trip_origin,
                                                        color: Colors.grey,
                                                        size: 22,
                                                      ),
                                                      title: Text(
                                                        lsttagslocal[index]
                                                            .tag_name,
                                                        style: TextStyle(
                                                            fontSize: 18),
                                                      ),
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pop(lsttagslocal[
                                                                index]);
                                                      },
                                                    ),
                                                  );
                                                },
                                                itemCount: lsttagslocal.length),
                                          ),
                                          Expanded(
                                            flex: 0,
                                            child: Container(
                                              width: 300,
                                              child: ElevatedButton.icon(
                                                  onPressed: () {
                                                    Navigator.of(context)
                                                        .pop(null);
                                                  },
                                                  icon: Icon(Icons.close,
                                                      size: 20,
                                                      color: Color.fromARGB(
                                                          255, 97, 115, 239)),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    shape:
                                                        const StadiumBorder(),
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    shadowColor: Colors
                                                        .transparent
                                                        .withOpacity(0.1),
                                                    elevation: 0,
                                                    side: const BorderSide(
                                                      width: 1.0,
                                                      color: Color.fromARGB(
                                                          255, 97, 115, 239),
                                                    ),
                                                  ),
                                                  label: Text("Gỡ nhãn",
                                                      style: TextStyle(
                                                          color: Color.fromARGB(
                                                              255,
                                                              97,
                                                              115,
                                                              239)))),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 0,
                                            child: isCreatedNewTag
                                                ? ListTile(
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
                                                          setState(() {});
                                                        },
                                                        icon: Icon(Icons.check,
                                                            size: 20,
                                                            color:
                                                                Colors.green)),
                                                    title: Container(
                                                      width: 200,
                                                      child: TextField(
                                                          controller:
                                                              _tagnamecontroller,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 18,
                                                          )),
                                                    ),
                                                  )
                                                : Container(
                                                    width: 300,
                                                    child: ElevatedButton.icon(
                                                        onPressed: () {
                                                          isCreatedNewTag =
                                                              true;
                                                          setState(() {});
                                                        },
                                                        icon: Icon(Icons.add,
                                                            size: 20,
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    97,
                                                                    115,
                                                                    239)),
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
                                                        label: Text(
                                                            "Tạo nhãn mới",
                                                            style: TextStyle(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        97,
                                                                        115,
                                                                        239)))),
                                                  ),
                                          ),
                                          Expanded(
                                            flex: 0,
                                            child: Container(
                                              width: 300,
                                              child: ElevatedButton(
                                                  onPressed: () {
                                                    isCreatedNewTag = false;
                                                    Navigator.of(context)
                                                        .pop(taglocal);
                                                  },
                                                  style:
                                                      ElevatedButton.styleFrom(
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
                                                  child: Text("HUỶ")),
                                            ),
                                          )
                                        ],
                                      ),
                                    ));
                                  },
                                );
                              });
                        }
                        setState(() {});

                      },
                    ),
                  ],
                ),
              ),
            ));
  }

  Future<void> getTagsByID() async {
    lsttags = await FireStorageService().getAllTagsForShare(widget.email);

  }



  void getNoteById(String id) async {
    if (widget.isEdit) {
      noteContentList.clear();

      await EasyLoading.show(
        status: "Đang tải dữ liệu của ghi chú...",
        maskType: EasyLoadingMaskType.black,
      );

      note = await FireStorageService()
          .getNoteShareByIdForShare(widget.noteId, widget.email);
      _noteTitleController.text = note.title;

      tag!.tagname = note.tagname;

      currentDateTime = note.timeStamp;
      for (int i = 0; i < note.content.length; i++) {
        Map<String, dynamic> temp = note.content[i];
        if (temp.containsKey('local_image')) {
          bool exists = await File(temp["local_image"]).exists();
          if (exists) {
            noteContentList.add(File(temp['local_image']));
          }
        } else if (temp.containsKey('image')) {
          noteContentList.add(temp['image']);
        }

        if (temp.containsKey('text')) {
          TextEditingController controller = TextEditingController();
          FocusNode fcnode = FocusNode();

          controller.text = temp['text'];
          noteContentList.add(widget.rule == rules[0] ? textFieldWidgetViewOnly(controller, fcnode) : textFieldWidget(controller, fcnode));
        }
      }

    }

    await FireStorageService().updateCloudImageURLForShare(id, note.content, widget.email);
    setState(() {});

    await EasyLoading.dismiss();
  }

  Future<void> updateNote() async {

    note = await FireStorageService().getNoteShareByIdForShare(widget.noteId, widget.email);

    NoteContent noteContent = NoteContent();
    List<Map<String, dynamic>> imageText = [];
    for (int i = 0; i < noteContentList.length; i++) {
      if (noteContentList[i] is TextField) {
        TextField textField = noteContentList[i];
        imageText.add({'text': textField.controller?.text});
      } else if (noteContentList[i] is File) {
        bool exists = await File(noteContentList[i].path).exists();

        if (exists) {
          imageText.add({'local_image': noteContentList[i].path});
        }
      }
    }
    noteContent.timeStamp = currentDateTime; //Chỉnh thành ngày update
    noteContent.title = NoteTitle;
    noteContent.content = imageText;
    noteContent.tagname = tag == null || tag!.tagname == ""
        ? ""
        : tag!.tagname; //////SỬA LẠI TAGNAME Ở ĐÂY KHI LÀM PHẦN TAG
    //////SỬA LẠI TAGNAME Ở ĐÂY KHI LÀM PHẦN TAG
    /////////SỬA LẠI TAGNAME Ở ĐÂY KHI LÀM PHẦN TAG

    await FireStorageService().updateNoteByIdForShare(widget.noteId, noteContent, widget.email);

    late int index;
    if (isConnected) {
      StorageService().deleteListOnlineImage(note.content);

      for (int i = 0; i < noteContentList.length; i++) {
        if (noteContentList[i] is File) {
          String temp = await StorageService().uploadImage(noteContentList[i]);
          index = imageText.indexWhere(
              (element) => element["local_image"] == noteContentList[i].path);
          imageText.insert(index + 1, {'image': temp});
        }
      }

      noteContent.content = imageText;
      await FireStorageService().updateNoteByIdForShare(widget.noteId, noteContent, widget.email);
    }

    //Navigator.pop(appcontext);
  }
  

  Future<void> createTag() async {
    if (_tagnamecontroller.text.isNotEmpty) {
      await EasyLoading.show(
        status: "Đang tạo nhãn mới...",
        maskType: EasyLoadingMaskType.none,
      );

      Tag t = Tag();
      t.tagname = _tagnamecontroller.text;
      FireStorageService().saveTagsForShare(t, widget.email);

      lsttags = await FireStorageService().getAllTagsForShare(widget.email);

      await EasyLoading.dismiss();

      isCreatedNewTag = false;

      _tagnamecontroller.text = "";
    }
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
}