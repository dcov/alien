import 'package:elmer_flutter/elmer_flutter.dart';
import 'package:flutter/material.dart';
import 'package:reddit/reddit.dart' show VoteDir;

import '../models/post_model.dart';
import '../widgets/formatting.dart';
import '../widgets/pressable.dart';
import '../widgets/tile.dart';

import 'media_thumbnail.dart';

class PostDepthTile extends StatelessWidget {

  PostDepthTile({
    Key key,
    @required this.post,
  }) : super(key: key);

  final Post post;

  @override
  Widget build(BuildContext context) {
    return CustomTile(
      onTap: () { },
      icon: Icon(Icons.comment),
      title: Text(
        post.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis));
  }
}

class PostListTile extends StatelessWidget {

  PostListTile({
    Key key,
    @required this.post,
    this.includeSubredditName = true,
  }) : super(key: key);

  final Post post;

  final bool includeSubredditName;
  
  @override
  Widget build(_) => Connector(
    builder: (BuildContext context) {
      return Pressable(
        onPress: () { },
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

enum PostTileLayout {
  depth,
  list,
}

class PostTile extends StatelessWidget {

  PostTile({
    Key key,
    @required this.post,
    @required this.layout,
    this.includeSubredditName,
  }) : assert(post != null),
       assert(layout != null),
       assert(includeSubredditName != null || layout == PostTileLayout.depth),
       super(key: key);

  final Post post;

  final PostTileLayout layout;

  final bool includeSubredditName;

  @override
  Widget build(BuildContext context) {
    switch (layout) {
      case PostTileLayout.depth:
        return PostDepthTile(post: post);
      case PostTileLayout.list:
        return PostListTile(
          post: post,
          includeSubredditName: includeSubredditName);
    }
    throw UnimplementedError();
  }
}

