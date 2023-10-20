import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CountdownState with ChangeNotifier {
  int _remainingSeconds = 60;
  late Timer _timer;

  int get remainingSeconds => _remainingSeconds;

  void startCountdown() {
    bool? _user = FirebaseAuth.instance.currentUser?.email?.isNotEmpty;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_remainingSeconds == 0 || !_user!) { //Huỷ bộ đếm khi đăng xuất, tránh lỗi SetState() leak memory
        resetCountdown();
        timer.cancel();
      } else {
        _remainingSeconds--;
        notifyListeners();
      }
    });
  }

  void resetCountdown() {
    _remainingSeconds = 60;
    notifyListeners();
  }

  void stopCount(){
    _timer.cancel();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
