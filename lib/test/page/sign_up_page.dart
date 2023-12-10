import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../router.dart';
import '../component/toast.dart';
import '../services/auth.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _retypePasswordController =
      TextEditingController();

  var _isObscure;

  @override
  void initState() {
    // TODO: implement initState
    _isObscure = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
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
                'Đăng ký',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Vui lòng nhập địa chỉ Email của bạn";
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
                    icon: Icon(Icons.lock)),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _retypePasswordController,
                obscureText: _isObscure,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Mật khẩu không trùng khớp";
                  }
                  return null;
                },
                decoration: InputDecoration(
                    hintText: 'Nhập lại mật khẩu',
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
                    icon: Icon(Icons.lock)),
              ),
              SizedBox(
                height: 50,
              ),
              SizedBox(
                width: Size.infinite.width,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    handleSubmit();
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
                      : Text('Đăng ký'),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Bạn đã có tài khoản?"),
                  TextButton(onPressed: () {
                    Navigator.of(context).popAndPushNamed(RoutePaths.login);
                  }, child: Text("Đăng nhập"))
                ],
              ),
              const Spacer()
            ],
          ),
        ),
      )),
    );
  }

  void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  void handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.value.text;
    final password = _passwordController.value.text;
    final retypePassword = _retypePasswordController.value.text;

    setState(() {
      _loading = true;
    });

    if (password.endsWith(retypePassword)) {
       String returnstr = await Auth().registerWithEmailPassword(context, email, password);

      if (returnstr == "success") {
        ToastComponent()
            .showToast('Đăng ký thành công. Vui lòng xác nhận email');
        Navigator.of(context).pushNamedAndRemoveUntil(
            RoutePaths.verifyEmail, (Route<dynamic> route) => false);
      }
      else{
        _loading = false;
        setState(() {
            
        });
      }
    } else {
      _loading = false;
      setState(() {

      });
      showToast("Mật khẩu không trùng khớp ! Thử lại");
    }

  }
}
