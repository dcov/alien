import 'package:muex/muex.dart';

import 'thing.dart';

part 'more.g.dart';

abstract class More implements Model, Thing {

  factory More({
    required bool isLoading,
    required int count,
    required int depth,
    required Iterable<String> thingIds,
    required Object refreshMarker,
    required String id,
    required String kind,
  }) = _$More;

  int get count;

  int get depth;

  bool get isLoading;
  set isLoading(bool value);

  Iterable<String> get thingIds;

  /// The post comments refresh instance that led to this object being created.
  /// 
  /// This is used when loading the comments that correspond to a [More] instance (i.e. the [thingIds]).
  ///
  /// See the [PostComments] model for more info.
  Object get refreshMarker;
}

