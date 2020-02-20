import 'package:elmer/elmer.dart';

import '../thing/thing_model.dart';

@abs
abstract class Saveable implements Thing {

  bool isSaved;
}
