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
import 'post_comments_slivers.dart';
import 'snudown_body.dart';

class _PostSliver extends StatelessWidget {

  _PostSliver({
    Key key,
    this.post,
    this.showSubreddit
  }) : assert(post != null),
       super(key: key);

  final Post post;

  final bool showSubreddit;

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
                fontSize: 16.0)),
            Wrap(
              spacing: 4.0,
              children: <Widget>[
                if (showSubreddit)
                  Text(
                    'r/${post.subredditName}',
                    style: TextStyle(
                      fontSize: 12.0)),
                Text(
                  'u/${post.authorName}',
                  style: TextStyle(
                    fontSize: 12.0)),
                Text(
                  formatElapsedUtc(post.createdAtUtc),
                  style: TextStyle(
                    fontSize: 12.0)),
              ]),
            Wrap(
              children: <Widget>[
                Text('')
              ]),
            if (post.selfText != null)
              SnudownBody(
                snudown: post.selfText,
                scrollable: false),
            if (post.media != null)
              AspectRatio(
                aspectRatio: 16/9,
                child: MediaThumbnail(
                  media: post.media),
              )
          ])));
  }
}

class _PostPageView extends StatelessWidget {

  _PostPageView({
    Key key,
    this.comments,
    this.showSubreddit,
  }) : super(key: key);

  final PostComments comments;

  final bool showSubreddit;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          backgroundColor: Theme.of(context).canvasColor,
          leading: CloseButton(color: Colors.black)),
        PostCommentsRefreshSliver(
          comments: comments),
        _PostSliver(
          post: comments.post,
          showSubreddit: showSubreddit),
        PostCommentsTreeSliver(
          comments: comments)
      ]);
  }
}

class _PostPage extends EntryPage {

  _PostPage({
    this.comments,
    String name,
    this.showSubreddit,
  }) : super(name: name);

  final PostComments comments;

  final bool showSubreddit;

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (BuildContext context) {
        return _PostPageView(
          comments: comments,
          showSubreddit: showSubreddit);
      });
  }
}

String postPageNameFrom(Post post) {
  return post.fullId;
}

void _showPostPage({
    BuildContext context,
    Post post,
    bool showSubreddit,
  }) {

  final comments = commentsFromPost(post);

  context.push(
    postPageNameFrom(post),
    (String pageName) {
      return _PostPage(
        comments: comments,
        name: pageName,
        showSubreddit: showSubreddit);
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
              post: post,
              showSubreddit: includeSubredditName);
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
                        spacing: 4.0,
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

