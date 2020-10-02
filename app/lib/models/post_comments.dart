import 'package:elmer/elmer.dart';
import 'package:reddit/reddit.dart';

import 'post.dart';
import 'thing.dart';

part 'post_comments.g.dart';

abstract class PostComments extends Model {

  factory PostComments({
    Post post,
    CommentsSort sortBy,
    List<Thing> things,
    bool refreshing,
    Object latestRefreshMarker,
  }) = _$PostComments;

  Post get post;

  CommentsSort sortBy;

  List<Thing> get things;

  bool refreshing;

  /// Used when determining whether to refresh, and whether to complete a refresh. This is needed because
  /// there are cases where multiple refresh actions are in progress (ex. if a user changes the sortBy value multiple
  /// times quickly), and this is used to ensure that only the latest refresh action completes succesfully.
  ///
  /// This is also used when loading the comments that correspond to a [More] model, so that if a refresh happens
  /// while loading those [More] comments, the loaded comments won't be inserted into the tree since the tree has
  /// changed and those comments might not correspond to it anymore.
  Object latestRefreshMarker;
}

