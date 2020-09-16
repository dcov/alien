import 'package:elmer/elmer.dart';

import 'thing.dart';

part 'more.g.dart';

abstract class More extends Model implements Thing {

  factory More({
    bool isLoading,
    int count,
    int depth,
    List<String> thingIds,
    String id,
    String kind,
  }) = _$More;

  int get count;

  int get depth;

  bool isLoading;

  List<String> get thingIds;
}

