part of '../post.dart';

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
          includeSubredditName: includeSubredditName
        );
    }
    throw UnimplementedError();
  }
}

