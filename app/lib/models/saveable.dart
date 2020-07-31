import 'package:elmer/elmer.dart';

import 'thing.dart';

export 'thing.dart';

@abs
abstract class Saveable implements Thing {

  bool isSaved;
}
