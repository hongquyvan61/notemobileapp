import 'dart:io';

import 'package:flutter/material.dart';
import 'package:notemobileapp/router.dart';

import 'package:notemobileapp/test/page/dialog.dart';

import '../component/toast.dart';
import '../services/auth.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _loading = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  var _isObscure;

 

  late BuildContext appcontext;

  @override
  void initState() {
    // TODO: implement initState
    _isObscure = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    appcontext = context;
    return Scaffold(
      appBar: AppBar(
        title: Text('Đăng nhập'),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              const Text(
                'Đăng Nhập',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập địa chỉ Email của bạn !";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                    hintText: 'Email',
                    focusColor: Colors.black,
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                      color: Colors.black,
                      width: 2,
                    )),
                    icon: Icon(Icons.account_box)),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: _isObscure,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập mật khẩu của bạn";
                  }
                  return null;
                },
                decoration: InputDecoration(
                    hintText: 'Mật khẩu',
                    focusColor: Colors.black,
                    focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                      color: Colors.black,
                      width: 2,
                    )),
                    suffixIcon: IconButton(
                      padding: const EdgeInsetsDirectional.only(end: 12),
                      icon: _isObscure
                          ? const Icon(Icons.visibility)
                          : const Icon(Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                    icon: const Icon(Icons.lock)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () {
                        DialogPage().openDialog(context);
                      },
                      child: const Text("Quên mật khẩu?")),
                ],
              ),
              //const Spacer(),
              SizedBox(
                width: Size.infinite.width,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    await handleSubmit(appcontext);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      maximumSize: Size.infinite),
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Đăng nhập'),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              // Text("Or"),
              // SizedBox(
              //   height: 20,
              // ),
              // SizedBox(
              //   width: Size.infinite.width,
              //   height: 50,
              //   child: ElevatedButton(
              //     onPressed: () {
              //       Auth().signInWithGoogle(context).then((value) {
              //         ToastComponent().showToast("Đăng nhập thành công");
              //         Navigator.of(context).pushNamedAndRemoveUntil(
              //             RoutePaths.start, (Route<dynamic> route) => false);
              //       });;
              //     },
              //     style: ElevatedButton.styleFrom(
              //         backgroundColor: Colors.black,
              //         maximumSize: Size.infinite),
              //     child: _loading
              //         ? const SizedBox(
              //             width: 20,
              //             height: 20,
              //             child: CircularProgressIndicator(
              //               color: Colors.white,
              //               strokeWidth: 2,
              //             ),
              //           )
              //         : Row(
              //             mainAxisAlignment: MainAxisAlignment.center,
              //             children: [
              //               Image.asset(
              //                 "images/google.png",
              //                 height: 30,
              //               ),
              //               SizedBox(
              //                 width: 5,
              //               ),
              //               Text("Sign Up with Google")
              //             ],
              //           ),
              //   ),
              // ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Bạn chưa có tài khoản?"),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(RoutePaths.signup);
                      },
                      child: Text("Đăng ký"))
                ],
              ),
              const Spacer()
            ],
          ),
        ),
      )),
    );
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

  

  Future<void> handleSubmit(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.value.text;
    final password = _passwordController.value.text;

    _loading = true;
    if(mounted){
      setState(() {
      
      });
    }
    
    await Auth().signInWithEmailPassword(context, email, password);
    // if(uID != -1){
    //   Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen(userID: uID)));
    // }
    // if(ucre != null){
    //   Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomeScreen()));
    // }

    Future.delayed(const Duration(seconds: 3), () {
      
    });

    _loading = false;

    if(mounted){
      setState(() {
        
      });
    }
  }
}
