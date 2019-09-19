part of 'post.dart';

class PostTile extends StatelessWidget {

  PostTile({
    Key key,
    @required this.postKey
  }) : super(key: key);

  final ModelKey postKey;
  
  @override
  Widget build(_) => Connector(
    builder: (BuildContext context, Store store, EventDispatch dispatch) {
      final Post post = store.get(this.postKey);
      return ListTile(
        title: Text(post.title),
      );
    },
  );
}

class PostPage extends StatefulWidget {

  PostPage({
    Key key,
    @required this.postKey
  }) : super(key: key);

  final ModelKey postKey;

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context, Store store, EventDispatch dispatch) {
      return const SizedBox();
    }
  );
}
