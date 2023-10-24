// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'dart:async';
import 'dart:io';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
import 'package:notemobileapp/test/services/firebase_firestore_service.dart';
import 'package:notemobileapp/test/services/firebase_store_service.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:speech_to_text/speech_to_text.dart';
import 'package:notemobileapp/DAL/UserDAL.dart';

import 'package:notemobileapp/DAL/NoteDAL.dart';
import 'package:notemobileapp/DAL/NoteContentDAL.dart';

import '../model/SqliteModel/NoteContentModel.dart';
import '../model/SqliteModel/NoteModel.dart';
import '../model/SqliteModel/initializeDB.dart';
import '../router.dart';
import '../test/services/internet_connection.dart';

class NewNoteScreen extends StatefulWidget {
  const NewNoteScreen({
    Key? key,
    required this.noteId,
    required this.isEdit,
    required this.email
  }) : super(key: key);

  final String noteId;
  final bool isEdit;

  final String? email;

  @override
  State<StatefulWidget> createState() {
    return NewNoteScreenState();
  }
}

class NewNoteScreenState extends State<NewNoteScreen> {
  late BuildContext appcontext;

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
  bool _showFab = true;
  bool _isElevated = true;
  bool _isVisible = true;
  bool _isBottomAppBarVisible = false;
  bool MicroIsListening = false;

  bool isEditCompleted = true;
  bool isConnected = false;
  late bool loginState;

  int vitrihinh = 0;

  late String NoteTitle = '';
  late String currentDateTime;
  late String firsttxtfieldcont;

  UserDAL uDAL = UserDAL();
  NoteDAL nDAL = NoteDAL();
  NoteContentDAL ncontentDAL = NoteContentDAL();

  FB_Note fb_note = FB_Note();
  FB_NoteContent fb_notect = FB_NoteContent();

  FloatingActionButtonLocation get _fabLocation => _isVisible
      ? FloatingActionButtonLocation.centerDocked
      : FloatingActionButtonLocation.centerFloat;

  NoteReceive note = NoteReceive();

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
    initializeDateFormatting();
    DateTime now = DateTime.now();
    currentDateTime = DateFormat.yMd('vi_VN').add_jm().format(now);

    checkLogin();

    if (widget.isEdit && widget.email == "") {
      loadingNoteWithIDAtLocal(-1, widget.noteId, widget.isEdit);
    }
    if(widget.isEdit && widget.email != ""){
      var temp = int.tryParse(widget.noteId);
      if(temp != null){
        loadingNoteWithIDAtLocal(-1, widget.noteId, widget.isEdit);
      }
      else{
        getNoteById(widget.noteId);
      }
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
          isConnected = _source.values.toList()[0] ? true : false ;
          break;
        case ConnectivityResult.wifi:
          isConnected = _source.values.toList()[0] ? true : false ;
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

  Future<bool> showAlertDialog(BuildContext context, String message, String alerttitle) async {
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

  Future loadingNoteWithIDAtLocal(int userid, String noteID, bool isEdit) async {
    List<NoteModel> tmp = await nDAL.getNoteByID(userid, int.parse(noteID), InitDataBase.db);
    if (tmp.isNotEmpty && isEdit) {
      _noteTitleController.text = tmp[0].title;
      currentDateTime = tmp[0].date_created;
      List<NoteContentModel> contents =
          await ncontentDAL.getAllNoteContentsById(InitDataBase.db, int.parse(noteID));
      if (contents.isNotEmpty) {
        firstTxtFieldController.text = contents[0].textcontent.toString();

        UpdateNoteModel firstupdtmodel = UpdateNoteModel(
            notecontent_id: contents[0].notecontent_id?.toInt() ?? 0,
            type: "update");

        lstupdatecontents.add(firstupdtmodel);
        //fcnFirstTxtField.requestFocus();

        if (contents.length >= 2) {
          for (int i = 1; i < contents.length; i++) {
            if (contents[i].textcontent != null) {
              FocusNode fcnTxtField = FocusNode();
              TextEditingController txtFieldController =
                  TextEditingController();
              Widget txtfield = TextField(
                keyboardType: TextInputType.multiline,
                focusNode: fcnTxtField,
                controller: txtFieldController,
                showCursor: true,
                //autofocus: true,
                maxLines: null,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(border: InputBorder.none),
              );
              txtFieldController.text = contents[i].textcontent.toString();
              lstFocusNode.add(fcnTxtField);
              lstTxtController.add(txtFieldController);
              noteContentList.add(txtfield);

              UpdateNoteContentList.add(txtFieldController);

              UpdateNoteModel updtmodel = UpdateNoteModel(
                  notecontent_id: contents[i].notecontent_id?.toInt() ?? 0,
                  type: "update");

              lstupdatecontents.add(updtmodel);
            }
            if (contents[i].imagecontent != null) {
              File img = File(contents[i].imagecontent.toString());

              noteContentList.add(img);
              UpdateNoteContentList.add(img);

              UpdateNoteModel updtmodel = UpdateNoteModel(
                  notecontent_id: contents[i].notecontent_id?.toInt() ?? 0,
                  type: "update");

              lstupdatecontents.add(updtmodel);
            }
          }
        }
        setState(() {});
      }
    }
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
    List<Map<String, dynamic>> CloudContents = [];

    firsttxtfieldcont = SaveNoteContentList[0].text;
    File file;
    String urlImageCloud;

    for (int i = 0; i < SaveNoteContentList.length; i++) {
      if (SaveNoteContentList[i] is File) {
        // String imageName = basename(SaveNoteContentList[i].path);
         file = File(SaveNoteContentList[i].path);
         urlImageCloud = await StorageService().uploadImage(file)    ;
        CloudContents.add({'image': urlImageCloud});
        CloudContents.add({'local_image' : SaveNoteContentList[i].path});
      } else {

        String noiDungGhiChu = SaveNoteContentList[i].text;
        CloudContents.add({'text': noiDungGhiChu});
      }
    }
    noteContent.timeStamp = currentDateTime;
    noteContent.title = NoteTitle;
    noteContent.content = CloudContents;
    noteContent.tagname = "";                  //////SỬA LẠI TAGNAME Ở ĐÂY KHI LÀM PHẦN TAG
    //////SỬA LẠI TAGNAME Ở ĐÂY KHI LÀM PHẦN TAG
    /////////SỬA LẠI TAGNAME Ở ĐÂY KHI LÀM PHẦN TAG
    await FireStorageService().saveContentNotes(noteContent);
    //Navigator.pop(appcontext);
  }

  Future<void> saveNoteToLocal() async {
    //SUA LAI USER ID O DAY
    //SUA LAI USER ID O DAY
    //SUA LAI USER ID O DAY
    //SUA LAI USER ID O DAY
    //SUA LAI USER ID O DAY
    NoteModel md = NoteModel(
        title: NoteTitle, date_created: currentDateTime, user_id: -1);
    bool checkinsertnote =
        await nDAL.insertNote(md, -1, InitDataBase.db).catchError(
      (Object e, StackTrace stackTrace) {
        debugPrint(e.toString());
      },
    );
    if (checkinsertnote) {
      int latestid = await ncontentDAL.getLatestNoteID(InitDataBase.db).catchError(
        (Object e, StackTrace stackTrace) {
          debugPrint(e.toString());
        },
      );
      for (int i = 0; i < SaveNoteContentList.length; i++) {
        if (SaveNoteContentList[i] is File) {
          // getting a directory path for saving
          // final Directory directory = await getApplicationDocumentsDirectory();

          // String imagename = basename(SaveNoteContentList[i].path);

          // copy the file to a new path
          // final File newImage = await File(SaveNoteContentList[i].path)
          //     .copy('$path/image/$imagename')
          //     .catchError(
          //   (Object e, StackTrace stackTrace) {
          //     debugPrint(e.toString());
          //   },
          // );

          NoteContentModel conmd = NoteContentModel(
              notecontent_id: null,
              textcontent: null,
              imagecontent: SaveNoteContentList[i].path,
              note_id: latestid);

          bool checkinsertnotecontent = await ncontentDAL
              .insertNoteContent(conmd, InitDataBase.db)
              .catchError(
            (Object e, StackTrace stackTrace) {
              debugPrint(e.toString());
            },
          );

          if (checkinsertnotecontent) {
            debugPrint('insert noi dung ghi chu thanh cong');
          } else {
            debugPrint('loi insert noi dung ghi chu');
          }
        } else {
          String noiDungGhiChu = SaveNoteContentList[i].text;
          NoteContentModel conmd = NoteContentModel(
              notecontent_id: null,
              textcontent: noiDungGhiChu,
              imagecontent: null,
              note_id: latestid);

          bool checkinsertnotecontent = await ncontentDAL
              .insertNoteContent(conmd, InitDataBase.db)
              .catchError(
            (Object e, StackTrace stackTrace) {
              debugPrint(e.toString());
            },
          );

          if (checkinsertnotecontent) {
            debugPrint('insert noi dung ghi chu thanh cong');
          } else {
            debugPrint('loi insert noi dung ghi chu');
          }
        }
      }
    } else {
      debugPrint('loi insert note');
    }


    //List<NoteModel> lstnotemodel = await nDAL.getAllNotes(InitDataBase.db);
    //List<NoteContentModel> lstnotecontent = await ncontentDAL.getAllNoteContentsById(InitDataBase.db, 1);
  }

  Future<void> updateNoteToLocal() async {
    bool updttitle = await nDAL.updateNoteTitle(
        int.parse(widget.noteId), _noteTitleController.text, InitDataBase.db);
    if (updttitle) {
      debugPrint("cap nhat tieu de ghi chu thanh cong");
    } else {
      debugPrint("xay ra loi khi cap nhat tieu de ghi chu");
    }
    for (int i = 0; i < lstupdatecontents.length; i++) {
      if (lstupdatecontents[i].type == "update") {
        if (UpdateNoteContentList[i] is File) {
          String imgpath = UpdateNoteContentList[i].path;
          bool isSuccess = await ncontentDAL.updateContentByID(
              lstupdatecontents[i].notecontent_id?.toInt() ?? 0,
              null,
              imgpath,
              InitDataBase.db);
        } else {
          String txt = UpdateNoteContentList[i].text;
          bool isSuccess = await ncontentDAL.updateContentByID(
              lstupdatecontents[i].notecontent_id?.toInt() ?? 0,
              txt,
              null,
              InitDataBase.db);
        }
      }
      if (lstupdatecontents[i].type == "insert_img") {
        // final Directory directory = await getApplicationDocumentsDirectory();
        // String drpath = directory.path;

        String imgpath = UpdateNoteContentList[i].path;
        // String imagename = basename(imgpath);

        // final File newImage =
        //     await File(imgpath).copy('$drpath/image/$imagename').catchError(
        //   (Object e, StackTrace stackTrace) {
        //     debugPrint(e.toString());
        //   },
        // );

        NoteContentModel conmd = NoteContentModel(
            notecontent_id: null,
            textcontent: null,
            imagecontent: imgpath,
            note_id: int.parse(widget.noteId)
        );

        bool checkinsertimgnotecontent = await ncontentDAL
            .insertNoteContent(conmd, InitDataBase.db)
            .catchError(
          (Object e, StackTrace stackTrace) {
            debugPrint(e.toString());
          },
        );

        if (checkinsertimgnotecontent) {
          debugPrint('insert hinh moi khi edit ghi chu thanh cong');
        } else {
          debugPrint('loi insert hinh moi khi edit ghi chu');
        }
      }
      if (lstupdatecontents[i].type == "insert_text") {
        NoteContentModel conmd = NoteContentModel(
            notecontent_id: null,
            textcontent: UpdateNoteContentList[i].text,
            imagecontent: null,
            note_id: int.parse(widget.noteId)
        );

        bool checkinsertnotecontent = await ncontentDAL
            .insertNoteContent(conmd, InitDataBase.db)
            .catchError(
          (Object e, StackTrace stackTrace) {
            debugPrint(e.toString());
          },
        );

        if (checkinsertnotecontent) {
          debugPrint('insert text moi khi edit ghi chu thanh cong');
        } else {
          debugPrint('loi insert text moi khi edit ghi chu');
        }
      }
    }

    for (int i = 0; i < lstdeletecontents.length; i++) {
      bool checkdel = await ncontentDAL.deleteNoteContentsByID(
          lstdeletecontents[i].notecontent_id?.toInt() ?? 0, InitDataBase.db);
      if (checkdel) {
        debugPrint("Xoa text field hoac img sau khi edit thanh cong");
      } else {
        debugPrint("Xoa text field hoac img sau khi edit xay ra loi!!");
      }
    }
  }

  Future<void> deleteNoteAtLocal() async{
    bool isSuccess = await nDAL.deleteNote(int.parse(widget.noteId), InitDataBase.db);
    if(isSuccess == false){
      debugPrint("Xoa note xay ra loi!!!!!!");
    }
  }

  Widget buildImageWidget(BuildContext context, int index) {
    Widget imageWidget = Stack(children: [
      noteContentList[index] is String ?
      Image.network(
        noteContentList[index],
        width: 350,
        height: 250,
        fit: BoxFit.cover,
      ) :
      Image.file(
        noteContentList[index]!,
        width: 350,
        height: 250,
        fit: BoxFit.cover,
      ),

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
                      if(loginState){

                      }
                      else{
                        UpdateNoteContentList.removeAt(index);

                        UpdateNoteModel delmodel = UpdateNoteModel(
                            notecontent_id: lstupdatecontents[index].notecontent_id,
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
                  if(loginState){
                    if (noteContentList[index] is TextField) {
                      if (noteContentList[index].controller?.text == "") {
                        //XOA TEXT FIELD NGAY SAU HINH NEU TEXT FIELD TRONG KHI EDIT GHI CHU
                        noteContentList.removeAt(index);
                      }
                    }
                  }
                  else{
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
              }))
    ]);
    return imageWidget;
  }

  //final QuillController _quillController = QuillController.basic();

  @override
  Widget build(BuildContext context) {
    appcontext = context;
    return SafeArea(
        child: Scaffold(
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
                      setState(() {
                      });
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
                      if(widget.email != ""){
                        await updateNote().whenComplete(() => Navigator.of(context).pop('RELOAD_LIST'));
                      }
                      else{
                        updateNoteToLocal();
                        Navigator.of(context).pop('RELOAD_LIST');
                      }
                      //updateNoteToLocal();
                      
                      //Navigator.push(context, MaterialPageRoute(builder: (context) => const ToDoPage()));
                    },
                  ),
                //Icon(null)
                if (widget.isEdit == false)
                  IconButton(
                    icon: const Icon(
                      Icons.check,
                    ),
                    onPressed: () {
                      if(widget.email != ""){
                        uploadNoteToCloud().whenComplete(() => Navigator.of(context).pop('RELOAD_LIST'));
                      }
                      else{
                        saveNoteToLocal();
                        Navigator.of(context).pop('RELOAD_LIST');
                      }
                      //saveNoteToLocal();
                      // Navigator.of(context).pop('RELOAD_LIST');
                    },
                  )
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
                    hintText: 'Tiêu đề ghi chú',
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
                  child: Text(
                    'Ngày giờ tạo: ' + currentDateTime,
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                ),
                Expanded(
                    child: ListView.separated(
                        controller: _controller,
                        itemCount: noteContentList.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (noteContentList[index] is String || noteContentList[index] is File) {
                            return buildImageWidget(context, index);
                          } else {
                            return noteContentList[index];
                          }
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider())),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: widget.isEdit && (isEditCompleted == true)
                        ? Row(
                            children: [
                              Expanded(flex: 1, child: SizedBox()),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {},
                                        child: const Icon(
                                          Icons.share,
                                          size: 20.0,
                                        ),
                                        style: ButtonStyle(
                                          padding: MaterialStateProperty.all(
                                              EdgeInsets.zero),
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Color.fromARGB(
                                                      255, 97, 115, 239)),
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          if(widget.email != ""){
                                            bool deleteornot = await showAlertDialog(context, 
                                                                "Bạn có muốn xoá ghi chú này không?", 
                                                                "Xoá ghi chú"
                                            );
                                            if(deleteornot){
                                              await deleteNote();
                                            }
                                          }
                                          else{
                                            bool deleteornot = await showAlertDialog(context, 
                                                                "Bạn có muốn xoá ghi chú này không?", 
                                                                "Xoá ghi chú"
                                            );
                                            if(deleteornot){
                                              deleteNoteAtLocal();
                                            }
                                          }
                                          Navigator.pop(context, true);
                                        },
                                        child: const Icon(
                                          Icons.delete,
                                          size: 20.0,
                                        ),
                                        style: ButtonStyle(
                                          padding: MaterialStateProperty.all(
                                              EdgeInsets.zero),
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Color.fromARGB(
                                                      255, 97, 115, 239)),
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(flex: 1, child: SizedBox()),
                            ],
                          )
                        : null)
              ]),

              //  child: Column(
              //   children: <Widget>[

              //     Expanded(
              //       child: ListView(
              //         controller: _controller,
              //         children: items.toList(),
              //       ),
              //     ),
              //   ],
              // ),
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
                      // child: FloatingActionButton(
                      //   onPressed: (){},
                      //   tooltip: 'Nhận diện giọng nói',
                      //   elevation: _isVisible ? 0.0 : null,
                      //   child: const Icon(Icons.mic),
                      // ),
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
                        // final SnackBar snackBar = SnackBar(
                        //   content: const Text('Yay! A SnackBar!'),
                        //   action: SnackBarAction(
                        //     label: 'Undo',
                        //     onPressed: () {},
                        //   ),
                        // );

                        // Find the ScaffoldMessenger in the widget tree
                        // and use it to show a SnackBar.
                        //ScaffoldMessenger.of(context).showSnackBar(snackBar);

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
                      icon: const Icon(Icons.turned_in_not_outlined),
                      onPressed: () {
                        Navigator.of(context).pushNamed(RoutePaths.test);
                      },
                    ),
                  ],
                ),
              ),
            ))

        //  child: Column(
        //   children: <Widget>[

        //     Expanded(
        //       child: ListView(
        //         controller: _controller,
        //         children: items.toList(),
        //       ),
        //     ),
        //   ],
        // ),
        );
    // return Scaffold(
    //   appBar: AppBar(
    //     centerTitle: true,
    //     title: text_default.Text('Tạo ghi chú'),
    //   ),
    //   body: Column(
    //     children: [
    //       QuillToolbar.basic(
    //         controller: _quillController,
    //         customButtons: [
    //           QuillCustomButton(
    //               icon: Icons.image,
    //               onTap: () {
    //                 _insertImage();
    //               }),
    //         ],
    //       ),
    //       QuillEditor.basic(controller: _quillController, readOnly: false, padding: EdgeInsets.all(8.0),),
    //     ],
    //   ),
    // );


  }


  void getNoteById(String id) async {
    if (widget.isEdit) {
      noteContentList.clear();
      note = await FireStorageService().getNoteById(widget.noteId);
      _noteTitleController.text = note.title;
        currentDateTime = note.timeStamp;
        for (var element in note.content) {
          Map<String, dynamic> temp = element;
          if(temp.containsKey('local_image')){
            bool exists = await File(temp["local_image"]).exists();
            if(exists){
               noteContentList.add(File(temp['local_image']));
            }
          }
          if(temp.containsKey('text')){
            TextEditingController controller = TextEditingController();
            FocusNode fcnode = FocusNode();

            controller.text = temp['text'];
            noteContentList.add(textFieldWidget(controller, fcnode));
          }
        }
      setState(() {
        
      });
    }
  }

  Future<void> updateNote() async {
    // showDialog(
    //     context: appcontext,
    //     builder: (context) {
    //       return Center(
    //         child: CircularProgressIndicator(),
    //       );
    //     });

    note = await FireStorageService().getNoteById(widget.noteId);
    StorageService().deleteListOnlineImage(note.content);

    NoteContent noteContent = NoteContent();
    List<Map<String, dynamic>> imageText = [];
    for (int i = 0; i < noteContentList.length; i++) {
      if (noteContentList[i] is TextField) {
        TextField textField = noteContentList[i];
        imageText.add({'text': textField.controller?.text});
      } else if (noteContentList[i] is File) {
        bool exists = await File(noteContentList[i].path).exists();

        if(exists){
          String temp = await StorageService().uploadImage(noteContentList[i]);
          imageText.add({'image': temp});
          imageText.add({'local_image': noteContentList[i].path});
        }
      }
    }
    noteContent.timeStamp = currentDateTime; //Chỉnh thành ngày update
    noteContent.title = NoteTitle;
    noteContent.content = imageText;
    noteContent.tagname = "";                     //////SỬA LẠI TAGNAME Ở ĐÂY KHI LÀM PHẦN TAG
    //////SỬA LẠI TAGNAME Ở ĐÂY KHI LÀM PHẦN TAG
    /////////SỬA LẠI TAGNAME Ở ĐÂY KHI LÀM PHẦN TAG
    await FireStorageService().updateNoteById(widget.noteId, noteContent);
    //Navigator.pop(appcontext);
  }

  Future<void> deleteNote() async {
    StorageService().deleteListImage(note.content);
    await FireStorageService().deleteNoteById(widget.noteId);
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
