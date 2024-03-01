import 'package:flutter/material.dart';

class StateProvider with ChangeNotifier {
  double _downloadPercentage = 0;
  String _downloadFileName = '';
  String _downloadedItemDirPath = '';

  double get downloadPercentage => _downloadPercentage;
  String get downloadFileName => _downloadFileName;
  String get downloadedItemDirPath => _downloadedItemDirPath;
  
   void downloadedItemDirPathSet(String path) {
    _downloadedItemDirPath = path;
    notifyListeners();
  }

  void downloadedItemDirPathReset() {
    _downloadedItemDirPath = '';
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
