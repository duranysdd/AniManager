import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  bool _darkMode = false;
  String _language = "es"; // español por defecto
  double _textScale = 1.0; // tamaño normal

  bool get darkMode => _darkMode;
  String get language => _language;
  double get textScale => _textScale;

  void setDarkMode(bool value) {
    _darkMode = value;
    notifyListeners();
  }

  void setLanguage(String value) {
    _language = value;
    notifyListeners();
  }

  void setTextScale(double value) {
    _textScale = value;
    notifyListeners();
  }
}
