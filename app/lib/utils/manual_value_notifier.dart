import 'package:flutter/foundation.dart';

class ManualValueNotifier<T> extends ValueNotifier<T> {

  ManualValueNotifier(T value) : super(value);

  void notify() => super.notifyListeners();
}
