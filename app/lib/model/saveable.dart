import 'thing.dart';

abstract class Saveable implements Thing {

  bool get isSaved;
  set isSaved(bool value);
}
