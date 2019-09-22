part of 'scaffolding.dart';

enum _MapType {
  page,
  tile,
  pop_event
}

dynamic _mapTarget(RoutingTarget target, _MapType type) =>
  target is Browse ?
    type == _MapType.page ? BrowsePage(browseKey: target.key) :
    type == _MapType.tile ? BrowseTile(browseKey: target.key) :
                            PopBrowse(browseKey: target.key) :
  target is Subreddit ?
    type == _MapType.page ? SubredditPage(subredditKey: target.key) :
    type == _MapType.tile ? SubredditTile(subredditKey: target.key) :
                            PopSubreddit(subredditKey: target.key) :
  target is Post ?
    type == _MapType.page ? PostPage(postKey: target.key) :
    type == _MapType.tile ? PostTile(postKey: target.key) :
                            PopPost(postKey: target.key) : null;
