import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';
import 'package:reddit/reddit.dart';

import '../logic/post.dart';
import '../logic/post_comments.dart';
import '../logic/thing.dart';
import '../models/post.dart';
import '../models/post_comments.dart';
import '../widgets/circle_divider.dart';
import '../widgets/draggable_page_route.dart';
import '../widgets/formatting.dart';
import '../widgets/pressable.dart';
import '../widgets/routing.dart';

import 'media_thumbnail.dart';
import 'post_comments_slivers.dart';
import 'snudown_body.dart';
import 'sort_bottom_sheet.dart';
import 'votable_utils.dart';

class _PostSliver extends StatelessWidget {

  _PostSliver({
    Key key,
    @required this.post,
  }) : assert(post != null),
       super(key: key);

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
                      media: post.media)))),
            if (post.selfText != null)
              Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: SnudownBody(
                  snudown: post.selfText,
                  scrollable: false))
          ])));
  }
}

class _PostPageView extends StatelessWidget {

  _PostPageView({
    Key key,
    this.comments,
  }) : super(key: key);

  final PostComments comments;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            elevation: 1.0,
            pinned: true,
            backgroundColor: Theme.of(context).canvasColor,
            toolbarHeight: 48.0,
            centerTitle: true,
            leading: PressableIcon(
              onPress: () => Navigator.pop(context),
              icon: Icons.arrow_back_ios,
              iconColor: Colors.black),
            actions: <Widget>[
              PressableIcon(
                onPress: () {},
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                icon: Icons.more_vert,
                iconColor: Colors.black),
            ]),
          PostCommentsRefreshSliver(
            comments: comments),
          _PostSliver(
            post: comments.post),
          Connector(
            builder: (_) {
              return SortSliver(
                parameters: <CommentsSort>[
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
                  context.dispatch(
                    RefreshPostComments(
                      comments: comments,
                      sortBy: parameter));
                });
            }),
          PostCommentsTreeSliver(
            comments: comments)
        ]));
  }
}

class _PostPage extends EntryPage {

  _PostPage({
    this.comments,
    String name,
  }) : super(name: name);

  final PostComments comments;

  @override
  Route createRoute(_) {
    return DraggablePageRoute(
      settings: this,
      builder: (_) {
        return _PostPageView(
          comments: comments);
      });
  }
}

String postPageNameFrom(Post post) {
  return post.fullId;
}

void showPostPage({
    @required BuildContext context,
    @required Post post,
  }) {
  assert(context != null);
  assert(post != null);

  final comments = commentsFromPost(post);

  context
    ..push(
        postPageNameFrom(post),
        (String pageName) {
          return _PostPage(
            comments: comments,
            name: pageName);
        })
    ..dispatch(MarkPostAsViewed(post: post))
    ..dispatch(RefreshPostComments(comments: comments));
}

