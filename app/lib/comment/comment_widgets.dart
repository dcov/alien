part of 'comment.dart';

class CommentTile extends StatelessWidget {

  CommentTile({
    Key key,
    @required this.commentKey
  }) : super(key: key);

  final ModelKey commentKey;

  @override
  Widget build(_) => Connector(
    builder: (BuildContext context, Store store, EventDispatch dispatch) {
      final Comment comment = store.get(this.commentKey);
      return ListTile(
        title: Text(comment.authorName),
      );
    }
  );
}
