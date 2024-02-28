import 'package:flutter/material.dart';

class StateProvider with ChangeNotifier {
  double _downloadPercentage = 0;

  double get downloadPercentage => _downloadPercentage;

  void downloadPercentageSet(double percent) {
    _downloadPercentage = percent;
    notifyListeners();
  }

  void downloadPercentageReset() {
    _downloadPercentage = 0;
    notifyListeners();
  }
}
