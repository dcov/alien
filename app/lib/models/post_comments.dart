import 'package:muex/muex.dart';
import 'package:reddit/reddit.dart';

import 'post.dart';
import 'thing.dart';

part 'post_comments.g.dart';

abstract class PostComments implements Model {

  factory PostComments({
    required Post post,
    required CommentsSort sortBy,
    List<Thing> things,
    required bool refreshing,
    Object? latestRefreshMarker,
  }) = _$PostComments;

  Post get post;

  CommentsSort get sortBy;
  set sortBy(CommentsSort value);

  List<Thing> get things;

  bool get refreshing;
  set refreshing(bool value);

  /// Used when determining whether to refresh, and then whether to complete a refresh. This is needed because
  /// there are cases where multiple refresh actions are in progress (ex. if a user changes the sortBy value multiple
  /// times quickly), and this is used to ensure that only the latest refresh action completes succesfully.
  ///
  /// This is also used when loading the comments that correspond to a [More] model, so that if a refresh happens
  /// while loading those [More] comments, the loaded comments won't be inserted into the tree since the tree has
  /// changed and those comments might not correspond to it anymore.
  Object? get latestRefreshMarker;
  set latestRefreshMarker(Object? value);
}
