import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notemobileapp/home/home.dart';
import 'package:notemobileapp/router.dart';
import 'package:notemobileapp/test/authservice/auth.dart';
import 'package:notemobileapp/test/page/dialog.dart';

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

  @override
  void initState() {
    // TODO: implement initState
    _isObscure = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Đăng nhập'),),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Login',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),

              const SizedBox(
                height: 20,
              ),

              TextFormField(
                controller: _emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your Email";
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
                    return "Please enter your Password";
                  }
                  return null;
                },
                decoration: InputDecoration(
                    hintText: 'Password',
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
                      child: const Text("Forgot Password?")),
                ],
              ),

              const SizedBox(
                height: 30,
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
                      : const Text('Login'),
                ),
              ),

              SizedBox(
                height: 20,
              ),

              Text("Or"),

              SizedBox(
                height: 20,
              ),

              SizedBox(
                width: Size.infinite.width,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Auth().signInWithGoogle(context);
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
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/google.png",
                              height: 30,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text("Sign Up with Google")
                          ],
                        ),
                ),
              ),

              SizedBox(
                height: 20,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account ?"),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(RoutePaths.signup);
                      },
                      child: Text("Sign Up"))
                ],
              )
            ],
          ),
        ),
      )),
    );
  }

  void handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.value.text;
    final password = _passwordController.value.text;

    setState(() {
      _loading = true;
    });

    int uID = await Auth().signInWithEmailPassword(email, password);
    if(uID != -1){
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomeScreen(userID: uID)));
    }
    // if(ucre != null){
    //   Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomeScreen()));
    // }

    // Future.delayed(const Duration(seconds: 3), () {
    //   setState(() {
    //     _loading = false;
    //   });
    // });
  }
}
