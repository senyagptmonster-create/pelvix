import 'package:flutter/foundation.dart';

class PelvixStore extends ChangeNotifier {
  int _streak = 0;
  int get streak => _streak;

  void incrementStreak() {
    _streak++;
    notifyListeners();
  }
}
