import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';
import 'package:reddit/reddit.dart' show CommentsSort;

import '../logic/post.dart';
import '../logic/post_comments.dart';
import '../logic/thing.dart';
import '../model/post.dart';
import '../model/post_comments.dart';
import '../ui/circle_divider.dart';
import '../ui/content_handle.dart';
import '../ui/formatting.dart';
import '../ui/media_thumbnail.dart';
import '../ui/post_comments_slivers.dart';
import '../ui/routing.dart';
import '../ui/snudown_body.dart';
import '../ui/theming.dart';
import '../ui/votable_utils.dart';

IconData _determineSortIcon(CommentsSort sortBy) {
  switch (sortBy) {
    case CommentsSort.best:
      return Icons.star;
    case CommentsSort.newest:
      return Icons.fiber_new;
    case CommentsSort.top:
      return Icons.bar_chart;
    case CommentsSort.qa:
      return Icons.question_answer;
    case CommentsSort.controversial:
      return Icons.face;
  }
  return Icons.sort;
}

class _PostContentBody extends StatelessWidget {

  _PostContentBody({
    Key? key,
    required this.post,
    required this.comments,
  }) : super(key: key);

  final Post post;
  final PostComments comments;

  @override
  Widget build(BuildContext context) {
    final theming = Theming.of(context);
    return Material(
      color: theming.canvasColor,
      child: CustomScrollView(
        slivers: <Widget>[
          PostCommentsRefreshSliver(
            comments: comments),
          _PostSliver(
            post: comments.post),
          PostCommentsTreeSliver(
            comments: comments)
        ]));
  }
}

class _PostSliver extends StatelessWidget {

  _PostSliver({
    Key? key,
    required this.post,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    final theming = Theming.of(context);
    return SliverToBoxAdapter(
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 1.0,
              color: theming.borderColor))),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                post.title,
                style: theming.titleText),
              Padding(
                padding: EdgeInsets.only(top: 2.0, bottom: 4.0),
                child: Wrap(
                  spacing: 4.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: HorizontalCircleDivider.divide(<Widget>[
                    Text(
                      'r/${post.subredditName}',
                      style: theming.detailText),
                    Text(
                      'u/${post.authorName}',
                      style: theming.detailText.copyWith(color: Colors.lightBlue)),
                    Text(
                      '${formatElapsedUtc(post.createdAtUtc)}',
                      style: theming.detailText),
                    Text(
                      '${formatCount(post.score)} points',
                      style: applyVoteDirColorToText(theming.detailText, post.voteDir)),
                    Text(
                      '${formatCount(post.commentCount)} comments',
                      style: theming.detailText)
                  ]))),
              if (post.media != null)
                Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: AspectRatio(
                    aspectRatio: 16/9,
                    child: SizedBox.expand(
                      child: MediaThumbnail(
                        media: post.media!)))),
              if (post.selfText != null)
                Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: SnudownBody(
                    snudown: post.selfText!,
                    scrollable: false))
            ]))));
  }
}

class PostRoute extends RouteEntry {

  PostRoute({ required this.post });

  final Post post;
  late PostComments _comments;

  static String pathFrom(Post post, String pathPrefix) {
    return '$pathPrefix${post.fullId}';
  }

  static void goTo(BuildContext context, Post post, String path) {
    context.goTo(
      path,
      onCreateEntry: () {
        return PostRoute(post: post);
      },
      onUpdateEntry: (RouteEntry entry) {
        assert(entry is PostRoute);
        // TODO
      });
  }

  @override
  void initState(BuildContext context) {
    _comments = commentsFromPost(post);
    context.then(Then.all({
        MarkPostAsViewed(post: post),
        RefreshPostComments(
          comments: _comments,
          sortBy: CommentsSort.best),
      }));
  }

  @override
  Widget build(BuildContext context) {
    final theming = Theming.of(context);
    return SizedBox();
  }
}
