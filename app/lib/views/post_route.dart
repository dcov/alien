import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';
import 'package:reddit/reddit.dart' show CommentsSort, VoteDir;

import '../logic/post.dart';
import '../logic/post_comments.dart';
import '../logic/thing.dart';
import '../models/post.dart';
import '../models/post_comments.dart';
import '../utils/formatting.dart';
import '../views/media_thumbnail.dart';
import '../views/post_comments_slivers.dart';
import '../views/snudown_body.dart';
import '../views/votable_utils.dart';
import '../widgets/circle_divider.dart';
import '../widgets/content_handle.dart';
import '../widgets/shell.dart';
import '../widgets/theming.dart';

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

class PostRoute extends ShellRoute {

  PostRoute({ required this.post });

  final Post post;
  late PostComments _comments;

  static String pathFrom(Post post, String pathPrefix) {
    return '$pathPrefix${post.fullId}';
  }

  static void goTo(BuildContext context, Post post, String path) {
    context.goTo(
      path,
      onCreateRoute: () {
        return PostRoute(post: post);
      },
      onUpdateRoute: (ShellRoute route) {
        assert(route is PostRoute);
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
  RouteComponents build(BuildContext context) {
    final theming = Theming.of(context);
    return RouteComponents(
      titleMiddle: Text(
        'Comments',
        style: theming.headerText),
      contentHandle: ContentHandle(
        items: <ContentHandleItem>[
          ContentHandleItem(
            icon: _determineSortIcon(_comments.sortBy),
            text: _comments.sortBy.name.toUpperCase()),
          ContentHandleItem(
            icon: Icons.comment,
            text: '${post.commentCount}')
        ]),
      contentBody: _PostContentBody(
        post: post,
        comments: _comments));
  }
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