// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'dart:async';
import 'dart:io';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';

//import 'package:flutter_quill/flutter_quill.dart' hide Text;

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
import '../test/notifi_service.dart';
import '../test/services/internet_connection.dart';
import '../test/ttspeech_config.dart';

class NewNoteScreen extends StatefulWidget {
  const NewNoteScreen(
      {
      Key? key,
      required this.noteId,
      required this.isEdit,
      required this.email,
      })
      : super(key: key);

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
  //late stt.SpeechToText _speech;
  bool _isListening = false;
  double _confidence = 1.0;
  bool loading = false;
  bool isEditCompleted = true;

  SpeechToText speechToText = SpeechToText();

  static FocusNode fcnFirstTxtField = FocusNode();
  static TextEditingController firstTxtFieldController =
      TextEditingController();

    
  List<dynamic> noteContentList = <dynamic>[
    
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


  bool isConnected = false;
  bool isCreatedNewTag = false;

  bool loginState = false;

  int vitrihinh = 0;

  late String NoteTitle = '';
  late Timestamp currentDateTime;
  late String currentDateTimeShow;
  late String firsttxtfieldcont;

  UserDAL uDAL = UserDAL();
  NoteDAL nDAL = NoteDAL();
  NoteContentDAL ncontentDAL = NoteContentDAL();
  TagDAL tagDAL = TagDAL();

  FB_Note fb_note = FB_Note();
  FB_NoteContent fb_notect = FB_NoteContent();

  FloatingActionButtonLocation get _fabLocation => FloatingActionButtonLocation.centerFloat;

  NoteReceive note = NoteReceive();
  TagReceive? tag;
  TagModel? taglocal;

  List<TagReceive> lsttags = [];
  List<TagModel> lsttagslocal = [];

  late StreamSubscription subscription;

  Map _source = {ConnectivityResult.none: false};
  final NetworkConnectivity _networkConnectivity = NetworkConnectivity.instance;


  DateTime scheduleTime = DateTime.now();
  Duration durationTime = const Duration();
  FlutterTts flutterTts = FlutterTts();

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
    DateTime dateTime = DateTime.now();

    String day = dateTime.day.toString();
    String month = dateTime.month.toString();
    String year = dateTime.year.toString();
    String hour = dateTime.hour.toString()..padLeft(2, '0');
    String minute = dateTime.minute.toString().padLeft(2, '0');
    currentDateTimeShow = '$day/$month/$year $hour:$minute';
    currentDateTime = Timestamp.fromDate(dateTime);

    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.chasingDots
      ..loadingStyle = EasyLoadingStyle.dark;

    //_speech = stt.SpeechToText();
    
    checkLogin();
    CheckInternetConnection();

    noteContentList.add(
      TextField(
        keyboardType: TextInputType.multiline,
        focusNode: fcnFirstTxtField,
        controller: firstTxtFieldController,
        enabled: isEditCompleted == false  || widget.isEdit == false ? true : false,
        showCursor: true,
        autofocus: true,
        maxLines: null,
        style: const TextStyle(fontSize: 14),
        decoration: const InputDecoration(border: InputBorder.none),
      )
    );

    if (widget.isEdit && widget.email == "") {
      loadingNoteWithIDAtLocal(-1, widget.noteId, widget.isEdit);
    }
    if (widget.isEdit && widget.email != "") {
      var temp = int.tryParse(widget.noteId);
      if (temp != null) {
        loadingNoteWithIDAtLocal(-1, widget.noteId, widget.isEdit);
      } else {
        getNoteById(widget.noteId);
      }
    }

    if (widget.email != "") {
      getTagsByID();
    } else {
      getTagsAtLocal();
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
    final imageFromCache =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (imageFromCache != null) {
      final File fileCache = File(imageFromCache.path);

      final directory = await getApplicationDocumentsDirectory();
      String pathAppDoc = directory.path;

      String destinationPath = '$pathAppDoc/${fileCache.uri.pathSegments.last}';
      await fileCache.copy(destinationPath);

      final imageTemp = File(destinationPath);

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
      fileCache.delete();
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

  Future loadingNoteWithIDAtLocal(int userid, String noteID, bool isEdit) async {
    List<NoteModel> tmp =
        await nDAL.getNoteByID(userid, int.parse(noteID), InitDataBase.db);
    if (tmp.isNotEmpty && isEdit) {
      _noteTitleController.text = tmp[0].title;
      currentDateTime = tmp[0].convertDateCreate();

      taglocal!.tag_id = tmp[0].tag_id?.toInt() ?? null;
      taglocal!.tag_name = tmp[0].tag_name?.toString() ?? "";

      List<NoteContentModel> contents = await ncontentDAL.getAllNoteContentsById(InitDataBase.db, int.parse(noteID));

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
                enabled: isEditCompleted == false  || isEdit == false ? true : false,
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

    String noteid = await FireStorageService().saveContentNotes(noteContent);

    if (isConnected) {
      for (int i = 0; i < SaveNoteContentList.length; i++) {
        if (SaveNoteContentList[i] is File) {
          file = File(SaveNoteContentList[i].path);
          urlImageCloud = await StorageService().uploadImage(file);
          // CloudContents.insert(i + 1, {'image': urlImageCloud});
          CloudContents[i].addAll({'image': urlImageCloud});
        }
      }

      await FireStorageService().updateCloudImageURL(noteid, CloudContents);
    }
  }

  Future<void> saveNoteToLocal() async {
    //SUA LAI USER ID O DAY
    //SUA LAI USER ID O DAY
    //SUA LAI USER ID O DAY
    //SUA LAI USER ID O DAY
    //SUA LAI USER ID O DAY
    late NoteModel md;
    if (taglocal == null) {
      md = NoteModel(
          title: NoteTitle,
          date_created: currentDateTime.millisecondsSinceEpoch,
          user_id: -1);
    } else {
      md = NoteModel(
          title: NoteTitle,
          date_created: currentDateTime.millisecondsSinceEpoch,
          user_id: -1,
          tag_id: taglocal!.tag_id);
    }

    bool checkinsertnote =
        await nDAL.insertNote(md, -1, InitDataBase.db).catchError(
      (Object e, StackTrace stackTrace) {
        debugPrint(e.toString());
      },
    );
    if (checkinsertnote) {
      int latestid =
          await ncontentDAL.getLatestNoteID(InitDataBase.db).catchError(
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

    bool updtag = await nDAL.updateTagInNote(
        int.parse(widget.noteId), taglocal, InitDataBase.db);

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
            note_id: int.parse(widget.noteId));

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
            note_id: int.parse(widget.noteId));

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

  Future<void> deleteNoteAtLocal() async {
    bool isSuccess =
        await nDAL.deleteNote(int.parse(widget.noteId), InitDataBase.db);
    if (isSuccess == false) {
      debugPrint("Xoa note xay ra loi!!!!!!");
    }

    setState(() {
      
    });
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
      
      widget.isEdit == true && isEditCompleted == false ?

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
                }
                setState(() {});
              }
            )
      )

      :
      const SizedBox()
    ]);
    return imageWidget;
  }

  //final QuillController _quillController = QuillController.basic();

  @override
  Widget build(BuildContext context) {
    appcontext = context;
    return SafeArea(
        child: Stack(children: [
      Scaffold(
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
                    if(loginState){
                      getNoteById(widget.noteId);
                    }
                    else{
                      noteContentList.clear();

                      noteContentList.add(
                        TextField(
                          keyboardType: TextInputType.multiline,
                          focusNode: fcnFirstTxtField,
                          controller: firstTxtFieldController,
                          enabled: isEditCompleted == false  || widget.isEdit == false ? true : false,
                          showCursor: true,
                          autofocus: true,
                          maxLines: null,
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(border: InputBorder.none),
                        )
                      );

                      lstupdatecontents.clear();
                      lstFocusNode.clear();
                      lstTxtController.clear();
                      UpdateNoteContentList.clear();

                      lstFocusNode.add(fcnFirstTxtField);
                      lstTxtController.add(firstTxtFieldController);
                      UpdateNoteContentList.add(firstTxtFieldController);

                      loadingNoteWithIDAtLocal(-1, widget.noteId, widget.isEdit);
                    }

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
                      await EasyLoading.show(
                        status: "Đang cập nhật ghi chú...",
                        maskType: EasyLoadingMaskType.black,
                      );

                      updateNote();

                      await EasyLoading.dismiss();

                      Navigator.of(context).pop('RELOAD_LIST');
                    } else {
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
                  onPressed: () async {
                    if (widget.email != "") {
                      await EasyLoading.show(
                        status: "Đang tạo ghi chú...",
                        maskType: EasyLoadingMaskType.black,
                      );

                      uploadNoteToCloud();

                      await EasyLoading.dismiss();
                      
                      Navigator.of(context).pop('RELOAD_LIST');
                    } else {
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
                enabled: isEditCompleted == false  || widget.isEdit == false ? true : false,
                autofocus: false,
                style:
                    const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
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
                                        color:
                                            Color.fromARGB(255, 97, 115, 239)),
                                  )
                                : Text(
                                    taglocal == null || taglocal!.tag_name == ""
                                        ? "Chưa có nhãn"
                                        : taglocal!.tag_name,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color:
                                            Color.fromARGB(255, 97, 115, 239)),
                                  ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Ngày tạo: $currentDateTimeShow',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
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
              Align(
                  alignment: Alignment.bottomCenter,
                  child: widget.isEdit && (isEditCompleted == true)
                      ? Row(
                          children: [
                            loginState ? Expanded(flex: 1, child: SizedBox()) : SizedBox(width: 0,height: 0,),
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: 
                                    loginState ? 

                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ShareNoteUser(
                                                        noteId:
                                                            widget.noteId)));
                                      },
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
                                    )

                                    :

                                    SizedBox()
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        if (widget.email != "") {
                                          bool deleteornot = await showAlertDialog(
                                              context,
                                              "Bạn có muốn xoá ghi chú này không?",
                                              "Xoá ghi chú");
                                          if (deleteornot) {
                                            setState(() {
                                              loading = true;
                                            });
                                            await deleteNote();
                                            Navigator.pop(context, true);
                                          }
                                        } else {
                                          bool deleteornot = await showAlertDialog(
                                              context,
                                              "Bạn có muốn xoá ghi chú này không?",
                                              "Xoá ghi chú");
                                          if (deleteornot) {
                                            await deleteNoteAtLocal();
                                            Navigator.of(context).pop('RELOAD_LIST');
                                          }
                                        }
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
          floatingActionButton:
              (isEditCompleted == false) || widget.isEdit == false
                  ? AvatarGlow(
                      animate: MicroIsListening,
                      glowColor: Colors.deepOrange,
                      repeat: true,
                      // child: FloatingActionButton(
                      //   onPressed: () {
                      //     _listenVoice();
                      //   },
                      //   child: Icon(_isListening ? Icons.mic : Icons.mic_none),
                      // ),
                      child: GestureDetector(
                        onTapDown: (details) async {
                          var available = await speechToText.initialize();
                          var vitri;
                          if (available) {
                            MicroIsListening = true;
                            setState(() {
                              speechToText.listen(onResult: (result) {
                                for (var i = 0; i < lstFocusNode.length; i++) {
                                    if (lstFocusNode[i].hasFocus) {
                                      vitri = i;
                                      break;
                                    }
                                }

                                  lstTxtController[vitri].text = result.recognizedWords;
                                  if (vitri == 0) {
                                    firsttxtfieldcont = result.recognizedWords;
                                  }

                                  if (result.hasConfidenceRating && result.confidence > 0) {
                                    _confidence = result.confidence;
                                  }

                                MicroIsListening = false;
                                setState(() {
                                  // if (result.finalResult) {
                                  //   String doanvannoi = result.recognizedWords;
                                  //   lstTxtController[vitri].text += doanvannoi;
                                  //   if (vitri == 0) {
                                  //     firsttxtfieldcont = doanvannoi;
                                  //   }
                                  //   MicroIsListening = false;
                                  // }
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
            child:

            BottomAppBar(
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
                    onPressed: () {
                      // Navigator.pushNamed(context, RoutePaths.temp);

                      DatePicker.showDateTimePicker(
                        context,
                        showTitleActions: true,
                        onChanged: (date) => {scheduleTime = date},
                        onConfirm: (date) {
                          String hour = timeSchedule().inHours.toString();
                          String minute = timeSchedule().inMinutes.toString();
                          String second = timeSchedule().inSeconds.toString();
                          Fluttertoast.showToast(
                              msg: "Đã đặt thông báo nhắc nhở sau $hour giờ $minute phút $second giây",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0);

                          NotificationService().scheduleNotification(
                              title: 'Scheduled Notification',
                              body: '$scheduleTime',
                              scheduledNotificationDateTime: scheduleTime);

                          Future.delayed(
                              scheduleTime.difference(DateTime.now().add(const Duration(seconds: -1))),
                                  () async => {
                                configTextToSpeech(flutterTts),
                                flutterTts.speak('Bạn có ghi chú ${_noteTitleController.text} cần xem lại!'),
                              });

                        },
                      );
                    },
                  ),
                  // IconButton(
                  //   tooltip: 'Định dạng chữ',
                  //   color: Colors.white,
                  //   icon: const Icon(Icons.abc),
                  //   onPressed: () {},
                  // ),
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
                                                      EasyLoadingMaskType.none,
                                                );
                                                lsttags =
                                                    await FireStorageService()
                                                        .getAllTags();

                                                await EasyLoading.dismiss();
                                              } else {
                                                await EasyLoading.show(
                                                  status: "Đang tìm kiếm...",
                                                  maskType:
                                                      EasyLoadingMaskType.none,
                                                );
                                                lsttags = lsttags
                                                    .where((element) => element
                                                        .tagname
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
                                          child: 
                                          lsttags.isNotEmpty || lsttagslocal.isNotEmpty
                                          ?
                                          ListView.builder(
                                              itemBuilder: (context, index) {
                                                return Container(
                                                  padding: EdgeInsets.fromLTRB(
                                                      10, 0, 10, 0),
                                                  child: ListTile(
                                                    leading: Icon(
                                                      Icons.turned_in_outlined,
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
                                                          .pop(lsttags[index]);
                                                    },
                                                  ),
                                                );
                                              },
                                              itemCount: lsttags.length
                                          )
                                        
                                          :

                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              const Image(
                                                image: AssetImage('images/tag.png'),
                                                width: 140,
                                                height: 140,
                                                fit: BoxFit.cover,
                                                
                                              ),
                                              const SizedBox(height: 20,),
                                              Container(
                                                margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                                child: const Text("Không có nhãn nào, hãy tạo nhãn mới nào!")
                                              ),
                                            ],
                                          )
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
                                                style: ElevatedButton.styleFrom(
                                                  shape: const StadiumBorder(),
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
                                                          color: Colors.green)),
                                                  title: Container(
                                                    width: 200,
                                                    child: TextField(
                                                        controller:
                                                            _tagnamecontroller,
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                        )),
                                                  ),
                                                )
                                              : Container(
                                                  width: 300,
                                                  child: ElevatedButton.icon(
                                                      onPressed: () {
                                                        isCreatedNewTag = true;
                                                        setState(() {});
                                                      },
                                                      icon: Icon(Icons.add,
                                                          size: 20,
                                                          color: Color.fromARGB(
                                                              255,
                                                              97,
                                                              115,
                                                              239)),
                                                      style: ElevatedButton
                                                          .styleFrom(
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
                                                style: ElevatedButton.styleFrom(
                                                  shape: const StadiumBorder(),
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
                                                      EasyLoadingMaskType.none,
                                                );
                                                lsttagslocal = await tagDAL
                                                    .getAllTagsByUserID(
                                                        -1, InitDataBase.db);

                                                await EasyLoading.dismiss();
                                              } else {
                                                await EasyLoading.show(
                                                  status: "Đang tìm kiếm...",
                                                  maskType:
                                                      EasyLoadingMaskType.none,
                                                );
                                                lsttagslocal = lsttagslocal
                                                    .where((element) => element
                                                        .tag_name
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
                                                  padding: EdgeInsets.fromLTRB(
                                                      10, 0, 10, 0),
                                                  child: ListTile(
                                                    leading: Icon(
                                                      Icons.turned_in_outlined,
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
                                                      Navigator.of(context).pop(
                                                          lsttagslocal[index]);
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
                                                style: ElevatedButton.styleFrom(
                                                  shape: const StadiumBorder(),
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
                                                        createTagAtLocal();

                                                        lsttagslocal = await tagDAL
                                                            .getAllTagsByUserID(
                                                                -1,
                                                                InitDataBase
                                                                    .db);

                                                        setState(() {});
                                                      },
                                                      icon: Icon(Icons.check,
                                                          size: 20,
                                                          color: Colors.green)),
                                                  title: Container(
                                                    width: 200,
                                                    child: TextField(
                                                        controller:
                                                            _tagnamecontroller,
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                        )),
                                                  ),
                                                )
                                              : Container(
                                                  width: 300,
                                                  child: ElevatedButton.icon(
                                                      onPressed: () {
                                                        isCreatedNewTag = true;
                                                        setState(() {});
                                                      },
                                                      icon: Icon(Icons.add,
                                                          size: 20,
                                                          color: Color.fromARGB(
                                                              255,
                                                              97,
                                                              115,
                                                              239)),
                                                      style: ElevatedButton
                                                          .styleFrom(
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
                                                style: ElevatedButton.styleFrom(
                                                  shape: const StadiumBorder(),
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
          )),
      loading
          ? Container(
              color: Colors.black.withOpacity(0.5), // Màn hình mờ
              child: Center(child: CircularProgressIndicator()))
          : SizedBox(
              height: 0,
              width: 0,
            )
    ]));
  }

  void _listenVoice() async {
    // if (!_isListening) {
    //   bool available = await _speech.initialize(
    //     onStatus: (value) => print('onStatus: $value'),
    //     onError: (value) => print('onError: $value'),
    //   );

    //   if (available) {
    //     setState(() => _isListening = true);
    //     _speech.listen(
    //         onResult: (value) => setState(() {
    //               int vitri = 0;
    //               for (var i = 0; i < lstFocusNode.length; i++) {
    //                 if (lstFocusNode[i].hasFocus) {
    //                   vitri = i;
    //                   break;
    //                 }
    //               }

    //               lstTxtController[vitri].text = value.recognizedWords;
    //               if (vitri == 0) {
    //                 firsttxtfieldcont = value.recognizedWords;
    //               }

    //               if (value.hasConfidenceRating && value.confidence > 0) {
    //                 _confidence = value.confidence;
    //               }
    //             }));
    //   }
    // } else {
    //   setState(() => _isListening = false);
    //   _speech.stop();
    // }
  }

  Future<void> getTagsByID() async {
    lsttags = await FireStorageService().getAllTags();
    // TagReceive inserttag = TagReceive();
    // inserttag.tagname = "";
    // inserttag.tagid = "";
    // lsttags!.add(inserttag);
  }

  Future<void> getTagsAtLocal() async {
    lsttagslocal = await tagDAL.getAllTagsByUserID(-1, InitDataBase.db);
    // TagReceive inserttag = TagReceive();
    // inserttag.tagname = "";
    // inserttag.tagid = "";
    // lsttags!.add(inserttag);
  }

  void getNoteById(String id) async {
    if (widget.isEdit) {
      noteContentList.clear();

      await EasyLoading.show(
        status: "Đang tải dữ liệu của ghi chú...",
        maskType: EasyLoadingMaskType.black,
      );

      note = await FireStorageService().getNoteById(widget.noteId);
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
        }

        if (temp.containsKey('text')) {
          TextEditingController controller = TextEditingController();
          FocusNode fcnode = FocusNode();

          controller.text = temp['text'];
          noteContentList.add(textFieldWidgetForEdit(controller, fcnode, isEditCompleted, widget.isEdit));
        }
      }
      // if(temp.containsKey('image')){
      //   if(temp['image'] == ""){
      //     if(isConnected){
      //       String urlImageCloud = await StorageService().uploadImage(File(note.content[i-1]["local_image"]));
      //       note.content[i]['image'] = urlImageCloud;
      //     }
      //   }
      // }
    }

    // await FireStorageService().updateCloudImageURL(id, note.content);
    setState(() {});

    await EasyLoading.dismiss();
  }

  Future<void> updateNote() async {

    note = await FireStorageService().getNoteById(widget.noteId);

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

    await FireStorageService().updateNoteById(widget.noteId, noteContent);

    late int index;
    if (isConnected) {
      StorageService().deleteListOnlineImage(note.content);

      for (int i = 0; i < noteContentList.length; i++) {
        if (noteContentList[i] is File) {
          String temp = await StorageService().uploadImage(noteContentList[i]);

          index = imageText.indexWhere(
                  (element) => element["local_image"] == noteContentList[i].path);
          // imageText.insert(index + 1, {'image': temp});
          imageText[index].addAll({'image': temp});

        }
      }

      noteContent.content = imageText;
      await FireStorageService().updateNoteById(widget.noteId, noteContent);
    }

    //Navigator.pop(appcontext);
  }

  Future<void> deleteNote() async {
    if (isConnected) {
      await StorageService().deleteListImage(note.content);
    }
    await FireStorageService().deleteNoteById(widget.noteId);
    setState(() {
      loading = false;
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
    }
  }

  Future<void> createTagAtLocal() async {
    if (_tagnamecontroller.text.isNotEmpty) {
      TagModel tagmodel = TagModel(tag_name: _tagnamecontroller.text);

      bool checkinsert = await tagDAL.insertTag(tagmodel, -1, InitDataBase.db);

      checkinsert
          ? debugPrint("Tao nhan thanh cong!")
          : debugPrint("Tao nhan that bai, xay ra loi!");

      _tagnamecontroller.text = "";

      await EasyLoading.dismiss();

      isCreatedNewTag = false;
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

  Duration timeSchedule(){
    return durationTime =  scheduleTime.difference(DateTime.now());
  }
}
