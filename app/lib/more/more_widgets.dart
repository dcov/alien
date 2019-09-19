part of 'more.dart';

class MoreTile extends StatelessWidget {

  const MoreTile({
    Key key,
    @required this.commentsTreeKey,
    @required this.moreKey
  }) : super(key: key);

  final ModelKey commentsTreeKey;

  final ModelKey moreKey;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext _, Store store, EventDispatch dispatch) {
      final More more = store.get(this.moreKey);
      return Padding(
        padding: EdgeInsets.only(left: 16.0 * more.depth),
        child: Material(
          child: InkWell(
            onTap: !more.isLoading
              ? () => dispatch(LoadMoreComments(
                    commentsTreeKey: this.commentsTreeKey, moreKey: more.key))
              : null,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: !more.isLoading
                ? Text('Load ${more.count} comments')
                : Text('Loading...'),
            )
          ),
        ),
      );
    },
  );
}
