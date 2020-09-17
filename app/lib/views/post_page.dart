import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';
import 'package:reddit/reddit.dart' show VoteDir;

import '../logic/post_comments.dart';
import '../logic/thing.dart';
import '../models/post.dart';
import '../models/post_comments.dart';
import '../widgets/formatting.dart';
import '../widgets/pressable.dart';
import '../widgets/routing.dart';
import '../widgets/widget_extensions.dart';

import 'media_thumbnail.dart';
import 'post_comments_scroll_view.dart';

class _PostPageView extends StatelessWidget {

  _PostPageView({
    Key key,
    @required this.comments,
  }) : assert(comments != null),
       super(key: key);

  final PostComments comments;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Material(
          child: Padding(
            padding: EdgeInsets.only(top: context.mediaPadding.top),
            child: SizedBox(
              height: 48.0,
              child: NavigationToolbar(
                leading: CloseButton(),
                middle: Text('${comments.post.commentCount} comments'))))),
        Expanded(
          child: PostCommentsScrollView(
            comments: comments)),
      ]);
  }
}

class _PostPage extends EntryPage {

  _PostPage({
    @required this.comments,
    @required String name,
  }) : super(name: name);

  final PostComments comments;

  @override
  Route createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (BuildContext context, _, __) {
        return _PostPageView(comments: comments);
      });
  }
}

void _showPostPage({
    BuildContext context,
    Post post
  }) {

  final comments = post.toComments();

  context.push(
    postPageNameFrom(post),
    (String pageName) {
      return _PostPage(
        comments: comments,
        name: pageName);
    });

  context.dispatch(
    RefreshPostComments(
      comments: comments));
}

class PostTile extends StatelessWidget {

  PostTile({
    Key key,
    @required this.post,
    @required this.includeSubredditName
  }) : assert(post != null),
       assert(includeSubredditName != null),
       super(key: key);

  final Post post;

  final bool includeSubredditName;

  @override
  Widget build(_) {
    return Connector(
      builder: (BuildContext context) {
        return Pressable(
          onPress: () {
            _showPostPage(
              context: context,
              post: post);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(post.title),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            if (includeSubredditName)
                              Text('r/${post.subredditName}'),
                            Text('u/${post.authorName}'),
                            Text(formatElapsedUtc(post.createdAtUtc)),
                          ])),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          Text(
                            '${formatCount(post.score)} points',
                            style: TextStyle(
                              color: post.voteDir == VoteDir.up ? Colors.deepOrange :
                                     post.voteDir == VoteDir.down ? Colors.indigoAccent :
                                     Colors.grey)),
                          Text('${formatCount(post.commentCount)} comments')
                        ])
                    ])),
                if (post.media != null) 
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Material(
                      child: InkWell(
                        child: ClipPath(
                          clipper: ShapeBorderClipper(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0))),
                          child: SizedBox(
                            width: 70,
                            height: 60,
                            child: MediaThumbnail(
                              media: post.media))))))
              ])));
      });
  }
}

String postPageNameFrom(Post post) {
  return post.fullId;
}

