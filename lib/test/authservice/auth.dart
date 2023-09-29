import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  Future<String> registerWithEmailPassword (String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'The account already exists for that email.';
      }
    } catch (e) {
      print(e);
    }
    return 'Successful';
  }

  Future<void> signInWithEmailPassword (String email, String password) async {
    final _user = _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  signInWithGoogle() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication aAuth = await gUser!.authentication;

    final credential = GoogleAuthProvider.credential(accessToken: aAuth.accessToken, idToken: aAuth.idToken);

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  googleSignOut() async {

    _auth.signOut();
    _googleSignIn.signOut();
  }
}