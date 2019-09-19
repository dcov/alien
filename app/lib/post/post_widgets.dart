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
        onTap: () => dispatch(PushPost(postKey: post.key)),
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
      final Post post = store.get(widget.postKey);
      return Column(
        children: <Widget>[
          Material(
            child: Padding(
              padding: MediaQuery.of(context).padding,
              child: SizedBox(
                height: 56.0,
                child: NavigationToolbar(
                  leading: IconButton(
                    onPressed: () => dispatch(PopPost(postKey: post.key)),
                    icon: Icon(Icons.close),
                  ),
                  middle: Text(
                    post.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: CommentsTreeScrollable(commentsTreeKey: post.comments.key),
          )
        ],
      );
    }
  );
}
