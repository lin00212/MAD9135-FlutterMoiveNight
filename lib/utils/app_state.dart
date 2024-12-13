import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  String? deviceId;
  String sessionId = '';
  setDeviceId(String id) {
    deviceId = id;
    notifyListeners();
  }

  setSessionId(String id) {
    sessionId = id;
    notifyListeners();
  }
}
