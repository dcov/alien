import 'package:elmer/elmer.dart';

import 'thing_model.dart';

export 'thing_model.dart';

@abs
abstract class Saveable implements Thing {

  bool isSaved;
}
