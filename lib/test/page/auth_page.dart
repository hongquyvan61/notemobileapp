import 'package:flutter/material.dart';
import 'package:notemobileapp/test/authservice/auth.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final bool _isLogin = true;
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                            ))),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your Password";
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                        hintText: 'Password',
                        focusColor: Colors.black,
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 2,
                            ))),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      handleSubmit();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child: _loading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(_isLogin ? 'Login' : 'Register'),
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
    if (_isLogin) {
      await Auth().signInWithEmailPassword(email, password);
    } else {
      await Auth().registerWithEmailPassword(email, password);
    }

    Future.delayed(const Duration(seconds: 3), (){
      setState(() {
        _loading = false;
      });
    });
  }
}
