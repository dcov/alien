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
    List<Thing> things,
  }) = _$PostComments;

  Post get post;

  bool refreshing;

  CommentsSort sortBy;

  List<Thing> get things;
}

