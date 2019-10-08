part of 'defaults.dart';

class DefaultsSliver extends StatelessWidget {

  const DefaultsSliver({
    Key key,
    @required this.defaults
  });

  final Defaults defaults;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context, EventDispatch dispatch) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, int index) {
            return SubredditTile(
              subreddit: defaults.subreddits[index]);
          },
          childCount: defaults.subreddits.length
        ),
      );
    }
  );
}
