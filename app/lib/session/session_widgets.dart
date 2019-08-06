part of 'session.dart';

class SessionSliver extends StatelessWidget {

  SessionSliver({ Key key }) : super(key: key);

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context, Store store, EventDispatch dispatch) {
      return SliverList(
        delegate: SliverChildListDelegate(<Widget>[
          Text('Lurking'),
          ListTile(
            title: Text('Recommended Subreddits'),
          ),
          ListTile(
            title: Text('Popular Subreddits'),
          ),
          ListTile(
            title: Text('Search'),
          ),
        ]),
      );
    },
  );
}
