import 'package:flutter/widgets.dart';

class ChangeNotifierController extends ChangeNotifier {

  void notify() {
    notifyListeners();
  }
}
