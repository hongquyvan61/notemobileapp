// ignore_for_file: sort_child_properties_last, prefer_const_constructors

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final String? _avatar = FirebaseAuth.instance.currentUser?.photoURL;
  final String? _userName = FirebaseAuth.instance.currentUser?.displayName;
  final String? _email = FirebaseAuth.instance.currentUser?.email;


  @override
  Widget build(BuildContext context) {
    return Drawer(
        elevation: 16,
        child: ListView(
          children: [
            _avatar != null
                ? UserAccountsDrawerHeader(
                    accountName: Text(_userName!),
                    accountEmail: Text(_email!),
                    currentAccountPicture: CircleAvatar(
                      child: ClipOval(
                        child: Image.network(_avatar!),
                      ),
                    ),
                  )
                : UserAccountsDrawerHeader(
                    accountName: Text('Account name'),
                    accountEmail: Text('Account email'),
                    currentAccountPicture: CircleAvatar(
                      child: ClipOval(
                        child: Icon(Icons.account_circle),
                      ),
                    ),
                  ),
            MouseRegion(
              child: ListTile(
                leading: Icon(Icons.notifications),
                title: Text('Thông báo'),
              ),
            ),
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Chia sẻ ghi chú'),
            ),
            ListTile(
              leading: Icon(Icons.lock_reset),
              title: Text('Đổi mật khẩu'),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Đăng xuất'),
            ),
          ],
        ));
  }
}
