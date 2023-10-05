import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notemobileapp/DAL/FB_DAL.dart/FB_Note.dart';
import 'package:notemobileapp/DAL/FB_DAL.dart/FB_NoteContent.dart';
import 'package:notemobileapp/model/SqliteModel/FirebaseModel/FBNoteContentModel.dart';
import 'package:notemobileapp/model/SqliteModel/NoteContentModel.dart';
import 'package:notemobileapp/model/SqliteModel/UpdateNoteModel.dart';
import 'package:notemobileapp/test/database/todo_db.dart';
import 'package:notemobileapp/test/page/todo_page.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:notemobileapp/DAL/UserDAL.dart';
import 'package:notemobileapp/model/SqliteModel/NoteModel.dart';
import 'package:notemobileapp/model/SqliteModel/initializeDB.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:notemobileapp/DAL/NoteDAL.dart';
import 'package:notemobileapp/DAL/NoteContentDAL.dart';
import 'package:sqflite/sqflite.dart';

import '../model/SqliteModel/FirebaseModel/FBNoteModel.dart';
import '../model/SqliteModel/UserModel.dart';
import '../router.dart';

class NewNoteScreen extends StatefulWidget {
  const NewNoteScreen({
     Key? key, required this.noteIDedit, required this.isEditState, required this.UserID
  }) : super(key: key);

  final int noteIDedit;
  final bool isEditState;
  final int UserID;

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
  static TextEditingController FirstTxtFieldController = TextEditingController();


  List<dynamic> NoteContentList = <dynamic>[
    TextField(
      keyboardType: TextInputType.multiline,
      focusNode: fcnFirstTxtField,
      controller: FirstTxtFieldController,
      showCursor: true,
      autofocus: true,
      maxLines: null,
      style: const TextStyle(fontSize: 14),
      decoration: const InputDecoration(border: InputBorder.none),
    )
  ];

  List<FocusNode> lstFocusNode = <FocusNode>[fcnFirstTxtField];
  List<TextEditingController> lstTxtController = <TextEditingController>[
    FirstTxtFieldController
  ];

  List<dynamic> SaveNoteContentList = <dynamic>[FirstTxtFieldController];
  List<dynamic> UpdateNoteContentList = <dynamic>[FirstTxtFieldController];


  List<UpdateNoteModel> lstupdatecontents = <UpdateNoteModel>[];
  List<UpdateNoteModel> lstdeletecontents = <UpdateNoteModel>[];
  
  late ScrollController _controller;
  late TextEditingController _notetitlecontroller;
  late TextEditingController _notecontentcontroller;
  bool _showFab = true;
  bool _isElevated = true;
  bool _isVisible = true;
  bool _isBottomAppBarVisible = false;
  bool MicroIsListening = false;

  bool isEditCompleted = true;

  int vitrihinh = 0;

  late String NoteTitle = '';
  late String CurrentDateTime;
  late String firsttxtfieldcont;

  UserDAL uDAL = UserDAL();
  NoteDAL nDAL = NoteDAL();
  NoteContentDAL ncontentDAL = NoteContentDAL();

  FB_Note fb_note = FB_Note();
  FB_NoteContent fb_notect = FB_NoteContent();

  FloatingActionButtonLocation get _fabLocation => _isVisible
      ? FloatingActionButtonLocation.centerDocked
      : FloatingActionButtonLocation.centerFloat;

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
    _notetitlecontroller = TextEditingController();
    _notecontentcontroller = TextEditingController();
    initializeDateFormatting();
    DateTime now = DateTime.now();
    CurrentDateTime = DateFormat.yMd('vi_VN').add_jm().format(now);
    if(widget.isEditState){
      loadingNoteWithIDAtLocal(widget.UserID, widget.noteIDedit, widget.isEditState);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_listen);
    _controller.dispose();
    _notetitlecontroller.dispose();
    _notecontentcontroller.dispose();
    FirstTxtFieldController.text = "";
    super.dispose();
  }


  Future getImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final imageTemp = File(image.path);

    this._image = imageTemp;
     
      if(widget.isEditState == false){
        NoteContentList.add(this._image);
        FocusNode fcnTxtField = FocusNode();
        TextEditingController txtfieldController = TextEditingController();
        Widget TxtFieldtieptheo =  TextField(
          keyboardType: TextInputType.multiline,
          focusNode: fcnTxtField,
          controller: txtfieldController,
          showCursor: true,
          autofocus: true,
          maxLines: null,
          style: const TextStyle(fontSize: 14),
          decoration: const InputDecoration(border: InputBorder.none),
        );
        lstFocusNode.add(fcnTxtField);
        lstTxtController.add(txtfieldController);
        NoteContentList.add(TxtFieldtieptheo);

        SaveNoteContentList.add(imageTemp);
        SaveNoteContentList.add(txtfieldController);
      }
      else{
        NoteContentList.add(this._image);
        FocusNode fcnTxtField = FocusNode();
        TextEditingController txtfieldController = TextEditingController();
        Widget TxtFieldtieptheo =  TextField(
          keyboardType: TextInputType.multiline,
          focusNode: fcnTxtField,
          controller: txtfieldController,
          showCursor: true,
          autofocus: true,
          maxLines: null,
          style: const TextStyle(fontSize: 14),
          decoration: const InputDecoration(border: InputBorder.none),
        );
        lstFocusNode.add(fcnTxtField);
        lstTxtController.add(txtfieldController);
        NoteContentList.add(TxtFieldtieptheo);

        UpdateNoteContentList.add(imageTemp);

        UpdateNoteModel updtmodel = UpdateNoteModel(
          notecontent_id: null, 
          type: "insert_img"
        );
        UpdateNoteModel updtmodel2 = UpdateNoteModel(
          notecontent_id: null, 
          type: "insert_text"
        );

        lstupdatecontents.add(updtmodel);
        lstupdatecontents.add(updtmodel2);

        UpdateNoteContentList.add(txtfieldController);
      }

    setState(() {
      
    });
  }

  Future<bool> showAlertDialog(BuildContext context, String message) async {
    // set up the buttons
    Widget cancelButton = OutlinedButton(
      child: Text("Không"),
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
      title: Text("Xoá hình"),
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


  Future loadingNoteWithIDAtLocal(int uid, int noteID, bool isEdit) async {
    List<NoteModel> tmp = await nDAL.getNoteByID(uid, noteID, InitDataBase.db);
    if(tmp.isNotEmpty && isEdit){
      _notetitlecontroller.text = tmp[0].title;
      CurrentDateTime = tmp[0].date_created;
      List<NoteContentModel> contents = await ncontentDAL.getAllNoteContentsById(InitDataBase.db, noteID);
      if(contents.isNotEmpty){  

        FirstTxtFieldController.text = contents[0].textcontent.toString();

        UpdateNoteModel firstupdtmodel = UpdateNoteModel(
          notecontent_id: contents[0].notecontent_id?.toInt() ?? 0, 
          type: "update"
        );

        lstupdatecontents.add(firstupdtmodel);
        //fcnFirstTxtField.requestFocus();

        if(contents.length >= 2){
          for(int i = 1; i < contents.length; i++){
            if(contents[i].textcontent != null){
              
                FocusNode fcnTxtField = FocusNode();
                TextEditingController txtfieldController = TextEditingController();
                Widget txtfield = TextField(
                  keyboardType: TextInputType.multiline,
                  focusNode: fcnTxtField,
                  controller: txtfieldController,
                  showCursor: true,
                  //autofocus: true,
                  maxLines: null,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(border: InputBorder.none),
                );
                txtfieldController.text = contents[i].textcontent.toString();
                lstFocusNode.add(fcnTxtField);
                lstTxtController.add(txtfieldController);
                NoteContentList.add(txtfield);
                
                UpdateNoteContentList.add(txtfieldController);
                
                UpdateNoteModel updtmodel = UpdateNoteModel(
                  notecontent_id: contents[i].notecontent_id?.toInt() ?? 0, 
                  type: "update"
                );

                lstupdatecontents.add(updtmodel);
            }
            if(contents[i].imagecontent != null){
              File img = File(contents[i].imagecontent.toString());
              
              NoteContentList.add(img);
              UpdateNoteContentList.add(img);

              UpdateNoteModel updtmodel = UpdateNoteModel(
                notecontent_id: contents[i].notecontent_id?.toInt() ?? 0, 
                type: "update"
              );

              lstupdatecontents.add(updtmodel);
            }
          }
        }
        setState(() {
          
        });
      }
    }
  }

  Future<void> uploadNoteToFB() async{

    try{

      firsttxtfieldcont = SaveNoteContentList[0].text;


      int totalnote = await fb_note.FB_CountTotalNote();

      int noteID = totalnote + 1;

      FBNoteModel fbnote = FBNoteModel(
        title: NoteTitle, 
        date_created: CurrentDateTime, 
        user_id: widget.UserID,
        tag_id: -1,
        note_id: noteID
      );

      fb_note.FB_insertNotetoFB(widget.UserID, noteID, fbnote);

      
      for(int i = 0; i < SaveNoteContentList.length; i++){
        if(SaveNoteContentList[i] is File){

          String imagename = basename(SaveNoteContentList[i].path);
          File file = File(SaveNoteContentList[i].path);

          var imagefile = FirebaseStorage.instance.ref().child("userID_${widget.UserID}").child("${imagename}");
          UploadTask task = imagefile.putFile(file!);
          TaskSnapshot snapshot = await task;

          String url = await snapshot.ref.getDownloadURL();

          if(url != null){


            int count = await fb_notect.FB_CountTotalNoteContents();

            int notectID = count + 1;

            FBNoteContentModel fbnotecontent = FBNoteContentModel(
              textcontent: "", 
              imagecontent: url, 
              note_id: noteID,
              notecontent_id: notectID
            );

            await fb_notect.FB_insertNoteContent(noteID, notectID, fbnotecontent);

          }
        }
        else{
          
          String noidungchu = i == 0 ? firsttxtfieldcont : SaveNoteContentList[i].text;

          int count = await fb_notect.FB_CountTotalNoteContents();

          int notectID = count + 1;

          FBNoteContentModel fbnotecontent = FBNoteContentModel(
              textcontent: noidungchu, 
              imagecontent: "", 
              note_id: noteID,
              notecontent_id: notectID
            );

          await fb_notect.FB_insertNoteContent(noteID, notectID, fbnotecontent);

        }
      }

    }
    on Exception catch (e){
      debugPrint(e.toString());
    }
  }

  Future<void> saveNoteToLocal() async {
    //SUA LAI USER ID O DAY
    //SUA LAI USER ID O DAY
    //SUA LAI USER ID O DAY
    //SUA LAI USER ID O DAY
    //SUA LAI USER ID O DAY
    NoteModel md = NoteModel(title: NoteTitle, date_created: CurrentDateTime, user_id: widget.UserID);
    bool checkinsertnote = await nDAL.insertNote(md, widget.UserID, InitDataBase.db).catchError((Object e, StackTrace stackTrace) {
                                                                                  debugPrint(e.toString());
                                                                                },);
    if (checkinsertnote) {
      int latestid = await ncontentDAL.getLatestNoteID(InitDataBase.db).catchError(
        (Object e, StackTrace stackTrace) {
          debugPrint(e.toString());
        },
      );
      for (int i = 0; i < SaveNoteContentList.length; i++) {
        if (SaveNoteContentList[i] is File) {
          // getting a directory path for saving
          final Directory directory = await getApplicationDocumentsDirectory();
          String path = directory.path;
          String imagename = basename(SaveNoteContentList[i].path);

          // copy the file to a new path
          final File newImage = await File(SaveNoteContentList[i].path)
              .copy('$path/image/$imagename')
              .catchError(
            (Object e, StackTrace stackTrace) {
              debugPrint(e.toString());
            },
          );

          NoteContentModel conmd = NoteContentModel(
              notecontent_id: null,
              textcontent: null,
              imagecontent: '$path/image/$imagename',
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
          } 
          else {
            debugPrint('loi insert noi dung ghi chu');
          }

        } 
        else {
          String noidungchu = SaveNoteContentList[i].text;
          NoteContentModel conmd = NoteContentModel(
              notecontent_id: null,
              textcontent: noidungchu,
              imagecontent: null,
              note_id: latestid
          );

          bool checkinsertnotecontent = await ncontentDAL
              .insertNoteContent(conmd, InitDataBase.db)
              .catchError(
            (Object e, StackTrace stackTrace) {
              debugPrint(e.toString());
            },
          );

          if (checkinsertnotecontent) {
            debugPrint('insert noi dung ghi chu thanh cong');
          }
          else {
            debugPrint('loi insert noi dung ghi chu');
          }
        }
      }
    } 
    else {
      debugPrint('loi insert note');
    }
    //List<NoteModel> lstnotemodel = await nDAL.getAllNotes(InitDataBase.db);
    //List<NoteContentModel> lstnotecontent = await ncontentDAL.getAllNoteContentsById(InitDataBase.db, 1);
  }

  Future<void> updateNoteToLocal() async {
    bool updttitle = await nDAL.updateNoteTitle(widget.noteIDedit, _notetitlecontroller.text, InitDataBase.db);
    if(updttitle){
      debugPrint("cap nhat tieu de ghi chu thanh cong");
    }
    else{
      debugPrint("xay ra loi khi cap nhat tieu de ghi chu");
    }
    for(int i = 0; i < lstupdatecontents.length; i++){
      if(lstupdatecontents[i].type == "update"){
        if(UpdateNoteContentList[i] is File){
          String imgpath = UpdateNoteContentList[i].path;
          bool isSuccess = await ncontentDAL.updateContentByID(
            lstupdatecontents[i].notecontent_id?.toInt() ?? 0, 
            null, 
            imgpath, 
            InitDataBase.db
          );

        }
        else{
          String txt = UpdateNoteContentList[i].text;
          bool isSuccess = await ncontentDAL.updateContentByID(
            lstupdatecontents[i].notecontent_id?.toInt() ?? 0, 
            txt, 
            null, 
            InitDataBase.db
          );
        }
      }
      if(lstupdatecontents[i].type == "insert_img"){
        final Directory directory = await getApplicationDocumentsDirectory();
        String drpath = directory.path;

        String imgpath = UpdateNoteContentList[i].path;
        String imagename = basename(imgpath);

        final File newImage = await File(imgpath)
              .copy('$drpath/image/$imagename')
              .catchError(
            (Object e, StackTrace stackTrace) {
              debugPrint(e.toString());
            },
          );

          NoteContentModel conmd = NoteContentModel(
              notecontent_id: null,
              textcontent: null,
              imagecontent: '$drpath/image/$imagename',
              note_id: widget.noteIDedit
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
          } 
          else {
            debugPrint('loi insert hinh moi khi edit ghi chu');
          }

      }
      if(lstupdatecontents[i].type == "insert_text"){

        NoteContentModel conmd = NoteContentModel(
              notecontent_id: null,
              textcontent: UpdateNoteContentList[i].text,
              imagecontent: null,
              note_id: widget.noteIDedit
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
          } 
          else {
            debugPrint('loi insert text moi khi edit ghi chu');
          }
      }
    }

    for(int i = 0; i < lstdeletecontents.length; i++){
      bool checkdel = await ncontentDAL.deleteNoteContentsByID(lstdeletecontents[i].notecontent_id?.toInt() ?? 0, InitDataBase.db);
      if(checkdel){
        debugPrint("Xoa text field hoac img sau khi edit thanh cong");
      }
      else{
        debugPrint("Xoa text field hoac img sau khi edit xay ra loi!!");
      }
    }
  }


  Widget buildImageWidget(BuildContext context, int index){
     Widget widgethinh = Stack(
        children: [
              Image.file(
                NoteContentList[index]!,
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
                    bool isDeleted = await showAlertDialog(appcontext, "Bạn có muốn xoá hình này?");
                    if(isDeleted){                                   //XOA HINH
                      NoteContentList.removeAt(index);
                      if(widget.isEditState == false){
                        SaveNoteContentList.removeAt(index);
                      }
                      else{
                        UpdateNoteContentList.removeAt(index);

                        UpdateNoteModel delmodel = UpdateNoteModel(
                          notecontent_id: lstupdatecontents[index].notecontent_id, 
                          type: "delete"
                        );

                        lstupdatecontents.removeAt(index);
                        lstdeletecontents.add(delmodel);
                      }
                    }
                    if(widget.isEditState == false){
                      if(SaveNoteContentList[index].text == ""){       //XOA TEXT FIELD NGAY SAU HINH NEU TEXT FIELD TRONG KHI TAO GHI CHU
                        NoteContentList.removeAt(index);
                      }
                    }
                    else{
                      if(UpdateNoteContentList[index] is TextEditingController){
                        if(UpdateNoteContentList[index].text == ""){       //XOA TEXT FIELD NGAY SAU HINH NEU TEXT FIELD TRONG KHI EDIT GHI CHU
                          NoteContentList.removeAt(index);

                          UpdateNoteModel delmodel = UpdateNoteModel(
                            notecontent_id: lstupdatecontents[index].notecontent_id, 
                            type: "delete"
                          );

                          lstupdatecontents.removeAt(index);
                          lstdeletecontents.add(delmodel);
                        }
                      }
                    }
                    setState(() {
                      
                    });
                  }
                )
              )
        ]
      );
    return widgethinh;
  }

  @override
  Widget build(BuildContext context) {
    appcontext = context;
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(131, 0, 0, 0),
              elevation: 0.0,
              title: widget.isEditState ? const Text('Sửa ghi chú',) : const Text('Tạo ghi chú',),
              centerTitle: true,
              actions: [
                if(widget.isEditState && isEditCompleted)
                  IconButton(
                    icon: const Icon(
                      Icons.edit,
                    ),
                    onPressed: () {
                      isEditCompleted = false;
                      setState(() {
                        
                      });
                      return ;
                    },
                  )
                else
                  if(isEditCompleted == false)
                     IconButton(
                        icon: const Icon(
                          Icons.update,
                        ),
                        onPressed: () {

                          updateNoteToLocal();

                          Navigator.of(context).pop('RELOAD_LIST');
                          //Navigator.push(context, MaterialPageRoute(builder: (context) => const ToDoPage()));
                        },
                    ),
                //Icon(null)
                  if(widget.isEditState == false)
                    IconButton(
                      icon: const Icon(
                        Icons.check,
                      ),
                      onPressed: () {
                        uploadNoteToFB();
                        saveNoteToLocal();
                        Navigator.of(context).pop('RELOAD_LIST');
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
                  controller: _notetitlecontroller,
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
                    NoteTitle = _notetitlecontroller.text;
                    fcnFirstTxtField.requestFocus();
                  },
                  onTapOutside: (event) {
                    NoteTitle = _notetitlecontroller.text;
                  },
                ),

                const SizedBox(height: 10),

                Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Ngày giờ tạo: ' + CurrentDateTime,
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                ),

                Expanded(
                    child: ListView.separated(
                        controller: _controller,
                        itemCount: NoteContentList.length,
                        itemBuilder: (BuildContext context, int index) {
                          if(NoteContentList[index] is File){
                            return buildImageWidget(context, index);
                          }
                          else{
                            return NoteContentList[index];
                          }
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider())),
                
                Align(
                  alignment: Alignment.bottomCenter,
                  child: widget.isEditState  && (isEditCompleted == true) ? Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: SizedBox()
                      ),

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
                                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(Color.fromARGB(255, 97, 115, 239)),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: 5,),

                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {},
                                child: const Icon(
                                  Icons.delete,
                                  size: 20.0,
                                ),
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all(EdgeInsets.zero),
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(Color.fromARGB(255, 97, 115, 239)),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Expanded(
                        flex: 1,
                        child: SizedBox()
                      ),
                    ],
                  )
                  :
                  null
                )
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
            floatingActionButton: (isEditCompleted == false) || widget.isEditState == false
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
                                  if(vitri == 0){
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
                height: (isEditCompleted == false) || widget.isEditState == false ?  70.0 : 0.0, 
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
  }
}
