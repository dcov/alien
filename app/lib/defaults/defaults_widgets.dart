part of 'defaults.dart';

class DefaultsSliver extends StatelessWidget {

  const DefaultsSliver({
    Key key,
    @required this.defaultsKey
  });

  final ModelKey defaultsKey;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context, Store store, EventDispatch dispatch) {
      final Defaults defaults = store.get(this.defaultsKey);
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, int index) {
            return SubredditTile(
              subredditKey: defaults.subreddits[index].key);
          },
          childCount: defaults.subreddits.length
        ),
      );
    }
  );
}
