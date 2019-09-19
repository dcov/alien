part of 'scaffolding.dart';

Widget _buildTarget(RoutingTarget target, bool isPage) {
  if (target is Browse)
    return isPage ? BrowsePage(browseKey: target.key)
                  : BrowseTile(browseKey: target.key);
  else if (target is Subreddit)
    return isPage ? SubredditPage(subredditKey: target.key)
                  : SubredditTile(subredditKey: target.key);
  else if (target is Post)
    return isPage ? PostPage(postKey: target.key)
                  : PostTile(postKey: target.key);
  
  return const SizedBox();
}
