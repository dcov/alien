import 'package:flutter/material.dart';
import 'package:muex_flutter/muex_flutter.dart';
import 'package:reddit/reddit.dart' show CommentsSort;

import '../logic/post.dart';
import '../logic/post_comments.dart';
import '../logic/thing.dart';
import '../models/post.dart';
import '../models/post_comments.dart';
import '../utils/formatting.dart';
import '../views/media_thumbnail.dart';
import '../views/post_comments_slivers.dart';
import '../views/snudown_body.dart';
import '../views/sort_bottom_sheet.dart';
import '../views/votable_utils.dart';
import '../widgets/circle_divider.dart';
import '../widgets/shell.dart';

class PostRoute extends ShellRoute {

  PostRoute({ required this.post });

  final Post post;
  late PostComments _comments;

  static void goTo(BuildContext context, Post post, String pathPrefix) {
    context.goTo(
      '$pathPrefix${post.fullId}',
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
    return RouteComponents(
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
    return Material(
      child: CustomScrollView(
        slivers: <Widget>[
          PostCommentsRefreshSliver(
            comments: comments),
          _PostSliver(
            post: comments.post),
          Connector(
            builder: (_) {
              return SortSliver(
                sortArgs: const <CommentsSort>[
                  // TODO: possibly move this into the reddit package as a static field i.e. CommentsSort.values
                  CommentsSort.best,
                  CommentsSort.top,
                  CommentsSort.newest,
                  CommentsSort.controversial,
                  CommentsSort.old,
                  CommentsSort.qa
                ],
                currentSortBy: comments.sortBy,
                onSort: (CommentsSort parameter, _) {
                  context.then(Then(
                      RefreshPostComments(
                        comments: comments,
                        sortBy: parameter)));
                });
            }),
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
  Widget build(_) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              post.title,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500)),
            Padding(
              padding: EdgeInsets.only(top: 2.0, bottom: 4.0),
              child: Wrap(
                spacing: 4.0,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: HorizontalCircleDivider.divide(<Widget>[
                  Text(
                    'r/${post.subredditName}',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.black54)),
                  Text(
                    'u/${post.authorName}',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.blue.shade900.withAlpha((80 / 100 * 255).round()))),
                  Text(
                    '${formatElapsedUtc(post.createdAtUtc)}',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.black54)),
                  Text(
                    '${formatCount(post.score)} points',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: getVotableColor(post))),
                  Text(
                    '${formatCount(post.commentCount)} comments',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.black54))
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
          ])));
  }
}
