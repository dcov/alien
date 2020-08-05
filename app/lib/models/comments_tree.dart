import 'package:elmer/elmer.dart';
import 'package:reddit/reddit.dart';

import 'thing.dart';

export 'thing.dart';

part 'comments_tree.mdl.dart';

@model
mixin $More implements Thing {

  int get count;

  int get depth;

  bool isLoading;

  List<String> get thingIds;
}

@model
mixin $CommentsTree {

  String get fullPostId;

  bool isRefreshing;

  String get permalink;

  CommentsSort sort;

  List<Thing> get things;
}

