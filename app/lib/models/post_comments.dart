import 'package:elmer/elmer.dart';
import 'package:reddit/reddit.dart';

import 'thing.dart';

part 'post_comments.g.dart';

abstract class PostComments extends Model {

  factory PostComments({
    bool isRefreshing,
    CommentsSort sortBy,
    String fullPostId,
    String permalink,
    List<Thing> things,
  }) = _$PostComments;

  String get fullPostId;

  bool isRefreshing;

  String get permalink;

  CommentsSort sortBy;

  List<Thing> get things;
}

