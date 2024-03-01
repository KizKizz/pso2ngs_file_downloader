import 'package:flutter/material.dart';

class StateProvider with ChangeNotifier {
  double _downloadPercentage = 0;
  String _downloadFileName = '';
  bool _isUpdateAvailable = false;

  double get downloadPercentage => _downloadPercentage;
  String get downloadFileName => _downloadFileName;
  bool get isUpdateAvailable => _isUpdateAvailable;

  void isUpdateAvailableTrue() {
    _isUpdateAvailable = true;
    notifyListeners();
  }

  void isUpdateAvailableFalse() {
    _isUpdateAvailable = false;
    notifyListeners();
  }

  void downloadFileNameSet(String name) {
    _downloadFileName = name;
    notifyListeners();
  }

  void downloadFileNameReset() {
    _downloadFileName = '';
    notifyListeners();
  }

  void downloadPercentageSet(double percent) {
    _downloadPercentage = percent;
    notifyListeners();
  }

  void downloadPercentageReset() {
    _downloadPercentage = 0;
    notifyListeners();
  }
}
