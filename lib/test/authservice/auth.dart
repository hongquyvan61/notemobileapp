import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final _auth = FirebaseAuth.instance;

  Future<void> registerWithEmailPassword (String email, String password) async {
    final _user = _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signInWithEmailPassword (String email, String password) async {
    final _user = _auth.signInWithEmailAndPassword(email: email, password: password);
  }
}