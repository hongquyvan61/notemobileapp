import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notemobileapp/model/NoteContentModel.dart';
import 'package:notemobileapp/test/database/todo_db.dart';
import 'package:notemobileapp/test/page/todo_page.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:notemobileapp/DAL/UserDAL.dart';
import 'package:notemobileapp/model/NoteModel.dart';
import 'package:notemobileapp/model/initializeDB.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:notemobileapp/DAL/NoteDAL.dart';
import 'package:notemobileapp/DAL/NoteContentDAL.dart';


import '../model/UserModel.dart';
import '../router.dart';

class NewNoteScreen extends StatefulWidget {
  const NewNoteScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return NewNoteScreenState();
  }
}

class NewNoteScreenState extends State<NewNoteScreen> {
  File? _image;

  SpeechToText speechToText = SpeechToText();

  static FocusNode fcnFirstTxtField = FocusNode();
  static TextEditingController FirstTxtFieldController = TextEditingController();

  List<Widget> NoteContentList = <Widget>[
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
  List<TextEditingController> lstTxtController = <TextEditingController>[FirstTxtFieldController];

  List<dynamic> SaveNoteContentList = <dynamic>[FirstTxtFieldController];

  late ScrollController _controller;
  late TextEditingController _notetitlecontroller;
  late TextEditingController _notecontentcontroller;
  bool _showFab = true;
  bool _isElevated = true;
  bool _isVisible = true;
  bool MicroIsListening = false;

  late String NoteTitle = '';
  late String CurrentDateTime;

  UserDAL uDAL = UserDAL();
  NoteDAL nDAL = NoteDAL();
  NoteContentDAL ncontentDAL = NoteContentDAL();

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
  }

  @override
  void dispose() {
    _controller.removeListener(_listen);
    _controller.dispose();
    _notetitlecontroller.dispose();
    _notecontentcontroller.dispose();
    super.dispose();
  }

  Future getImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final imageTemp = File(image.path);

    setState(() {
      this._image = imageTemp;
      Widget widgethinh = Image.file(_image!, width: 250, height: 250, fit: BoxFit.cover,);
      NoteContentList.add(widgethinh);
      FocusNode fcnTxtField = FocusNode();
      TextEditingController txtfieldController = TextEditingController();
      Widget TxtFieldtieptheo = TextField(
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
    });
  }

  Future<void> saveNoteToLocal() async {

    //SUA LAI USER ID O DAY
    //SUA LAI USER ID O DAY
    //SUA LAI USER ID O DAY
    //SUA LAI USER ID O DAY
    //SUA LAI USER ID O DAY
    NoteModel md = NoteModel(title: NoteTitle, date_created: CurrentDateTime, user_id: 1);
    bool checkinsertnote = await nDAL.insertNote(md, 1, InitDataBase.db).catchError(
                                                                          (Object e, StackTrace stackTrace) 
                                                                          {
                                                                            debugPrint(e.toString());
                                                                          },);
    if(checkinsertnote){
      int latestid = await ncontentDAL.getLatestNoteID(InitDataBase.db).catchError(
                                                                          (Object e, StackTrace stackTrace) 
                                                                          {
                                                                            debugPrint(e.toString());
                                                                          },);
      for(int i = 0; i < SaveNoteContentList.length; i++){
        if(SaveNoteContentList[i] is File){
            // getting a directory path for saving
            final Directory directory = await getApplicationDocumentsDirectory();
            String path = directory.path;
            String imagename = basename(SaveNoteContentList[i].path);

            // copy the file to a new path
            final File newImage = await File(SaveNoteContentList[i].path).copy('$path/image/$imagename').catchError(
                                                                          (Object e, StackTrace stackTrace) 
                                                                          {
                                                                            debugPrint(e.toString());
                                                                          },);


            NoteContentModel conmd = NoteContentModel(notecontent_id: null, textcontent: null, imagecontent: '$path/image/$imagename', note_id: latestid);
            bool checkinsertnotecontent = await ncontentDAL.insertNoteContent(conmd, InitDataBase.db).catchError(
                                                                          (Object e, StackTrace stackTrace) 
                                                                          {
                                                                            debugPrint(e.toString());
                                                                          },);
            if(checkinsertnotecontent){
              debugPrint('insert noi dung ghi chu thanh cong');
            }
            else{
              debugPrint('loi insert noi dung ghi chu');
            }
        }
        else{
          String noidungchu = SaveNoteContentList[i].text;
          NoteContentModel conmd = NoteContentModel(notecontent_id: null, textcontent: noidungchu, imagecontent: null, note_id: latestid);
          bool checkinsertnotecontent = await ncontentDAL.insertNoteContent(conmd, InitDataBase.db).catchError(
                                                                          (Object e, StackTrace stackTrace) 
                                                                          {
                                                                            debugPrint(e.toString());
                                                                          },);
            if(checkinsertnotecontent){
              debugPrint('insert noi dung ghi chu thanh cong');
            }
            else{
              debugPrint('loi insert noi dung ghi chu');
            }
        }
      }
      
    }
    else{
      debugPrint('loi insert note');
    }
    //List<NoteModel> lstnotemodel = await nDAL.getAllNotes(InitDataBase.db);
    //List<NoteContentModel> lstnotecontent = await ncontentDAL.getAllNoteContentsById(InitDataBase.db, 1);
  }
  

  @override
  Widget build(BuildContext context) {
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
              backgroundColor: const Color.fromARGB(131, 0, 0, 0),
              elevation: 0.0,
              title: const Text('Tạo ghi chú',),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.check,
                  ),
                  onPressed: (){
                    saveNoteToLocal();
                    Navigator.of(context).pop('RELOAD_LIST');
                    //Navigator.push(context, MaterialPageRoute(builder: (context) => const ToDoPage()));
                  },
                )
              ],
            ),

          body: Container(
              padding: EdgeInsets.all(13),
              child: Column(
                children: [
                  TextField(
                    style: const TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                    controller: _notetitlecontroller,
                    decoration: const InputDecoration(
                      hintText: 'Tiêu đề ghi chú',
                      hintStyle: TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                            width: 1,
                        ), 
                      ),
                    ),
                    onSubmitted: (String value) {
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
                            return NoteContentList[index];
                          },
                          separatorBuilder: (BuildContext context, int index) => const Divider()
                        )
                  ),

                  
                ]
              ),

              
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

              floatingActionButton: _showFab
                ? AvatarGlow(
                  animate: MicroIsListening,
                  duration: const Duration(milliseconds: 2000),
                  glowColor: Colors.deepOrange,
                  repeat: true,
                  child: GestureDetector(
                    onTapDown: (details) async{
                      var available = await speechToText.initialize();
                      var vitri;
                      if(available){
                        setState(() {
                          MicroIsListening = true;
                          speechToText.listen(onResult: (result){
                              setState(() {
                                for(var i = 0; i < lstFocusNode.length; i++){
                                  if(lstFocusNode[i].hasFocus){
                                    vitri = i;
                                    break;
                                  }
                                }
                                if(result.finalResult){
                                  String doanvannoi = result.recognizedWords;
                                  lstTxtController[vitri].text += doanvannoi;
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
                height: 70.0,
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
            )
        )
        

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
