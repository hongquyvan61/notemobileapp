// ignore_for_file: sort_child_properties_last, prefer_const_constructors

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';


import '../../router.dart';
import '../services/auth.dart';
import '../services/count_down_state.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

int selected = 0;
bool canReset = true;

class _NavBarState extends State<NavBar> {
  String? _avatar = '';
  String? _userName = '';
  String? _email = '';

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 16,
      child: _email != null
          ? ListView(
              children: [
                UserAccountsDrawerHeader(

                  accountName: _userName != null ? Text(_userName!) : Text(''),
                  accountEmail: Text(_email!),
                  currentAccountPicture: CircleAvatar(
                    child: ClipOval(
                      child: _avatar != null ? Image.network(_avatar!) : Icon(Icons.account_circle),
                    ),
                  ),
                ),
                AppDrawerTile(index: 0, onTap: updateSelected(0)),
                AppDrawerTile(index: 1, onTap: updateSelected(1)),
                canReset
                    ? AppDrawerTile(index: 2, onTap: updateSelected(2))
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: ListTile(
                          selected: selected == 2,
                          // selectedTileColor: Defaults.drawerSelectedTileColor,
                          leading: Icon(
                            Icons.lock_reset,
                            size: 30,
                            color: Colors.black,
                          ),
                          title: Opacity(
                            opacity: 0.25,
                            child: Text(
                              "Thử lại sau(${Provider.of<CountdownState>(context).remainingSeconds})",
                              style: GoogleFonts.sanchez(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,

                              ),
                            ),
                          ),
                        ),
                      ),
                AppDrawerTile(index: 3, onTap: updateSelected(3)),
              ],
            )
          : ListView(
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text('Account name'),
                  accountEmail: Text('Account email'),
                  currentAccountPicture: CircleAvatar(
                    child: ClipOval(
                      child: Icon(Icons.account_circle),
                    ),
                  ),
                ),
                AppDrawerTile(index: 4, onTap: updateSelected(4))
              ],
            ),
    );
  }

  Function updateSelected(int index) {
    return () {
      setState(() {
        selected = index;
      });
      action();
    };
  }

  action() {
    switch (selected) {
      case 0:
        Navigator.pop(context);
        Navigator.pushNamed(context, RoutePaths.notificationPage);
      case 1:
        Navigator.pop(context);
        Navigator.pushNamed(context, RoutePaths.shareNotePage);
      case 2:
        dialogResetPassWord();
      case 3:
        confirmLogOut();
      case 4:
        Navigator.pushNamed(context, RoutePaths.login);
    }
  }

  void confirmLogOut() {
    final googleSignIn = GoogleSignIn();
    AlertDialog alert = AlertDialog(
      contentTextStyle: TextStyle(fontSize: 15, color: Colors.black),
      titleTextStyle: TextStyle(
        fontSize: 20,
        color: Colors.black,
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))),
      title: Text("Đăng xuất khỏi tài khoản này ?"),
      content: Text(
          "Ghi chú của bạn đã được sao lưu, bạn có thể xem khi đăng nhập trở lại!"),
      actions: [
        TextButton(
          child: Text("Không"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text("Đăng xuất"),
          onPressed: () {
            googleSignIn.signOut();
            FirebaseAuth.instance.signOut();
            setState(() {
              _email = null;
              _avatar = null;
              _userName = null;
            });
            Navigator.pop(context);
          },
        )
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }

  void dialogResetPassWord() {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController _rePassController = TextEditingController();
    final TextEditingController _oldPassController = TextEditingController();
    final TextEditingController _newPassController = TextEditingController();
    FocusNode _focus = FocusNode();
    bool canReSendEmail = true;

    AlertDialog alert = AlertDialog(
      contentTextStyle: TextStyle(fontSize: 16, color: Colors.black),
      titleTextStyle: TextStyle(
        fontSize: 25,
        color: Colors.black,
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))),
      title: Text("Đổi mật khẩu"),
      content: Text(
          'Email đặt lại mật khẩu sẽ được gửi tới hộp thư của bạn, truy cập theo đường dẫn trong mail để đặt lại mật khẩu'),
      actions: [
        TextButton(
          child: Text("Huỷ"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        ElevatedButton(
          onPressed: () async {
            // Auth().changePassword();
            Provider.of<CountdownState>(context, listen: false).startCountdown();
            setState(() {
            });
            canReset = false;
            Navigator.pop(context);
            await Future.delayed(Duration(seconds: 60)); //số giây phải bằng số giây ở startCountdown
            canReset = true;
          },
          child: Text("Gửi email"),
          focusNode: _focus,
        )
      ],
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        });
  }



  void getUserInfo(){
    FirebaseAuth _auth = FirebaseAuth.instance;
    _email = _auth.currentUser?.email;
    _userName = _auth.currentUser?.displayName;
    _avatar = _auth.currentUser?.photoURL;
  }
}

class AppDrawerTile extends StatelessWidget {
  const AppDrawerTile({
    super.key,
    required this.index,
    required this.onTap,
  });

  final int index;
  final onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListTile(
        onTap: onTap,
        selected: selected == index,
        // selectedTileColor: Defaults.drawerSelectedTileColor,
        leading: Icon(
          drawerItemIcon[index],
          size: 30,
          color: Colors.black,
        ),
        title: Text(
          drawerItemText[index],
          style: GoogleFonts.sanchez(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  static final drawerItemIcon = [
    Icons.notifications,
    Icons.share,
    Icons.lock_reset,
    Icons.logout,
    Icons.login,

  ];
  static final drawerItemText = [
    'Thông báo',
    'Chia sẻ ghi chú',
    'Đổi mật khẩu',
    'Đăng xuất',
    'Đăng nhập',

  ];
}

class SetTrue{ //Set lại canResent sau đăng xuất khi bộ delay chưa đếm xong để user mới vào bấm được,vì bộ delay chưa xong không thể set True.
  void setCanReset(){
    canReset = true;
  }
}