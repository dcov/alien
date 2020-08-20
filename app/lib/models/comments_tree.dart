import 'package:elmer/elmer.dart';
import 'package:reddit/reddit.dart';

import 'thing.dart';

part 'comments_tree.g.dart';

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

abstract class CommentsTree extends Model {

  factory CommentsTree({
    bool isRefreshing,
    CommentsSort sortBy,
    String fullPostId,
    String permalink,
    List<Thing> things,
  }) = _$CommentsTree;

  String get fullPostId;

  bool isRefreshing;

  String get permalink;

  CommentsSort sortBy;

  List<Thing> get things;
}

