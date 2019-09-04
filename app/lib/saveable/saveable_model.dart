part of 'saveable.dart';

mixin Saveable on Thing {

  bool get isSaved => _isSaved;
  bool _isSaved;
  set isSaved(bool value) {
    _isSaved = set(_isSaved, value);
  }
}
