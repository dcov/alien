import 'package:mal/mal.dart';

import 'thing.dart';

part 'more.g.dart';

abstract class More implements Model, Thing {

  factory More({
    bool isLoading,
    int count,
    int depth,
    List<String> thingIds,
    Object refreshMarker,
    String id,
    String kind,
  }) = _$More;

  int get count;

  int get depth;

  bool isLoading;

  List<String> get thingIds;

  /// The post comments refresh instance that led to this object being created.
  /// 
  /// This is used when loading the comments that correspond to a [More] instance (i.e. the [thingIds]).
  ///
  /// See the [PostComments] model for more info.
  Object get refreshMarker;
}

