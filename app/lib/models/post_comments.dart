import 'package:elmer/elmer.dart';
import 'package:reddit/reddit.dart';

import 'post.dart';
import 'thing.dart';

part 'post_comments.g.dart';

abstract class PostComments extends Model {

  factory PostComments({
    Post post,
    bool refreshing,
    CommentsSort sortBy,
    String fullPostId,
    String permalink,
    List<Thing> things,
  }) = _$PostComments;

  Post get post;

  String get fullPostId;

  bool refreshing;

  String get permalink;

  CommentsSort sortBy;

  List<Thing> get things;
}

